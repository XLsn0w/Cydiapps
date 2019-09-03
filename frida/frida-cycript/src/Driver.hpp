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

#ifndef CYCRIPT_DRIVER_HPP
#define CYCRIPT_DRIVER_HPP

#include <iostream>

#include <stack>
#include <string>
#include <vector>

#include "Location.hpp"
#include "Options.hpp"
#include "Pooling.hpp"
#include "Standard.hpp"

struct CYClassTail;
struct CYExpression;
struct CYScript;
struct CYWord;

enum CYMark {
    CYMarkScript,
    CYMarkModule,
    CYMarkExpression,
};

class _visible CYDriver {
  public:
    CYPool &pool_;
    void *scanner_;

    std::vector<char> buffer_;
    bool tail_;

    std::stack<bool> in_;
    std::stack<bool> return_;
    std::stack<bool> super_;
    std::stack<bool> template_;
    std::stack<bool> yield_;

    std::stack<CYClassTail *> class_;

    CYMark mark_;
    int hold_;
    bool newline_;
    bool last_;

    std::streambuf &data_;

    int debug_;
    bool strict_;
    bool highlight_;

    enum Condition {
        XMLContentCondition,
        XMLTagCondition,
    };

    std::string filename_;

    struct Error {
        bool warning_;
        CYLocation location_;
        std::string message_;
    };

    typedef std::vector<Error> Errors;

    CYScript *script_;
    Errors errors_;

    bool auto_;

    struct Context {
        CYExpression *context_;

        Context(CYExpression *context) :
            context_(context)
        {
        }

        typedef std::vector<CYWord *> Words;
        Words words_;
    };

    typedef std::vector<Context> Contexts;
    Contexts contexts_;

    CYExpression *context_;

    enum Mode {
        AutoNone,
        AutoPrimary,
        AutoDirect,
        AutoIndirect,
        AutoMessage,
        AutoResolve,
        AutoStruct,
        AutoEnum,
    } mode_;

  private:
    void ScannerInit();
    void ScannerDestroy();

  public:
    CYDriver(CYPool &pool, std::streambuf &data, const std::string &filename = "");
    ~CYDriver();

    bool Parse(CYMark mark = CYMarkModule);
    void Replace(CYOptions &options);

    void SetRegEx(bool equal);
    void SetCondition(Condition condition);

    void PushCondition(Condition condition);
    void PopCondition();

    void Warning(const CYLocation &location, const char *message);
};

#endif/*CYCRIPT_DRIVER_HPP*/
