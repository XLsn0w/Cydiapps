/* Cycript - The Truly Universal Scripting Language
 * Copyright (C) 2009-2016  Jay Freeman (saurik)
*/

/* GNU Affero General Public License, Version 3 {{{ */
/*
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.

 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.

 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
**/
/* }}} */

#include "cycript.hpp"

#include <iostream>
#include <set>
#include <map>
#include <iomanip>
#include <sstream>
#include <cmath>

#include <dlfcn.h>
#include <dirent.h>
#include <fcntl.h>
#include <unistd.h>

#include <sys/mman.h>
#include <sys/stat.h>

#include <frida-core.h>
#include <sqlite3.h>

#include "sig/parse.hpp"

#include "Bridge.hpp"
#include "Code.hpp"
#include "Decode.hpp"
#include "Error.hpp"
#include "Execute.hpp"
#include "Internal.hpp"
#include "JavaScript.hpp"
#include "Pooling.hpp"
#include "String.hpp"

const char *sqlite3_column_string(sqlite3_stmt *stmt, int n) {
    return reinterpret_cast<const char *>(sqlite3_column_text(stmt, n));
}

char *sqlite3_column_pooled(CYPool &pool, sqlite3_stmt *stmt, int n) {
    if (const char *value = sqlite3_column_string(stmt, n))
        return pool.strdup(value);
    else return NULL;
}

template <typename T>
class FridaRefPtr
{
  private:
    T *ptr_;

  public:
    FridaRefPtr(T *ptr) :
        ptr_(ptr)
    {
    }

    FridaRefPtr(const FridaRefPtr<T> &other) :
        ptr_(other.ptr_)
    {
        if (ptr_ != NULL)
            g_object_ref(ptr_);
    }

    FridaRefPtr() :
        ptr_(0)
    {
    }

    ~FridaRefPtr() {
        if (ptr_ != NULL)
            g_object_unref(ptr_);
    }

    bool IsNull() const {
        return ptr_ == 0;
    }

    FridaRefPtr &operator =(const FridaRefPtr &other) {
        FridaRefPtr tmp(other);
        Swap(*this, tmp);
        return *this;
    }

    FridaRefPtr &operator =(T *other) {
        FridaRefPtr tmp(other);
        Swap(*this, tmp);
        return *this;
    }

    T *operator ->() const {
        return ptr_;
    }

    T &operator *() const {
        return *ptr_;
    }

    operator T *() {
        return ptr_;
    }

    static void Swap(FridaRefPtr &a, FridaRefPtr &b) {
        T *tmp(a.ptr_);
        a.ptr_ = b.ptr_;
        b.ptr_ = tmp;
    }
};

static const char *ResolveModule(CYPool &pool, const char *name, const char *from);
static const char *TryResolveFile(CYPool &pool, bool exact, const char *name);
static const char *TryResolveDirectory(CYPool &pool, const char *name);
static const char *TryResolveEither(CYPool &pool, const char *name);
static CYUTF8String CompileModule(CYPool &pool, CYUTF8String code);
static void OnDetached(FridaSession *session, FridaSessionDetachReason reason, FridaCrash *crash, gpointer user_data);
static void OnMessage(FridaScript *script, const gchar *message, GBytes *data, gpointer user_data);
static void OnStanza(JsonArray *stanza);
static void OnError(JsonObject *error);
static void OnLog(JsonObject *item);
static FridaRefPtr<FridaDevice> ResolveDevice(const char *device_id, const char *host, FridaRefPtr<FridaDeviceManager> manager);
static guint ResolveProcess(const char *target, FridaRefPtr<FridaDevice> device);
static void CheckGError(GError *&error);

static sqlite3 *database_;

static FridaRefPtr<FridaDeviceManager> device_manager_;
static FridaRefPtr<FridaDevice> device_;
static FridaRefPtr<FridaSession> session_;
static FridaRefPtr<FridaScript> script_;

static GMutex lock_;
static GCond cond_;
static bool detached_;
static bool received_reply_;
static gchar *reply_;

