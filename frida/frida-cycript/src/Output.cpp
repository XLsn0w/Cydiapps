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

#include <cmath>
#include <iomanip>
#include <sstream>

#include "Syntax.hpp"

enum CYStringType {
    CYStringTypeSingle,
    CYStringTypeDouble,
    CYStringTypeTemplate,
};

void CYStringify(std::ostringstream &str, const char *data, size_t size, CYStringifyMode mode) {
    if (size == 0) {
        str << "\"\"";
        return;
    }

    unsigned quot(0), apos(0), tick(0), line(0);
    for (const char *value(data), *end(data + size); value != end; ++value)
        switch (*value) {
            case '"': ++quot; break;
            case '\'': ++apos; break;
            case '`': ++tick; break;
            case '$': ++tick; break;
            case '\n': ++line; break;
        }

    bool split;
    if (mode != CYStringifyModeCycript)
        split = false;
    else {
        double ratio(double(line) / size);
        split = size > 10 && line > 2 && ratio > 0.005 && ratio < 0.10;
    }

    CYStringType type;
    if (mode == CYStringifyModeNative)
        type = CYStringTypeDouble;
    else if (split)
        type = CYStringTypeTemplate;
    else if (quot > apos)
        type = CYStringTypeSingle;
    else
        type = CYStringTypeDouble;

    bool parens(split && mode != CYStringifyModeNative && type != CYStringTypeTemplate);
    if (parens)
        str << '(';

    char border;
    switch (type) {
        case CYStringTypeSingle: border = '\''; break;
        case CYStringTypeDouble: border = '"'; break;
        case CYStringTypeTemplate: border = '`'; break;
    }

    str << border;

    bool space(false);

    for (const char *value(data), *end(data + size); value != end; ++value)
        if (*value == ' ') {
            space = true;
            str << ' ';
        } else { switch (uint8_t next = *value) {
            case '\\': str << "\\\\"; break;
            case '\b': str << "\\b"; break;
            case '\f': str << "\\f"; break;
            case '\r': str << "\\r"; break;
            case '\t': str << "\\t"; break;
            case '\v': str << "\\v"; break;

            case '\a':
                if (mode == CYStringifyModeNative)
                    str << "\\a";
                else goto simple;
            break;

            case '\n':
                if (!split)
                    str << "\\n";
                /*else if (mode == CYStringifyModeNative)
                    str << border << "\\\n" << border;*/
                else if (type != CYStringTypeTemplate)
                    str << border << '+' << border;
                else if (!space)
                    str << '\n';
                else
                    str << "\\n\\\n";
            break;

            case '$':
                if (type == CYStringTypeTemplate)
                    str << "\\$";
                else goto simple;
            break;

            case '`':
                if (type == CYStringTypeTemplate)
                    str << "\\`";
                else goto simple;
            break;

            case '"':
                if (type == CYStringTypeDouble)
                    str << "\\\"";
                else goto simple;
            break;

            case '\'':
                if (type == CYStringTypeSingle)
                    str << "\\'";
                else goto simple;
            break;

            case '\0':
                if (mode != CYStringifyModeNative && value[1] >= '0' && value[1] <= '9')
                    str << "\\x00";
                else
                    str << "\\0";
            break;

            default:
                if (next >= 0x20 && next < 0x7f) simple:
                    str << *value;
                else if (mode == CYStringifyModeNative)
                    str << "\\x" << std::setbase(16) << std::setw(2) << std::setfill('0') << unsigned(*value & 0xff);
                else {
                    unsigned levels(1);
                    if ((next & 0x80) != 0)
                        while ((next & 0x80 >> ++levels) != 0);

                    unsigned point(next & 0xff >> levels);
                    while (--levels != 0)
                        point = point << 6 | uint8_t(*++value) & 0x3f;

                    if (point < 0x100)
                        str << "\\x" << std::setbase(16) << std::setw(2) << std::setfill('0') << point;
                    else if (point < 0x10000)
                        str << "\\u" << std::setbase(16) << std::setw(4) << std::setfill('0') << point;
                    else {
                        point -= 0x10000;
                        str << "\\u" << std::setbase(16) << std::setw(4) << std::setfill('0') << (0xd800 | point >> 0x0a);
                        str << "\\u" << std::setbase(16) << std::setw(4) << std::setfill('0') << (0xdc00 | point & 0x3ff);
                    }
                }
        } space = false; }

    str << border;

    if (parens)
        str << ')';
}

