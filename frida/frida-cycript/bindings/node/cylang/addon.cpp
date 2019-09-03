/* Cycript - The Truly Universal Scripting Language
 * Copyright (C) 2009-2016  Jay Freeman (saurik)
 * Copyright (C) 2016-2018  NowSecure <oleavr@nowsecure.com>
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
#include "Syntax.hpp"

#include <sstream>

#include <node_api.h>

namespace cylang {

class Binding {
  public:
    static napi_value Compile(napi_env env, napi_callback_info info) {
        napi_value argv[3];
        size_t argc = 3;
        napi_get_cb_info(env, info, &argc, argv, NULL, NULL);
        if (argc != 3) {
            napi_throw_error(env, "EINVAL", "Missing one or more arguments");
            return NULL;
        }

        CYPool pool;

        std::string code;
        if (!GetStringArg(env, argv[0], code))
            return NULL;

        bool strict;
        if (!GetBoolArg(env, argv[1], strict))
            return NULL;

        bool pretty;
        if (!GetBoolArg(env, argv[2], pretty))
            return NULL;

        std::stringbuf stream(code);
        CYDriver driver(pool, stream);
        driver.strict_ = strict;

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
        out.pretty_ = pretty;
        driver.Replace(options);
        out << *driver.script_;

        std::string result(str.str());
        napi_value result_value;
        napi_create_string_utf8(env, result.c_str(), NAPI_AUTO_LENGTH, &result_value);
        return result_value;
    }

  private:
    static bool GetStringArg(napi_env env, napi_value value, std::string &result) {
        size_t size;
        if (napi_get_value_string_utf8(env, value, NULL, 0, &size) != napi_ok) {
            napi_throw_type_error(env, "EINVAL", "Expected a string");
            return false;
        }
        result.resize(size, '\0');

        napi_get_value_string_utf8(env, value, &result[0], size + 1, &size);

        return true;
    }

    static bool GetBoolArg(napi_env env, napi_value value, bool &result) {
        if (napi_get_value_bool(env, value, &result) != napi_ok) {
            napi_throw_type_error(env, "EINVAL", "Expected a boolean");
            return false;
        }

        return true;
    }
};

NAPI_MODULE_INIT() {
    napi_property_descriptor desc[] = {
        {"compile", NULL, Binding::Compile, NULL, NULL, NULL, napi_default, NULL},
    };

    if (napi_define_properties(env, exports, sizeof(desc) / sizeof(desc[0]), desc) != napi_ok)
        return NULL;

    return exports;
}

}