_visible void CYAttach(const char *device_id, const char *host, const char *target) {
    CYPool pool;

    auto library_path(CYPoolLibraryPath(pool));

    const char *db(pool.strcat(library_path, "/libcycript.db", NULL));
    _sqlcall(sqlite3_open_v2(db, &database_, SQLITE_OPEN_READONLY, NULL));

    frida_init();

    FridaRefPtr<FridaDeviceManager> manager(frida_device_manager_new());

    FridaRefPtr<FridaDevice> device(ResolveDevice(device_id, host, manager));

    auto pid = ResolveProcess(target, device);

    GError *error(NULL);
    FridaRefPtr<FridaSession> session(frida_device_attach_sync(device, pid, &error));
    CheckGError(error);
    g_signal_connect(session, "detached", G_CALLBACK(OnDetached), NULL);

    CYUTF8String source(CYPoolFileUTF8String(pool, pool.strcat(library_path, "/libcycript.js", NULL)));
    if (source.data == NULL)
        CYThrow("libcycript.js not found");

    FridaRefPtr<FridaScriptOptions> options(frida_script_options_new());
    frida_script_options_set_name(options, "libcycript-runtime");

    FridaRefPtr<FridaScript> script(frida_session_create_script_sync(session, source.data, options, &error));
    CheckGError(error);
    g_signal_connect(script, "message", G_CALLBACK(OnMessage), NULL);

    frida_script_load_sync(script, &error);
    CheckGError(error);

    device_manager_ = manager;
    device_ = device;
    session_ = session;
    script_ = script;
}

_visible void CYDetach() {
    if (!script_.IsNull()) {
        frida_script_unload_sync(script_, NULL);
        script_ = NULL;
    }

    if (!session_.IsNull()) {
        frida_session_detach_sync(session_);
        session_ = NULL;
    }

    device_ = NULL;

    if (!device_manager_.IsNull()) {
        frida_device_manager_close_sync(device_manager_);
        device_manager_ = NULL;
    }
}

_visible void CYSetArgs(const char *argv0, const char *script, int argc, const char *argv[]) {
}

_visible void CYGarbageCollect() {
  CYPool pool;
  CYExecute(pool, "gc();");
}

_visible void CYDestroyContext() {
}

_visible const char *CYExecute(CYPool &pool, CYUTF8String code) {
    FridaRefPtr<JsonBuilder> builder(json_builder_new());
    json_builder_begin_object(builder);
    json_builder_set_member_name(builder, "type");
    json_builder_add_string_value(builder, "eval");
    json_builder_set_member_name(builder, "payload");
    json_builder_add_string_value(builder, code.data);
    json_builder_end_object(builder);
    auto root(json_builder_get_root(builder));
    auto message(json_to_string(root, FALSE));
    json_node_unref(root);

    GError *error(NULL);
    frida_script_post_sync(script_, message, NULL, &error);
    g_free(message);
    CheckGError(error);

    bool detached(false);
    char *reply(NULL);
    g_mutex_lock(&lock_);
    while (!detached_ && !received_reply_)
        g_cond_wait(&cond_, &lock_);
    detached = detached_;
    if (received_reply_) {
        reply = pool.strdup(reply_);
        g_free(reply_);
        received_reply_ = false;
        reply_ = NULL;
    }
    g_mutex_unlock(&lock_);

    if (detached && reply == NULL)
        CYThrow("Target process terminated");

    return reply;
}

static void OnEvalResult(JsonNode *result) {
    gchar *reply(g_strdup(json_node_get_string(result)));
    g_mutex_lock(&lock_);
    g_assert(reply_ == NULL);
    received_reply_ = true;
    reply_ = reply;
    g_cond_signal(&cond_);
    g_mutex_unlock(&lock_);
}

_visible void CYCancel() {
}