void CYNumerify(std::ostringstream &str, double value) {
    if (std::isinf(value)) {
        if (value < 0)
            str << '-';
        str << "Infinity";
        return;
    }

    char string[32];
    // XXX: I want this to print 1e3 rather than 1000
    sprintf(string, "%.17g", value);
    str << string;
}

void CYOutput::Terminate() {
    operator ()(';');
    mode_ = NoMode;
}

CYOutput &CYOutput::operator <<(char rhs) {
    if (rhs == ' ' || rhs == '\n')
        if (pretty_)
            operator ()(rhs);
        else goto done;
    else if (rhs == '\t')
        if (pretty_)
            for (unsigned i(0); i != indent_; ++i)
                operator ()("    ", 4);
        else goto done;
    else if (rhs == '\r') {
        if (right_) {
            operator ()('\n');
            right_ = false;
        } goto done;
    } else goto work;

    right_ = true;
    mode_ = NoMode;
    goto done;

  work:
    if (mode_ == Terminated && rhs != '}') {
        right_ = true;
        operator ()(';');
    }

    if (rhs == ';') {
        if (pretty_)
            goto none;
        else {
            mode_ = Terminated;
            goto done;
        }
    } else if (rhs == '+') {
        if (mode_ == NoPlus)
            operator ()(' ');
        mode_ = NoPlus;
    } else if (rhs == '-') {
        if (mode_ == NoHyphen)
            operator ()(' ');
        mode_ = NoHyphen;
    } else if (WordEndRange_[rhs]) {
        if (mode_ == NoLetter)
            operator ()(' ');
        mode_ = NoLetter;
    } else none:
        mode_ = NoMode;

    right_ = true;
    operator ()(rhs);
  done:
    return *this;
}

CYOutput &CYOutput::operator <<(const char *rhs) {
    size_t size(strlen(rhs));

    if (size == 1)
        return *this << *rhs;

    if (mode_ == Terminated)
        operator ()(';');
    else if (
        mode_ == NoPlus && *rhs == '+' ||
        mode_ == NoHyphen && *rhs == '-' ||
        mode_ == NoLetter && WordEndRange_[*rhs]
    )
        operator ()(' ');

    char last(rhs[size - 1]);
    if (WordEndRange_[last] || last == '/')
        mode_ = NoLetter;
    else
        mode_ = NoMode;

    right_ = true;
    operator ()(rhs, size);
    return *this;
}

void CYArgument::Output(CYOutput &out) const {
    if (name_ != NULL) {
        out << *name_;
        if (value_ != NULL)
            out << ':' << ' ';
    }
    if (value_ != NULL)
        value_->Output(out, CYAssign::Precedence_, CYNoFlags);
    if (next_ != NULL) {
        out << ',';
        out << ' ' << *next_;
    }
}

void CYArray::Output(CYOutput &out, CYFlags flags) const {
    out << '[' << elements_ << ']';
}

void CYArrayComprehension::Output(CYOutput &out, CYFlags flags) const {
    out << '[' << *expression_ << ' ' << *comprehensions_ << ']';
}

void CYAssignment::Output(CYOutput &out, CYFlags flags) const {
    lhs_->Output(out, Precedence() - 1, CYLeft(flags) | CYNoRightHand);
    out << ' ' << Operator() << ' ';
    rhs_->Output(out, Precedence(), CYRight(flags));
}

void CYAttemptMember::Output(CYOutput &out, CYFlags flags) const {
    object_->Output(out, Precedence(), CYLeft(flags) | CYNoInteger);
    if (const char *word = property_->Word())
        out << "?." << word;
    else
        _assert(false);
}

void CYBlock::Output(CYOutput &out, CYFlags flags) const {
    out << '{' << '\n';
    ++out.indent_;
    out << code_;
    --out.indent_;
    out << '\t' << '}';
}

void CYBoolean::Output(CYOutput &out, CYFlags flags) const {
    out << '!' << (Value() ? "0" : "1");
    if ((flags & CYNoInteger) != 0)
        out << '.';
}

void CYBreak::Output(CYOutput &out, CYFlags flags) const {
    out << "break";
    if (label_ != NULL)
        out << ' ' << *label_;
    out << ';';
}

void CYCall::Output(CYOutput &out, CYFlags flags) const {
    bool protect((flags & CYNoCall) != 0);
    if (protect)
        out << '(';
    function_->Output(out, Precedence(), protect ? CYNoFlags : flags);
    out << '(' << arguments_ << ')';
    if (protect)
        out << ')';
}

namespace cy {
namespace Syntax {

void Catch::Output(CYOutput &out) const {
    out << ' ' << "catch" << ' ' << '(' << *name_ << ')' << ' ';
    out << '{' << '\n';
    ++out.indent_;
    out << code_;
    --out.indent_;
    out << '\t' << '}';
}

} }

