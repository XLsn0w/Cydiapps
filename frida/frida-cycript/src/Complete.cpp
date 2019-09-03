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

#include <typeinfo>

#include "cycript.hpp"

#include "Driver.hpp"
#include "Replace.hpp"
#include "String.hpp"

static CYExpression *ParseExpression(CYPool &pool, CYUTF8String code) {
    std::stringstream stream;
    stream << '(' << code << ')';
    CYDriver driver(pool, *stream.rdbuf());
    if (driver.Parse() || !driver.errors_.empty())
        return NULL;

    CYOptions options;
    CYContext context(options);

    CYStatement *statement(driver.script_->code_);
    _assert(statement != NULL);
    _assert(statement->next_ == NULL);

    CYExpress *express(dynamic_cast<CYExpress *>(driver.script_->code_));
    _assert(express != NULL);

    CYParenthetical *parenthetical(dynamic_cast<CYParenthetical *>(express->expression_));
    _assert(parenthetical != NULL);

    return parenthetical->expression_;
}

_visible char **CYComplete(const char *word, const std::string &line, CYUTF8String (*run)(CYPool &pool, const std::string &)) {
    CYLocalPool pool;

    std::stringbuf stream(line);
    CYDriver driver(pool, stream);

    driver.auto_ = true;

    if (driver.Parse() || !driver.errors_.empty())
        return NULL;

    if (driver.mode_ == CYDriver::AutoNone)
        return NULL;

    CYExpression *expression;

    CYOptions options;
    CYContext context(options);

    std::ostringstream prefix;

    switch (driver.mode_) {
        case CYDriver::AutoPrimary:
            expression = $ CYThis();
        break;

        case CYDriver::AutoDirect:
            expression = driver.context_;
        break;

        case CYDriver::AutoIndirect:
            expression = $ CYIndirect(driver.context_);
        break;

        case CYDriver::AutoMessage: {
            CYDriver::Context &thing(driver.contexts_.back());
            expression = $M($C1($V("object_getClass"), thing.context_), $S("prototype"));
            for (CYDriver::Context::Words::const_iterator part(thing.words_.begin()); part != thing.words_.end(); ++part)
                prefix << (*part)->word_ << ':';
        } break;

        case CYDriver::AutoResolve:
            expression = $M(driver.context_, $S("$cyr"));
        break;

        case CYDriver::AutoStruct:
            expression = $ CYThis();
            prefix << "$cys";
        break;

        case CYDriver::AutoEnum:
            expression = $ CYThis();
            prefix << "$cye";
        break;

        default:
            _assert(false);
    }

    std::string begin(prefix.str());

    CYBoolean *message;
    if (driver.mode_ == CYDriver::AutoMessage)
        message = $ CYTrue();
    else
        message = $ CYFalse();

    driver.script_ = $ CYScript($ CYExpress($C4(ParseExpression(pool,
    "   function(object, prefix, word, message) {\n"
    "       var names = [];\n"
    "       var before = prefix.length;\n"
    "       prefix += word;\n"
    "       var entire = prefix.length;\n"
    "       if (false) {\n"
    "           for (var name in object)\n"
    "               if (name.substring(0, entire) == prefix)\n"
    "                   names.push(name);\n"
    "       } else do {\n"
    "           if (object.hasOwnProperty(\"cy$complete\"))\n"
    "               names = names.concat(object.cy$complete(prefix, message));\n"
    "           try {\n"
    "               var local = Object.getOwnPropertyNames(object);\n"
    "           } catch (e) {\n"
    "               continue;\n"
    "           }\n"
    "           for (var name of local)\n"
    "               if (name.substring(0, entire) == prefix)\n"
    "                   names.push(name);\n"
    "       } while (object = typeof object === 'object' ? Object.getPrototypeOf(object) : object.__proto__);\n"
    "       return names;\n"
    "   }\n"
    ), expression, $S(begin.c_str()), $S(word), message)));

    driver.script_->Replace(context);

    std::stringbuf str;
    CYOutput out(str, options);
    out << *driver.script_;

    std::string code(str.str());
    CYUTF8String json(run(pool, code));
    // XXX: if this fails we should not try to parse it

    CYExpression *result(ParseExpression(pool, json));
    if (result == NULL)
        return NULL;

    CYArray *array(dynamic_cast<CYArray *>(result->Primitive(context)));
    if (array == NULL)
        return NULL;

    // XXX: use an std::set?
    typedef std::vector<CYUTF8String> Completions;
    Completions completions;

    std::string common;
    bool rest(false);

    for (CYElement *element(array->elements_); element != NULL; ) {
        CYElementValue *value(dynamic_cast<CYElementValue *>(element));
        _assert(value != NULL);
        element = value->next_;

        _assert(value->value_ != NULL);
        CYString *string(value->value_->String(context));
        if (string == NULL)
            CYThrow("string was actually %s", typeid(*value->value_).name());

        CYUTF8String completion(string->value_, string->size_);
        _assert(completion.size >= begin.size());
        completion.data += begin.size();
        completion.size -= begin.size();

        if (completion.size == 0 && driver.mode_ == CYDriver::AutoMessage)
            completion = "]";

        if (CYStartsWith(completion, "$cy"))
            continue;
        completions.push_back(completion);

        if (!rest) {
            common = completion;
            rest = true;
        } else {
            size_t limit(completion.size), size(common.size());
            if (size > limit)
                common = common.substr(0, limit);
            else
                limit = size;
            for (limit = 0; limit != size; ++limit)
                if (common[limit] != completion.data[limit])
                    break;
            if (limit != size)
                common = common.substr(0, limit);
        }
    }

    size_t count(completions.size());
    if (count == 0)
        return NULL;

    size_t colon(common.find(':'));
    if (colon != std::string::npos)
        common = common.substr(0, colon + 1);
    if (completions.size() == 1)
        common += ' ';

    char **results(reinterpret_cast<char **>(malloc(sizeof(char *) * (count + 2))));

    results[0] = strdup(common.c_str());
    size_t index(0);
    for (Completions::const_iterator i(completions.begin()); i != completions.end(); ++i)
        results[++index] = strdup(i->data);
    results[count + 1] = NULL;

    return results;
}