static void OnLookupRequest(const char *property) {
    CYPool pool;

    sqlite3_stmt *statement;

    _sqlcall(sqlite3_prepare(database_,
        "select "
            "\"cache\".\"code\", "
            "\"cache\".\"flags\" "
        "from \"cache\" "
        "where"
            " \"cache\".\"system\" & " CY_SYSTEM " == " CY_SYSTEM " and"
            " \"cache\".\"name\" = ?"
        " limit 1"
    , -1, &statement, NULL));

    _sqlcall(sqlite3_bind_text(statement, 1, property, -1, SQLITE_STATIC));

    bool success;
    CYUTF8String parsed;
    unsigned flags(0);
    if (_sqlcall(sqlite3_step(statement)) == SQLITE_DONE)
        success = false;
    else {
        success = true;
        auto code = sqlite3_column_pooled(pool, statement, 0);
        flags = sqlite3_column_int(statement, 1);

        try {
            parsed = CYPoolCode(pool, code);
        } catch (const CYException &error) {
            std::cerr << "failed to parse cached code for " << property << ": " << error.PoolCString(pool) << std::endl;
            success = false;
        }
    }

    _sqlcall(sqlite3_finalize(statement));

    FridaRefPtr<JsonBuilder> builder(json_builder_new());
    json_builder_begin_object(builder);
    json_builder_set_member_name(builder, "type");
    json_builder_add_string_value(builder, "lookup:reply");
    json_builder_set_member_name(builder, "payload");
    if (success) {
        json_builder_begin_object(builder);
        json_builder_set_member_name(builder, "code");
        json_builder_add_string_value(builder, parsed.data);
        json_builder_set_member_name(builder, "flags");
        json_builder_add_int_value(builder, flags);
        json_builder_end_object(builder);
    } else {
        json_builder_add_null_value(builder);
    }
    json_builder_end_object(builder);
    auto root(json_builder_get_root(builder));
    auto message(json_to_string(root, FALSE));
    json_node_unref(root);

    frida_script_post(script_, message, NULL, NULL, NULL);
    g_free(message);
}

static void OnCompleteRequest(const char *prefix) {
    FridaRefPtr<JsonBuilder> builder(json_builder_new());
    json_builder_begin_object(builder);
    json_builder_set_member_name(builder, "type");
    json_builder_add_string_value(builder, "complete:reply");

    sqlite3_stmt *statement;

    auto prefix_length(strlen(prefix));
    if (prefix_length == 0)
        _sqlcall(sqlite3_prepare(database_,
            "select "
                "\"cache\".\"name\" "
            "from \"cache\" "
            "where"
                " \"cache\".\"system\" & " CY_SYSTEM " == " CY_SYSTEM
        , -1, &statement, NULL));
    else {
        _sqlcall(sqlite3_prepare(database_,
            "select "
                "\"cache\".\"name\" "
            "from \"cache\" "
            "where"
                " \"cache\".\"name\" >= ? and \"cache\".\"name\" < ? and "
                " \"cache\".\"system\" & " CY_SYSTEM " == " CY_SYSTEM
        , -1, &statement, NULL));

        _sqlcall(sqlite3_bind_text(statement, 1, prefix, -1, SQLITE_STATIC));

        char *after(g_strdup(prefix));
        ++after[prefix_length - 1];
        _sqlcall(sqlite3_bind_text(statement, 2, after, -1, SQLITE_TRANSIENT));
        g_free(after);
    }

    json_builder_set_member_name(builder, "payload");
    json_builder_begin_array(builder);
    while (_sqlcall(sqlite3_step(statement)) != SQLITE_DONE) {
        json_builder_add_string_value(builder, sqlite3_column_string(statement, 0));
    }
    json_builder_end_array(builder);
    json_builder_end_object(builder);

    _sqlcall(sqlite3_finalize(statement));

    auto root(json_builder_get_root(builder));
    auto message(json_to_string(root, FALSE));
    json_node_unref(root);

    frida_script_post(script_, message, NULL, NULL, NULL);
    g_free(message);
}