void CYClassExpression::Output(CYOutput &out, CYFlags flags) const {
    bool protect((flags & CYNoClass) != 0);
    if (protect)
        out << '(';
    out << "class";
    if (name_ != NULL)
        out << ' ' << *name_;
    out << *tail_;;
    if (protect)
        out << ')';
}

void CYClassStatement::Output(CYOutput &out, CYFlags flags) const {
    out << "class" << ' ' << *name_  << *tail_;
}

void CYClassTail::Output(CYOutput &out) const {
    if (extends_ == NULL)
        out << ' ';
    else {
        out << '\n';
        ++out.indent_;
        out << "extends" << ' ';
        extends_->Output(out, CYAssign::Precedence_ - 1, CYNoFlags);
        out << '\n';
        --out.indent_;
    }

    out << '{' << '\n';
    ++out.indent_;

    --out.indent_;
    out << '}';
}

void CYCompound::Output(CYOutput &out, CYFlags flags) const {
    if (next_ == NULL)
        expression_->Output(out, flags);
    else {
        expression_->Output(out, CYLeft(flags));
        out << ',' << ' ';
        next_->Output(out, CYRight(flags));
    }
}

void CYComputed::PropertyName(CYOutput &out) const {
    out << '[';
    expression_->Output(out, CYAssign::Precedence_, CYNoFlags);
    out << ']';
}

void CYCondition::Output(CYOutput &out, CYFlags flags) const {
    test_->Output(out, Precedence() - 1, CYLeft(flags));
    out << ' ' << '?' << ' ';
    if (true_ != NULL)
        true_->Output(out, CYAssign::Precedence_, CYNoColon);
    out << ' ' << ':' << ' ';
    false_->Output(out, CYAssign::Precedence_, CYRight(flags));
}

void CYContinue::Output(CYOutput &out, CYFlags flags) const {
    out << "continue";
    if (label_ != NULL)
        out << ' ' << *label_;
    out << ';';
}

void CYClause::Output(CYOutput &out) const {
    out << '\t';
    if (value_ == NULL)
        out << "default";
    else {
        out << "case" << ' ';
        value_->Output(out, CYNoColon);
    }
    out << ':' << '\n';
    ++out.indent_;
    out << code_;
    --out.indent_;
    out << next_;
}

void CYDebugger::Output(CYOutput &out, CYFlags flags) const {
    out << "debugger" << ';';
}

void CYBinding::Output(CYOutput &out, CYFlags flags) const {
    out << *identifier_;
    //out.out_ << ':' << identifier_->usage_ << '#' << identifier_->offset_;
    if (initializer_ != NULL) {
        out << ' ' << '=' << ' ';
        initializer_->Output(out, CYAssign::Precedence_, CYRight(flags));
    }
}

void CYBindings::Output(CYOutput &out) const {
    Output(out, CYNoFlags);
}

void CYBindings::Output(CYOutput &out, CYFlags flags) const {
    const CYBindings *binding(this);
    bool first(true);

    for (;;) {
        CYBindings *next(binding->next_);

        CYFlags jacks(first ? CYLeft(flags) : next == NULL ? CYRight(flags) : CYCenter(flags));
        first = false;
        binding->binding_->Output(out, jacks);

        if (next == NULL)
            break;

        out << ',' << ' ';
        binding = next;
    }
}

void CYDirectMember::Output(CYOutput &out, CYFlags flags) const {
    object_->Output(out, Precedence(), CYLeft(flags) | CYNoInteger);
    if (const char *word = property_->Word())
        out << '.' << word;
    else
        out << '[' << *property_ << ']';
}

void CYDoWhile::Output(CYOutput &out, CYFlags flags) const {
    out << "do";

    unsigned line(out.position_.line);
    unsigned indent(out.indent_);
    code_->Single(out, CYCenter(flags), CYCompactLong);

    if (out.position_.line != line && out.recent_ == indent)
        out << ' ';
    else
        out << '\n' << '\t';

    out << "while" << ' ' << '(' << *test_ << ')';
}

void CYElementSpread::Output(CYOutput &out) const {
    out << "..." << value_;
}

void CYElementValue::Output(CYOutput &out) const {
    if (value_ != NULL)
        value_->Output(out, CYAssign::Precedence_, CYNoFlags);
    if (next_ != NULL || value_ == NULL) {
        out << ',';
        if (next_ != NULL && !next_->Elision())
            out << ' ';
    }
    if (next_ != NULL)
        next_->Output(out);
}

