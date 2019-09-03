/* Cycript - The Truly Universal Scripting Language
 * Copyright (C) 2009-2016  Jay Freeman (saurik)
 * Copyright (C)      2016  NowSecure <oleavr@nowsecure.com>
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

#include "Driver.hpp"
#include "JavaScript.hpp"
#include "Syntax.hpp"

#include <sstream>

#include <node_api.h>

namespace cynode {

class Binding {
  public:
    static void Dispose(void *user_data) {
        CYDestroyContext();
    }

    static napi_value Attach(napi_env env, napi_callback_info info) {
        napi_value argv[3];
        size_t argc = 3;
        napi_get_cb_info(env, info, &argc, argv, NULL, NULL);
        if (argc != 3) {
            napi_throw_error(env, "EINVAL", "Missing one or more arguments");
            return NULL;
        }

        CYPool pool;

        const char *device_id;
        if (!GetOptionalStringArg(env, pool, argv[0], &device_id))
            return NULL;

        const char *host;
        if (!GetOptionalStringArg(env, pool, argv[1], &host))
            return NULL;

        const char *target;
        if (!GetOptionalStringArg(env, pool, argv[2], &target))
            return NULL;

        try {
            CYAttach(device_id, host, target);
        } catch (const CYException &error) {
            napi_throw_error(env, NULL, error.PoolCString(pool));
        }

        return NULL;
    }

    static napi_value Execute(napi_env env, napi_callback_info info) {
        napi_value command_value;
        size_t argc = 1;
        napi_get_cb_info(env, info, &argc, &command_value, NULL, NULL);
        if (argc != 1) {
            napi_throw_error(env, "EINVAL", "Missing command value");
            return NULL;
        }

        CYPool pool;

        const char *command;
        if (!GetStringArg(env, pool, command_value, &command))
            return NULL;

        try {
            std::stringbuf stream(command);
            CYDriver driver(pool, stream);
            driver.strict_ = false;

            if (driver.Parse() || !driver.errors_.empty()) {
                for (CYDriver::Errors::const_iterator error(driver.errors_.begin()); error != driver.errors_.end(); ++error) {
                    auto message(error->message_);
                    napi_throw_error(env, "EINVAL", message.c_str());
                    return NULL;
                }

                napi_throw_error(env, "EINVAL", "Invalid code");
                return NULL;
            }

            if (driver.script_ == NULL) {
                napi_throw_error(env, "EINVAL", "Invalid code");
                return NULL;
            }

            std::stringbuf str;
            CYOptions options;
            CYOutput out(str, options);
            out.pretty_ = false;
            driver.Replace(options);
            out << *driver.script_;
            auto code(str.str());

            auto json(CYExecute(pool, CYUTF8String(code.c_str(), code.size())));

            napi_value result_value;
            if (json != NULL)
                napi_create_string_utf8(env, json, NAPI_AUTO_LENGTH, &result_value);
            else
                napi_get_null(env, &result_value);
            return result_value;
        } catch (const CYException &error) {
            napi_throw_error(env, NULL, error.PoolCString(pool));
            return NULL;
        }
    }

  private:
    static bool GetStringArg(napi_env env, CYPool &pool, napi_value value, const char **result) {
        if (!GetOptionalStringArg(env, pool, value, result))
            return false;

        if (*result == NULL) {
            napi_throw_type_error(env, "EINVAL", "Expected a string");
            return false;
        }

        return true;
    }

    static bool GetOptionalStringArg(napi_env env, CYPool &pool, napi_value value, const char **result) {
        size_t size;
        if (napi_get_value_string_utf8(env, value, NULL, 0, &size) != napi_ok) {
            napi_value null_value;
            napi_get_null(env, &null_value);
            bool is_null = false;
            napi_strict_equals(env, value, null_value, &is_null);
            if (is_null) {
                *result = NULL;
                return true;
            }

            napi_throw_type_error(env, "EINVAL", "Expected a string");
            return false;
        }
        size += 1;
        char *str = pool.malloc<char>(size);

        napi_get_value_string_utf8(env, value, str, size, &size);

        *result = str;
        return true;
    }
};

NAPI_MODULE_INIT() {
    napi_property_descriptor desc[] = {
        {"attach", NULL, Binding::Attach, NULL, NULL, NULL, napi_default, NULL},
        {"execute", NULL, Binding::Execute, NULL, NULL, NULL, napi_default, NULL},
    };

    if (napi_define_properties(env, exports, sizeof(desc) / sizeof(desc[0]), desc) != napi_ok)
        return NULL;

    napi_add_env_cleanup_hook(env, Binding::Dispose, NULL);

    return exports;
}

}