static void OnRequireResolveRequest(JsonObject *request) {
    CYPool pool;

    auto library_path(CYPoolLibraryPath(pool));

    const char *name(json_object_get_string_member(request, "name"));
    const char *from(json_object_get_string_member(request, "from"));
    if (from == NULL)
        from = library_path;

    const char *path(NULL);

    const char *dirname(NULL);
    CYUTF8String code;

    const char *error(NULL);

    sqlite3_stmt *statement;

    _sqlcall(sqlite3_prepare(database_,
        "select "
            "\"module\".\"code\", "
            "\"module\".\"flags\" "
        "from \"module\" "
        "where"
            " \"module\".\"name\" = ?"
        " limit 1"
    , -1, &statement, NULL));

    _sqlcall(sqlite3_bind_text(statement, 1, name, -1, SQLITE_STATIC));

    if (_sqlcall(sqlite3_step(statement)) != SQLITE_DONE) {
        path = name;

        dirname = library_path;
        code.data = static_cast<const char *>(sqlite3_column_blob(statement, 0));
        code.size = sqlite3_column_bytes(statement, 0);
        try {
            code = CompileModule(pool, code);
        } catch (const CYException &e) {
            error = e.PoolCString(pool);
        }
    } else {
        try {
            path = ResolveModule(pool, name, from);
        } catch (const CYException &e) {
            error = e.PoolCString(pool);
        }
    }

    _sqlcall(sqlite3_finalize(statement));

    FridaRefPtr<JsonBuilder> builder(json_builder_new());
    json_builder_begin_object(builder);
    json_builder_set_member_name(builder, "type");
    json_builder_add_string_value(builder, "require:resolve:reply");
    json_builder_set_member_name(builder, "payload");
    if (error == NULL) {
        json_builder_begin_object(builder);

        json_builder_set_member_name(builder, "path");
        json_builder_add_string_value(builder, path);

        json_builder_set_member_name(builder, "module");
        if (code.data != NULL) {
            json_builder_begin_object(builder);
            json_builder_set_member_name(builder, "dirname");
            json_builder_add_string_value(builder, dirname);
            json_builder_set_member_name(builder, "code");
            json_builder_add_string_value(builder, code.data);
            json_builder_end_object(builder);
        } else {
            json_builder_add_null_value(builder);
        }
        json_builder_end_object(builder);
    } else {
        json_builder_add_null_value(builder);
    }
    json_builder_end_object(builder);
    auto root(json_builder_get_root(builder));
    auto message(json_to_string(root, FALSE));
    json_node_unref(root);

    frida_script_post(script_, message, NULL, NULL, NULL);
    g_free(message);
}

static void OnRequireReadRequest(const char *path) {
    CYPool pool;

    auto dirname(g_path_get_dirname(path));
    auto filename(g_path_get_basename(path));

    CYUTF8String contents;
    bool is_code(g_str_has_suffix(filename, ".cy") || g_str_has_suffix(filename, ".js"));
    bool is_json(g_str_has_suffix(filename, ".json"));
    const char *error(NULL);

    // TODO: make this stricter as we technically can't trust the remote agent
    bool allowed(is_code || is_json);
    if (allowed) {
        contents = CYPoolFileUTF8String(pool, path);
        if (is_code) {
            try {
                contents = CompileModule(pool, contents);
            } catch (const CYException &e) {
                error = e.PoolCString(pool);
            }
        }
    } else {
        error = "Access denied";
    }

    FridaRefPtr<JsonBuilder> builder(json_builder_new());
    json_builder_begin_object(builder);
    json_builder_set_member_name(builder, "type");
    json_builder_add_string_value(builder, "require:read:reply");
    json_builder_set_member_name(builder, "payload");
    if (error == NULL) {
        json_builder_begin_object(builder);
        json_builder_set_member_name(builder, "dirname");
        json_builder_add_string_value(builder, dirname);
        json_builder_set_member_name(builder, is_code ? "code" : "data");
        json_builder_add_string_value(builder, contents.data);
        json_builder_end_object(builder);
    } else {
        json_builder_add_null_value(builder);
    }
    json_builder_end_object(builder);
    auto root(json_builder_get_root(builder));
    auto message(json_to_string(root, FALSE));
    json_node_unref(root);

    frida_script_post(script_, message, NULL, NULL, NULL);
    g_free(message);

    g_free(filename);
    g_free(dirname);
}

static CYUTF8String CompileModule(CYPool &pool, CYUTF8String code) {
    std::stringstream wrap;
    wrap << "(function (exports, require, module, __filename, __dirname) { " << code << "\n});";
    return CYPoolCode(pool, *wrap.rdbuf());
}