void CYEmpty::Output(CYOutput &out, CYFlags flags) const {
    out.Terminate();
}

void CYEval::Output(CYOutput &out, CYFlags flags) const {
    _assert(false);
}

void CYExpress::Output(CYOutput &out, CYFlags flags) const {
    expression_->Output(out, flags | CYNoBFC);
    out << ';';
}

void CYExpression::Output(CYOutput &out) const {
    Output(out, CYNoFlags);
}

void CYExpression::Output(CYOutput &out, int precedence, CYFlags flags) const {
    if (precedence < Precedence() || (flags & CYNoRightHand) != 0 && RightHand())
        out << '(' << *this << ')';
    else
        Output(out, flags);
}

void CYExtend::Output(CYOutput &out, CYFlags flags) const {
    lhs_->Output(out, CYLeft(flags));
    out << ' ' << object_;
}

void CYExternalDefinition::Output(CYOutput &out, CYFlags flags) const {
    out << "extern" << ' ' << abi_ << ' ';
    type_->Output(out, name_);
    out.Terminate();
}

void CYExternalExpression::Output(CYOutput &out, CYFlags flags) const {
    out << '(' << "extern" << ' ' << abi_ << ' ';
    type_->Output(out, name_);
    out << ')';
}

void CYFatArrow::Output(CYOutput &out, CYFlags flags) const {
    out << '(' << parameters_ << ')' << ' ' << "=>" << ' ' << '{' << code_ << '}';
}

void CYFinally::Output(CYOutput &out) const {
    out << ' ' << "finally" << ' ';
    out << '{' << '\n';
    ++out.indent_;
    out << code_;
    --out.indent_;
    out << '\t' << '}';
}

void CYFor::Output(CYOutput &out, CYFlags flags) const {
    out << "for" << ' ' << '(';
    if (initializer_ != NULL)
        initializer_->Output(out, CYNoIn);
    out.Terminate();
    if (test_ != NULL)
        out << ' ';
    out << test_;
    out.Terminate();
    if (increment_ != NULL)
        out << ' ';
    out << increment_;
    out << ')';
    code_->Single(out, CYRight(flags), CYCompactShort);
}

void CYForLexical::Output(CYOutput &out, CYFlags flags) const {
    out << (constant_ ? "const" : "let") << ' ';
    binding_->Output(out, CYRight(flags));
}

void CYForIn::Output(CYOutput &out, CYFlags flags) const {
    out << "for" << ' ' << '(';
    initializer_->Output(out, CYNoIn | CYNoRightHand);
    out << ' ' << "in" << ' ' << *iterable_ << ')';
    code_->Single(out, CYRight(flags), CYCompactShort);
}

void CYForInitialized::Output(CYOutput &out, CYFlags flags) const {
    out << "for" << ' ' << '(' << "var" << ' ';
    binding_->Output(out, CYNoIn | CYNoRightHand);
    out << ' ' << "in" << ' ' << *iterable_ << ')';
    code_->Single(out, CYRight(flags), CYCompactShort);
}

void CYForInComprehension::Output(CYOutput &out) const {
    out << "for" << ' ' << '(';
    binding_->Output(out, CYNoIn | CYNoRightHand);
    out << ' ' << "in" << ' ' << *iterable_ << ')';
}

void CYForOf::Output(CYOutput &out, CYFlags flags) const {
    out << "for" << ' ' << '(';
    initializer_->Output(out, CYNoRightHand);
    out << ' ' << "of" << ' ' << *iterable_ << ')';
    code_->Single(out, CYRight(flags), CYCompactShort);
}

void CYForOfComprehension::Output(CYOutput &out) const {
    out << "for" << ' ' << '(';
    binding_->Output(out, CYNoRightHand);
    out << ' ' << "of" << ' ' << *iterable_ << ')' << next_;
}

void CYForVariable::Output(CYOutput &out, CYFlags flags) const {
    out << "var" << ' ';
    binding_->Output(out, CYRight(flags));
}

void CYFunction::Output(CYOutput &out) const {
    out << '(' << parameters_ << ')' << ' ';
    out << '{' << '\n';
    ++out.indent_;
    out << code_;
    --out.indent_;
    out << '\t' << '}';
}

void CYFunctionExpression::Output(CYOutput &out, CYFlags flags) const {
    // XXX: one could imagine using + here to save a byte
    bool protect((flags & CYNoFunction) != 0);
    if (protect)
        out << '(';
    out << "function";
    if (name_ != NULL)
        out << ' ' << *name_;
    CYFunction::Output(out);
    if (protect)
        out << ')';
}

