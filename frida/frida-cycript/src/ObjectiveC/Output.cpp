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

#include <sstream>

#include "Replace.hpp"

#include "ObjectiveC/Syntax.hpp"

void CYCategory::Output(CYOutput &out, CYFlags flags) const {
    out << "@implementation" << ' ' << *name_ << ' ' << '(' << ')' << '\n';
    ++out.indent_;

    CYForEach (message, messages_) {
        message->Output(out);
        out << '\n';
    }

    --out.indent_;
    out << "@end";
}

void CYImplementation::Output(CYOutput &out, CYFlags flags) const {
    out << "@implementation" << ' ' << *name_ << '\n';
    ++out.indent_;

    // XXX: implement

    --out.indent_;
    out << "@end";
}

void CYImplementationField::Output(CYOutput &out) const {
    type_->Output(out, name_);
    out.Terminate();
    out << '\n';
}

void CYInstanceLiteral::Output(CYOutput &out, CYFlags flags) const {
    out << '#';
    number_->Output(out, CYRight(flags));
}

void CYMessage::Output(CYOutput &out) const {
    out << (instance_ ? '-' : '+');

    CYForEach (parameter, parameters_)
        if (parameter->name_ != NULL) {
            out << ' ' << *parameter->name_;
            // XXX: this is off somehow
            if (parameter->identifier_ != NULL) {
                out << ':';
                if (parameter->type_ != NULL)
                    out << '(' << *parameter->type_ << ')';
                out << *parameter->identifier_;
            }
        }

    out << code_;
}

void CYBox::Output(CYOutput &out, CYFlags flags) const {
    out << '@';
    value_->Output(out, Precedence(), CYRight(flags));
}

void CYObjCArray::Output(CYOutput &out, CYFlags flags) const {
    out << '@' << '[' << elements_ << ']';
}

void CYObjCDictionary::Output(CYOutput &out, CYFlags flags) const {
    unsigned count(0);
    CYForEach (pair, pairs_)
        ++count;
    bool large(count > 8);

    out << '@' << '{';
    if (large) {
        out << '\n';
        ++out.indent_;
    }

    bool comma(false);
    CYForEach (pair, pairs_) {
        if (!comma)
            comma = true;
        else {
            out << ',';
            if (large)
                out << '\n';
            else
                out << ' ';
        }

        if (large)
            out << '\t';

        pair->key_->Output(out, CYAssign::Precedence_, CYNoFlags);
        out << ':' << ' ';
        pair->value_->Output(out, CYAssign::Precedence_, CYNoFlags);
    }

    if (large && out.pretty_)
        out << ',';

    if (large) {
        out << '\n';
        --out.indent_;
    }

    out << '\t' << '}';
}

void CYObjCBlock::Output(CYOutput &out, CYFlags flags) const {
    out << '^' << ' ' << *typed_ << ' ' << '(';

    bool comma(false);
    CYForEach (parameter, parameters_) {
        if (comma)
            out << ',' << ' ';
        else
            comma = true;
        parameter->type_->Output(out, parameter->name_);
    }

    out << ')' << ' ' << '{' << '\n';
    ++out.indent_;
    out << code_;
    --out.indent_;
    out << '\t' << '}';
}

void CYProtocol::Output(CYOutput &out) const {
    name_->Output(out, CYAssign::Precedence_, CYNoFlags);
    if (next_ != NULL)
        out << ',' << ' ' << *next_;
}

void CYSelector::Output(CYOutput &out, CYFlags flags) const {
    out << "@selector" << '(' << parts_ << ')';
}

void CYSelectorPart::Output(CYOutput &out) const {
    out << name_;
    if (value_)
        out << ':';
    out << next_;
}

void CYSend::Output(CYOutput &out, CYFlags flags) const {
    CYForEach (argument, arguments_)
        if (argument->name_ != NULL) {
            out << ' ' << *argument->name_;
            if (argument->value_ != NULL)
                out << ':' << *argument->value_;
        }
}

void CYSendDirect::Output(CYOutput &out, CYFlags flags) const {
    out << '[';
    self_->Output(out, CYAssign::Precedence_, CYNoFlags);
    CYSend::Output(out, flags);
    out << ']';
}

void CYSendSuper::Output(CYOutput &out, CYFlags flags) const {
    out << '[' << "super";
    CYSend::Output(out, flags);
    out << ']';
}