static const char *ResolveModule(CYPool &pool, const char *name, const char *from) {
    if (g_path_is_absolute(name)) {
        auto path(TryResolveEither(pool, name));
        if (path != NULL)
            return path;
    } else {
        if (g_str_has_prefix(name, "./") || g_str_has_prefix(name, "../")) {
            auto absolute_name(g_build_filename(from, name, NULL));
            auto path(TryResolveEither(pool, pool.strdup(absolute_name)));
            g_free(absolute_name);
            if (path != NULL)
                return path;
        } else {
            bool reached_top(false);
            std::string current(from);
            do {
                auto parent(g_path_get_dirname(current.c_str()));
                reached_top = strcmp(parent, ".") == 0 || parent == current;
                auto modules_name(g_build_filename(parent, "node_modules", name, NULL));
                auto path(TryResolveEither(pool, pool.strdup(modules_name)));
                g_free(modules_name);
                current = parent;
                g_free(parent);
                if (path != NULL)
                    return path;
            } while (!reached_top);

            auto library_name(g_build_filename(CYPoolLibraryPath(pool), "cycript0.9", pool.strcat(name, ".cy", NULL), NULL));
            auto path(TryResolveFile(pool, true, pool.strdup(library_name)));
            g_free(library_name);
            if (path != NULL)
                return path;
        }
    }

    CYThrow("Cannot find module '%s'", name);
}

static const char *TryResolveFile(CYPool &pool, bool exact, const char *name) {
    if (exact)
        return g_file_test(name, G_FILE_TEST_IS_REGULAR) ? name : NULL;

    const char *candidates[2] = {
        pool.strcat(name, ".js", NULL),
        pool.strcat(name, ".json", NULL),
    };
    for (auto i = 0; i != G_N_ELEMENTS(candidates); i++) {
        auto candidate(candidates[i]);
        if (g_file_test(candidate, G_FILE_TEST_IS_REGULAR))
            return candidate;
    }

    return NULL;
}

static const char *TryResolveDirectory(CYPool &pool, const char *name) {
    if (!g_file_test(name, G_FILE_TEST_IS_DIR))
        return NULL;

    const char *path(NULL);
    auto package_json_path(g_build_filename(name, "package.json", NULL));
    if (g_file_test(package_json_path, G_FILE_TEST_IS_REGULAR)) {
        FridaRefPtr<JsonParser> parser(json_parser_new());
        if (json_parser_load_from_file(parser, package_json_path, NULL)) {
            auto root(json_parser_get_root(parser));
            if (JSON_NODE_HOLDS_OBJECT(root)) {
                auto main(json_object_get_member(json_node_get_object(root), "main"));
                if (JSON_NODE_HOLDS_VALUE(main) && json_node_get_value_type(main) == G_TYPE_STRING) {
                    auto package_name(g_build_filename(name, json_node_get_string(main), NULL));
                    path = TryResolveFile(pool, true, pool.strdup(package_name));
                    g_free(package_name);
                }
            }
        }
    }
    g_free(package_json_path);
    if (path != NULL)
        return path;

    auto index_name(g_build_filename(name, "index", NULL));
    path = TryResolveFile(pool, false, pool.strdup(index_name));
    g_free(index_name);
    return path;
}

static const char *TryResolveEither(CYPool &pool, const char *name) {
    auto path(TryResolveFile(pool, true, name));
    if (path == NULL)
        path = TryResolveDirectory(pool, name);
    return path;
}

static void OnDetached(FridaSession *session, FridaSessionDetachReason reason, FridaCrash *crash, gpointer user_data) {
    g_mutex_lock(&lock_);
    detached_ = true;
    g_cond_signal(&cond_);
    g_mutex_unlock(&lock_);
}

static void OnMessage(FridaScript *script, const gchar *message, GBytes *data, gpointer user_data) {
    FridaRefPtr<JsonParser> parser(json_parser_new());
    json_parser_load_from_data(parser, message, -1, NULL);

    auto root(json_node_get_object(json_parser_get_root(parser)));
    auto type(json_object_get_string_member(root, "type"));
    if (strcmp(type, "send") == 0)
        OnStanza(json_object_get_array_member(root, "payload"));
    else if (strcmp(type, "error") == 0)
        OnError(root);
    else if (strcmp(type, "log") == 0)
        OnLog(root);
}

static void OnStanza(JsonArray *stanza) {
    auto name(json_array_get_string_element(stanza, 0));
    auto payload(json_array_get_element(stanza, 1));
    if (strcmp(name, "eval:result") == 0)
        OnEvalResult(payload);
    else if (strcmp(name, "lookup") == 0)
        OnLookupRequest(json_node_get_string(payload));
    else if (strcmp(name, "complete") == 0)
        OnCompleteRequest(json_node_get_string(payload));
    else if (strcmp(name, "require:resolve") == 0)
        OnRequireResolveRequest(json_node_get_object(payload));
    else if (strcmp(name, "require:read") == 0)
        OnRequireReadRequest(json_node_get_string(payload));
}