void CYFunctionStatement::Output(CYOutput &out, CYFlags flags) const {
    out << "function" << ' ' << *name_;
    CYFunction::Output(out);
}

void CYFunctionParameter::Output(CYOutput &out) const {
    binding_->Output(out, CYNoFlags);
    if (next_ != NULL)
        out << ',' << ' ' << *next_;
}

const char *CYIdentifier::Word() const {
    return next_ == NULL || next_ == this ? CYWord::Word() : next_->Word();
}

void CYIf::Output(CYOutput &out, CYFlags flags) const {
    bool protect(false);
    if (false_ == NULL && (flags & CYNoDangle) != 0) {
        protect = true;
        out << '{';
    }

    out << "if" << ' ' << '(' << *test_ << ')';

    CYFlags right(protect ? CYNoFlags : CYRight(flags));

    CYFlags jacks(CYNoDangle);
    if (false_ == NULL)
        jacks |= right;
    else
        jacks |= protect ? CYNoFlags : CYCenter(flags);

    unsigned line(out.position_.line);
    unsigned indent(out.indent_);
    true_->Single(out, jacks, CYCompactShort);

    if (false_ != NULL) {
        if (out.position_.line != line && out.recent_ == indent)
            out << ' ';
        else
            out << '\n' << '\t';

        out << "else";
        false_->Single(out, right, CYCompactLong);
    }

    if (protect)
        out << '}';
}

void CYIfComprehension::Output(CYOutput &out) const {
    out << "if" << ' ' << '(' << *test_ << ')' << next_;
}

void CYImport::Output(CYOutput &out, CYFlags flags) const {
    out << "@import";
}

void CYImportDeclaration::Output(CYOutput &out, CYFlags flags) const {
    _assert(false);
}

void CYIndirect::Output(CYOutput &out, CYFlags flags) const {
    out << "*";
    rhs_->Output(out, Precedence(), CYRight(flags));
}

void CYIndirectMember::Output(CYOutput &out, CYFlags flags) const {
    object_->Output(out, Precedence(), CYLeft(flags));
    if (const char *word = property_->Word())
        out << "->" << word;
    else
        out << "->" << '[' << *property_ << ']';
}

void CYInfix::Output(CYOutput &out, CYFlags flags) const {
    const char *name(Operator());
    bool protect((flags & CYNoIn) != 0 && strcmp(name, "in") == 0);
    if (protect)
        out << '(';
    CYFlags left(protect ? CYNoFlags : CYLeft(flags));
    lhs_->Output(out, Precedence(), left);
    out << ' ' << name << ' ';
    CYFlags right(protect ? CYNoFlags : CYRight(flags));
    rhs_->Output(out, Precedence() - 1, right);
    if (protect)
        out << ')';
}

void CYLabel::Output(CYOutput &out, CYFlags flags) const {
    out << *name_ << ':';
    statement_->Single(out, CYRight(flags), CYCompactShort);
}

void CYParenthetical::Output(CYOutput &out, CYFlags flags) const {
    out << '(';
    expression_->Output(out, CYCompound::Precedence_, CYNoFlags);
    out << ')';
}

void CYStatement::Output(CYOutput &out) const {
    Multiple(out);
}

void CYTemplate::Output(CYOutput &out, CYFlags flags) const {
    _assert(false);
}

void CYTypeArrayOf::Output(CYOutput &out, CYPropertyName *name) const {
    next_->Output(out, Precedence(), name, false);
    out << '[';
    out << size_;
    out << ']';
}

void CYTypeBlockWith::Output(CYOutput &out, CYPropertyName *name) const {
    out << '(' << '^';
    next_->Output(out, Precedence(), name, false);
    out << ')' << '(' << parameters_ << ')';
}

void CYTypeConstant::Output(CYOutput &out, CYPropertyName *name) const {
    out << "const";
    next_->Output(out, Precedence(), name, false);
}

void CYTypeFunctionWith::Output(CYOutput &out, CYPropertyName *name) const {
    next_->Output(out, Precedence(), name, false);
    out << '(' << parameters_;
    if (variadic_) {
        if (parameters_ != NULL)
            out << ',' << ' ';
        out << "...";
    }
    out << ')';
}

void CYTypePointerTo::Output(CYOutput &out, CYPropertyName *name) const {
    out << '*';
    next_->Output(out, Precedence(), name, false);
}

void CYTypeVolatile::Output(CYOutput &out, CYPropertyName *name) const {
    out << "volatile";
    next_->Output(out, Precedence(), name, true);
}