static void OnError(JsonObject *error) {
    auto stack(json_object_get_string_member(error, "stack"));
    std::cerr << "[error] " << stack << std::endl;
}

static void OnLog(JsonObject *item) {
    auto message(json_object_get_string_member(item, "payload"));
    std::cout << "[log] " << message << std::endl;
}

static FridaRefPtr<FridaDevice> ResolveDevice(const char *device_id, const char *host, FridaRefPtr<FridaDeviceManager> manager) {
    FridaRefPtr<FridaDevice> device;

    GError *error(NULL);
    if (host != NULL) {
        device = frida_device_manager_add_remote_device_sync(manager, host, &error);
        CheckGError(error);
    } else {
        FridaRefPtr<FridaDeviceList> devices(frida_device_manager_enumerate_devices_sync(manager, &error));
        CheckGError(error);

        auto size(frida_device_list_size(devices));
        for (gint i(0); i != size; i++) {
            FridaRefPtr<FridaDevice> d(frida_device_list_get(devices, i));
            if ((device_id == NULL && frida_device_get_dtype(d) == FRIDA_DEVICE_TYPE_LOCAL) ||
                (device_id != NULL && strcmp(frida_device_get_id(d), device_id) == 0)) {
                device = d;
                break;
            }
        }

        if (device.IsNull())
            CYThrow("Device not found");
    }

    return device;
}

static guint ResolveProcess(const char *target, FridaRefPtr<FridaDevice> device) {
    const guint system_session_pid(0);

    if (target == NULL)
        return system_session_pid;

    gchar *endptr(NULL);
    guint64 parsed_pid(g_ascii_strtoull(target, &endptr, 10));
    bool valid = endptr == target + strlen(target);
    if (valid) {
        return parsed_pid;
    } else {
        FridaRefPtr<FridaProcess> process;

        GError *error(NULL);
        FridaRefPtr<FridaProcessList> processes(frida_device_enumerate_processes_sync(device, &error));
        CheckGError(error);

        auto size(frida_process_list_size(processes));
        auto normalized_target(g_utf8_casefold(target, -1));
        for (gint i(0); i != size && process.IsNull(); i++) {
            FridaRefPtr<FridaProcess> p(frida_process_list_get(processes, i));
            auto name(frida_process_get_name(p));
            auto normalized_name(g_utf8_casefold(name, -1));
            if (strcmp(normalized_name, normalized_target) == 0)
                process = p;
            g_free(normalized_name);
        }
        g_free(normalized_target);

        if (process.IsNull())
            CYThrow("Process not found");

        return frida_process_get_pid(process);
    }
}

static void CheckGError(GError *&error) {
    if (error != NULL) {
        std::string message(error->message);
        g_clear_error(&error);
        CYThrow("%s", message.c_str());
    }
}

#ifdef __ANDROID__
char *CYPoolLibraryPath_(CYPool &pool) {
    FILE *maps(fopen("/proc/self/maps", "r"));
    struct F { FILE *f; F(FILE *f) : f(f) {}
        ~F() { fclose(f); } } f(maps);

    size_t function(reinterpret_cast<size_t>(&CYPoolLibraryPath));

    for (;;) {
        size_t start; size_t end; char flags[8]; unsigned long long offset;
        int major; int minor; unsigned long long inode; char file[1024];
        int count(fscanf(maps, "%zx-%zx %7s %llx %x:%x %llu%[ ]%1024[^\n]\n",
            &start, &end, flags, &offset, &major, &minor, &inode, file, file));
        if (count < 8) break; else if (start <= function && function < end)
            return pool.strdup(file);
    }

    _assert(false);
}
#else
char *CYPoolLibraryPath_(CYPool &pool) {
    Dl_info addr;
    _assert(dladdr(reinterpret_cast<void *>(&CYPoolLibraryPath), &addr) != 0);
    return pool.strdup(addr.dli_fname);
}
#endif

const char *CYPoolLibraryPath(CYPool &pool) {
    char *lib(CYPoolLibraryPath_(pool));

    char *slash(strrchr(lib, '/'));
    if (slash == NULL)
        return ".";
    *slash = '\0';

    return lib;
}