#ifdef __clang__
# pragma clang diagnostic push
# pragma clang diagnostic ignored "-Wtautological-undefined-compare"
#endif

void CYTypeModifier::Output(CYOutput &out, int precedence, CYPropertyName *name, bool space) const {
    if (this == NULL && name == NULL)
        return;
    else if (space)
        out << ' ';

    if (this == NULL) {
        name->PropertyName(out);
        return;
    }

    bool protect(precedence > Precedence());

    if (protect)
        out << '(';
    Output(out, name);
    if (protect)
        out << ')';
}

#ifdef __clang__
# pragma clang diagnostic pop
#endif

void CYType::Output(CYOutput &out, CYPropertyName *name) const {
    out << *specifier_;
    modifier_->Output(out, 0, name, true);
}

void CYType::Output(CYOutput &out) const {
    Output(out, NULL);
}

void CYEncodedType::Output(CYOutput &out, CYFlags flags) const {
    out << "@encode(" << typed_ << ")";
}

void CYTypedParameter::Output(CYOutput &out) const {
    type_->Output(out, name_);
    if (next_ != NULL)
        out << ',' << ' ' << next_;
}

void CYLambda::Output(CYOutput &out, CYFlags flags) const {
    // XXX: this is seriously wrong
    out << "[](";
    out << ")->";
    out << "{";
    out << "}";
}

void CYTypeDefinition::Output(CYOutput &out, CYFlags flags) const {
    out << "typedef" << ' ';
    type_->Output(out, name_);
    out.Terminate();
}

void CYTypeExpression::Output(CYOutput &out, CYFlags flags) const {
    out << '(' << "typedef" << ' ' << *typed_ << ')';
}

void CYLexical::Output(CYOutput &out, CYFlags flags) const {
    out << "let" << ' ';
    bindings_->Output(out, flags); // XXX: flags
    out << ';';
}

void CYModule::Output(CYOutput &out) const {
    out << part_;
    if (next_ != NULL)
        out << '.' << next_;
}

namespace cy {
namespace Syntax {

void New::Output(CYOutput &out, CYFlags flags) const {
    out << "new" << ' ';
    CYFlags jacks(CYNoCall | CYCenter(flags));
    constructor_->Output(out, Precedence(), jacks);
    if (arguments_ != NULL)
        out << '(' << *arguments_ << ')';
}

} }

void CYNull::Output(CYOutput &out, CYFlags flags) const {
    out << "null";
}

void CYNumber::Output(CYOutput &out, CYFlags flags) const {
    std::ostringstream str;
    CYNumerify(str, Value());
    std::string value(str.str());
    out << value.c_str();
    // XXX: this should probably also handle hex conversions and exponents
    if ((flags & CYNoInteger) != 0 && value.find('.') == std::string::npos)
        out << '.';
}

void CYNumber::PropertyName(CYOutput &out) const {
    Output(out, CYNoFlags);
}

void CYObject::Output(CYOutput &out, CYFlags flags) const {
    bool protect((flags & CYNoBrace) != 0);
    if (protect)
        out << '(';
    out << '{' << '\n';
    ++out.indent_;
    out << properties_;
    --out.indent_;
    out << '\t' << '}';
    if (protect)
        out << ')';
}

void CYPostfix::Output(CYOutput &out, CYFlags flags) const {
    lhs_->Output(out, Precedence(), CYLeft(flags));
    out << Operator();
}

void CYPrefix::Output(CYOutput &out, CYFlags flags) const {
    const char *name(Operator());
    out << name;
    if (Alphabetic())
        out << ' ';
    rhs_->Output(out, Precedence(), CYRight(flags));
}

void CYScript::Output(CYOutput &out) const {
    out << code_;
}

void CYProperty::Output(CYOutput &out) const {
    if (next_ != NULL || out.pretty_)
        out << ',';
    out << '\n' <<  next_;
}

void CYPropertyGetter::Output(CYOutput &out) const {
    out << "get" << ' ';
    name_->PropertyName(out);
    CYFunction::Output(out);
    CYProperty::Output(out);
}

void CYPropertyMethod::Output(CYOutput &out) const {
    name_->PropertyName(out);
    CYFunction::Output(out);
    CYProperty::Output(out);
}

void CYPropertySetter::Output(CYOutput &out) const {
    out << "set" << ' ';
    name_->PropertyName(out);
    CYFunction::Output(out);
    CYProperty::Output(out);
}

void CYPropertyValue::Output(CYOutput &out) const {
    out << '\t';
    name_->PropertyName(out);
    out << ':' << ' ';
    value_->Output(out, CYAssign::Precedence_, CYNoFlags);
    CYProperty::Output(out);
}

void CYRegEx::Output(CYOutput &out, CYFlags flags) const {
    out << Value();
}

void CYResolveMember::Output(CYOutput &out, CYFlags flags) const {
    object_->Output(out, Precedence(), CYLeft(flags));
    if (const char *word = property_->Word())
        out << "::" << word;
    else
        out << "::" << '[' << *property_ << ']';
}

void CYReturn::Output(CYOutput &out, CYFlags flags) const {
    out << "return";
    if (value_ != NULL)
        out << ' ' << *value_;
    out << ';';
}

void CYRubyBlock::Output(CYOutput &out, CYFlags flags) const {
    lhs_->Output(out, CYLeft(flags));
    out << ' ';
    proc_->Output(out, CYRight(flags));
}

void CYRubyProc::Output(CYOutput &out, CYFlags flags) const {
    out << '{' << ' ' << '|' << parameters_ << '|' << '\n';
    ++out.indent_;
    out << code_;
    --out.indent_;
    out << '\t' << '}';
}

void CYSubscriptMember::Output(CYOutput &out, CYFlags flags) const {
    object_->Output(out, Precedence(), CYLeft(flags));
    out << "." << '[' << *property_ << ']';
}

void CYStatement::Multiple(CYOutput &out, CYFlags flags) const {
    bool first(true);
    CYForEach (next, this) {
        bool last(next->next_ == NULL);
        CYFlags jacks(first ? last ? flags : CYLeft(flags) : last ? CYRight(flags) : CYCenter(flags));
        first = false;
        out << '\t';
        next->Output(out, jacks);
        out << '\n';
    }
}

#ifdef __clang__
# pragma clang diagnostic push
# pragma clang diagnostic ignored "-Wtautological-undefined-compare"
#endif

void CYStatement::Single(CYOutput &out, CYFlags flags, CYCompactType request) const {
    if (this == NULL)
        return out.Terminate();

    _assert(next_ == NULL);

    CYCompactType compact(Compact());

    if (compact >= request)
        out << ' ';
    else {
        out << '\n';
        ++out.indent_;
        out << '\t';
    }

    Output(out, flags);

    if (compact < request)
        --out.indent_;
}

#ifdef __clang__
# pragma clang diagnostic pop
#endif

void CYString::Output(CYOutput &out, CYFlags flags) const {
    std::ostringstream str;
    CYStringify(str, value_, size_, CYStringifyModeLegacy);
    out << str.str().c_str();
}

void CYString::PropertyName(CYOutput &out) const {
    if (const char *word = Word())
        out << word;
    else
        out << *this;
}

static const char *Reserved_[] = {
    "false", "null", "true",

    "break", "case", "catch", "continue", "default",
    "delete", "do", "else", "finally", "for", "function",
    "if", "in", "instanceof", "new", "return", "switch",
    "this", "throw", "try", "typeof", "var", "void",
    "while", "with",

    "debugger", "const",

    "class", "enum", "export", "extends", "import", "super",

    "abstract", "boolean", "byte", "char", "double", "final",
    "float", "goto", "int", "long", "native", "short",
    "synchronized", "throws", "transient", "volatile",

    "let", "yield",

    NULL
};

const char *CYString::Word() const {
    if (size_ == 0 || !WordStartRange_[value_[0]])
        return NULL;
    for (size_t i(1); i != size_; ++i)
        if (!WordEndRange_[value_[i]])
            return NULL;
    const char *value(Value());
    for (const char **reserved(Reserved_); *reserved != NULL; ++reserved)
        if (strcmp(*reserved, value) == 0)
            return NULL;
    return value;
}

void CYStructDefinition::Output(CYOutput &out, CYFlags flags) const {
    out << "struct" << ' ' << *name_ << *tail_;
}

void CYStructTail::Output(CYOutput &out) const {
    out << ' ' << '{' << '\n';
    ++out.indent_;
    CYForEach (field, fields_) {
        out << '\t';
        field->type_->Output(out, field->name_);
        out.Terminate();
        out << '\n';
    }
    --out.indent_;
    out << '\t' << '}';
}

void CYSuperAccess::Output(CYOutput &out, CYFlags flags) const {
    out << "super";
    if (const char *word = property_->Word())
        out << '.' << word;
    else
        out << '[' << *property_ << ']';
}

void CYSuperCall::Output(CYOutput &out, CYFlags flags) const {
    out << "super" << '(' << arguments_ << ')';
}

void CYSwitch::Output(CYOutput &out, CYFlags flags) const {
    out << "switch" << ' ' << '(' << *value_ << ')' << ' ' << '{' << '\n';
    ++out.indent_;
    out << clauses_;
    --out.indent_;
    out << '\t' << '}';
}

void CYSymbol::Output(CYOutput &out, CYFlags flags) const {
    bool protect((flags & CYNoColon) != 0);
    if (protect)
        out << '(';
    out << ':' << name_;
    if (protect)
        out << ')';
}

void CYThis::Output(CYOutput &out, CYFlags flags) const {
    out << "this";
}

namespace cy {
namespace Syntax {

void Throw::Output(CYOutput &out, CYFlags flags) const {
    out << "throw";
    if (value_ != NULL)
        out << ' ' << *value_;
    out << ';';
}

void Try::Output(CYOutput &out, CYFlags flags) const {
    out << "try" << ' ';
    out << '{' << '\n';
    ++out.indent_;
    out << code_;
    --out.indent_;
    out << '\t' << '}';
    out << catch_ << finally_;
}

} }

void CYTypeCharacter::Output(CYOutput &out) const {
    switch (signing_) {
        case CYTypeNeutral: break;
        case CYTypeSigned: out << "signed" << ' '; break;
        case CYTypeUnsigned: out << "unsigned" << ' '; break;
    }

    out << "char";
}

void CYTypeEnum::Output(CYOutput &out) const {
    out << "enum" << ' ';
    if (name_ != NULL)
        out << *name_;
    else {
        if (specifier_ != NULL)
            out << ':' << ' ' << *specifier_ << ' ';

        out << '{' << '\n';
        ++out.indent_;
        bool comma(false);

        CYForEach (constant, constants_) {
            if (comma)
                out << ',' << '\n';
            else
                comma = true;
            out << '\t' << constant->name_;
            out << ' ' << '=' << ' ' << constant->value_;
        }

        if (out.pretty_)
            out << ',';
        out << '\n';
        --out.indent_;
        out << '\t' << '}';
    }
}

void CYTypeError::Output(CYOutput &out) const {
    out << "@error";
}

void CYTypeFloating::Output(CYOutput &out) const {
    switch (length_) {
        case 0: out << "float"; break;
        case 1: out << "double"; break;
        case 2: out << "long" << ' ' << "double"; break;
        default: _assert(false);
    }
}

void CYTypeInt128::Output(CYOutput &out) const {
    switch (signing_) {
        case CYTypeNeutral: break;
        case CYTypeSigned: out << "signed" << ' '; break;
        case CYTypeUnsigned: out << "unsigned" << ' '; break;
    }

    out << "__int128";
}

void CYTypeIntegral::Output(CYOutput &out) const {
    if (signing_ == CYTypeUnsigned)
        out << "unsigned" << ' ';
    switch (length_) {
        case 0: out << "short"; break;
        case 1: out << "int"; break;
        case 2: out << "long"; break;
        case 3: out << "long" << ' ' << "long"; break;
        default: _assert(false);
    }
}

void CYTypeStruct::Output(CYOutput &out) const {
    out << "struct";
    if (name_ != NULL)
        out << ' ' << *name_;
    else
        out << *tail_;
}

void CYTypeReference::Output(CYOutput &out) const {
    switch (kind_) {
        case CYTypeReferenceStruct: out << "struct"; break;
        case CYTypeReferenceEnum: out << "enum"; break;
        default: _assert(false);
    }

    out << ' ' << *name_;
}

void CYTypeVariable::Output(CYOutput &out) const {
    out << *name_;
}

void CYTypeVoid::Output(CYOutput &out) const {
    out << "void";
}

void CYVar::Output(CYOutput &out, CYFlags flags) const {
    out << "var" << ' ';
    bindings_->Output(out, flags); // XXX: flags
    out << ';';
}

void CYVariable::Output(CYOutput &out, CYFlags flags) const {
    out << *name_;
}

void CYWhile::Output(CYOutput &out, CYFlags flags) const {
    out << "while" << ' ' << '(' << *test_ << ')';
    code_->Single(out, CYRight(flags), CYCompactShort);
}

void CYWith::Output(CYOutput &out, CYFlags flags) const {
    out << "with" << ' ' << '(' << *scope_ << ')';
    code_->Single(out, CYRight(flags), CYCompactShort);
}

void CYWord::Output(CYOutput &out) const {
    out << Word();
    if (out.options_.verbose_) {
        out('@');
        char number[32];
        sprintf(number, "%p", this);
        out(number);
    }
}

void CYWord::PropertyName(CYOutput &out) const {
    Output(out);
}

const char *CYWord::Word() const {
    return word_;
}
