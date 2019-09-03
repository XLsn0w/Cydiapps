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

#ifndef CYCRIPT_SYNTAX_HPP
#define CYCRIPT_SYNTAX_HPP

#include <cstdio>
#include <cstdlib>

#include <streambuf>
#include <string>
#include <vector>

#include "List.hpp"
#include "Location.hpp"
#include "Options.hpp"
#include "Pooling.hpp"
#include "String.hpp"

#ifdef __clang__
# pragma clang diagnostic push
# pragma clang diagnostic ignored "-Winconsistent-missing-override"
# pragma clang diagnostic ignored "-Woverloaded-virtual"
#endif

double CYCastDouble(const char *value, size_t size);
double CYCastDouble(const char *value);
double CYCastDouble(CYUTF8String value);

void CYNumerify(std::ostringstream &str, double value);

enum CYStringifyMode {
    CYStringifyModeLegacy,
    CYStringifyModeCycript,
    CYStringifyModeNative,
};

void CYStringify(std::ostringstream &str, const char *data, size_t size, CYStringifyMode mode);

// XXX: this really should not be here ... :/
void *CYPoolFile(CYPool &pool, const char *path, size_t *psize);
CYUTF8String CYPoolFileUTF8String(CYPool &pool, const char *path);

struct CYContext;

struct CYThing {
    virtual void Output(struct CYOutput &out) const = 0;
};

struct CYOutput {
    std::streambuf &out_;
    CYPosition position_;

    CYOptions &options_;
    bool pretty_;
    unsigned indent_;
    unsigned recent_;
    bool right_;

    enum {
        NoMode,
        NoLetter,
        NoPlus,
        NoHyphen,
        Terminated
    } mode_;

    CYOutput(std::streambuf &out, CYOptions &options) :
        out_(out),
        options_(options),
        pretty_(false),
        indent_(0),
        recent_(0),
        right_(false),
        mode_(NoMode)
    {
    }

    void Check(char value);
    void Terminate();

    _finline void operator ()(char value) {
        _assert(out_.sputc(value) != EOF);
        recent_ = indent_;
        if (value == '\n')
            position_.Lines(1);
        else
            position_.Columns(1);
    }

    _finline void operator ()(const char *data, std::streamsize size) {
        _assert(out_.sputn(data, size) == size);
        recent_ = indent_;
        position_.Columns(static_cast<unsigned>(size));
    }

    _finline void operator ()(const char *data) {
        return operator ()(data, strlen(data));
    }

    CYOutput &operator <<(char rhs);
    CYOutput &operator <<(const char *rhs);

    _finline CYOutput &operator <<(const CYThing *rhs) {
        if (rhs != NULL)
            rhs->Output(*this);
        return *this;
    }

    _finline CYOutput &operator <<(const CYThing &rhs) {
        rhs.Output(*this);
        return *this;
    }
};

struct CYExpression;
struct CYAssignment;
struct CYIdentifier;
struct CYNumber;

struct CYPropertyName {
    virtual bool Computed() const {
        return false;
    }

    virtual bool Constructor() const {
        return false;
    }

    virtual CYIdentifier *Identifier() {
        return NULL;
    }

    virtual CYNumber *Number(CYContext &context) {
        return NULL;
    }

    virtual CYExpression *PropertyName(CYContext &context) = 0;
    virtual void PropertyName(CYOutput &out) const = 0;
};

enum CYNeeded {
    CYNever     = -1,
    CYSometimes =  0,
    CYAlways    =  1,
};

enum CYFlags {
    CYNoFlags =      0,
    CYNoBrace =      (1 << 0),
    CYNoFunction =   (1 << 1),
    CYNoClass =      (1 << 2),
    CYNoIn =         (1 << 3),
    CYNoCall =       (1 << 4),
    CYNoRightHand =  (1 << 5),
    CYNoDangle =     (1 << 6),
    CYNoInteger =    (1 << 7),
    CYNoColon =      (1 << 8),
    CYNoBFC =        (CYNoBrace | CYNoFunction | CYNoClass),
};

_finline CYFlags operator ~(CYFlags rhs) {
    return static_cast<CYFlags>(~static_cast<unsigned>(rhs));
}

_finline CYFlags operator &(CYFlags lhs, CYFlags rhs) {
    return static_cast<CYFlags>(static_cast<unsigned>(lhs) & static_cast<unsigned>(rhs));
}

_finline CYFlags operator |(CYFlags lhs, CYFlags rhs) {
    return static_cast<CYFlags>(static_cast<unsigned>(lhs) | static_cast<unsigned>(rhs));
}

_finline CYFlags &operator |=(CYFlags &lhs, CYFlags rhs) {
    return lhs = lhs | rhs;
}

_finline CYFlags CYLeft(CYFlags flags) {
    return flags & ~(CYNoDangle | CYNoInteger);
}

_finline CYFlags CYRight(CYFlags flags) {
    return flags & ~CYNoBFC;
}

_finline CYFlags CYCenter(CYFlags flags) {
    return CYLeft(CYRight(flags));
}

enum CYCompactType {
    CYCompactNone,
    CYCompactLong,
    CYCompactShort,
};

#define CYCompact(type) \
    virtual CYCompactType Compact() const { \
        return CYCompact ## type; \
    }

struct CYStatement :
    CYNext<CYStatement>,
    CYThing
{
    void Single(CYOutput &out, CYFlags flags, CYCompactType request) const;
    void Multiple(CYOutput &out, CYFlags flags = CYNoFlags) const;
    virtual void Output(CYOutput &out) const;

    virtual CYStatement *Replace(CYContext &context) = 0;

    virtual CYCompactType Compact() const = 0;
    virtual CYStatement *Return();

  private:
    virtual void Output(CYOutput &out, CYFlags flags) const = 0;
};

typedef CYList<CYStatement> CYStatements;

struct CYForInitializer :
    CYStatement
{
    virtual CYForInitializer *Replace(CYContext &context) = 0;
    virtual void Output(CYOutput &out, CYFlags flags) const = 0;
};

struct CYWord :
    CYThing,
    CYPropertyName
{
    const char *word_;

    CYWord(const char *word) :
        word_(word)
    {
    }

    virtual bool Constructor() const {
        return strcmp(word_, "constructor") == 0;
    }

    virtual const char *Word() const;
    virtual void Output(CYOutput &out) const;

    virtual CYExpression *PropertyName(CYContext &context);
    virtual void PropertyName(CYOutput &out) const;
};

_finline std::ostream &operator <<(std::ostream &lhs, const CYWord &rhs) {
    lhs << &rhs << '=';
    return lhs << rhs.Word();
}

enum CYIdentifierKind {
    CYIdentifierArgument,
    CYIdentifierCatch,
    CYIdentifierGlobal,
    CYIdentifierLexical,
    CYIdentifierMagic,
    CYIdentifierOther,
    CYIdentifierVariable,
};

struct CYIdentifier :
    CYNext<CYIdentifier>,
    CYWord
{
    CYLocation location_;
    size_t offset_;
    size_t usage_;

    CYIdentifier(const char *word) :
        CYWord(word),
        offset_(0),
        usage_(0)
    {
    }

    CYIdentifier *Identifier() override {
        return this;
    }

    virtual const char *Word() const;
    CYIdentifier *Replace(CYContext &context, CYIdentifierKind);
};

struct CYLabel :
    CYStatement
{
    CYIdentifier *name_;
    CYStatement *statement_;

    CYLabel(CYIdentifier *name, CYStatement *statement) :
        name_(name),
        statement_(statement)
    {
    }

    CYCompact(Short)

    virtual CYStatement *Replace(CYContext &context);
    virtual void Output(CYOutput &out, CYFlags flags) const;
};

struct CYCStringLess :
    std::binary_function<const char *, const char *, bool>
{
    _finline bool operator ()(const char *lhs, const char *rhs) const {
        return strcmp(lhs, rhs) < 0;
    }
};

struct CYIdentifierValueLess :
    std::binary_function<CYIdentifier *, CYIdentifier *, bool>
{
    _finline bool operator ()(CYIdentifier *lhs, CYIdentifier *rhs) const {
        return CYCStringLess()(lhs->Word(), rhs->Word());
    }
};

struct CYIdentifierFlags :
    CYNext<CYIdentifierFlags>
{
    CYIdentifier *identifier_;
    CYIdentifierKind kind_;
    unsigned count_;
    unsigned offset_;

    CYIdentifierFlags(CYIdentifier *identifier, CYIdentifierKind kind, CYIdentifierFlags *next = NULL) :
        CYNext<CYIdentifierFlags>(next),
        identifier_(identifier),
        kind_(kind),
        count_(0),
        offset_(0)
    {
    }
};

struct CYScope {
    bool transparent_;
    CYScope *parent_;
    bool damaged_;
    CYIdentifierFlags *shadow_;

    CYIdentifierFlags *internal_;

    CYScope(bool transparent, CYContext &context);

    CYIdentifierFlags *Lookup(CYContext &context, const char *word);
    CYIdentifierFlags *Lookup(CYContext &context, CYIdentifier *identifier);

    CYIdentifierFlags *Declare(CYContext &context, CYIdentifier *identifier, CYIdentifierKind kind);
    void Merge(CYContext &context, const CYIdentifierFlags *flags);

    void Close(CYContext &context, CYStatement *&statements);
    void Close(CYContext &context);
    void Damage();
};

struct CYScript :
    CYThing
{
    CYStatement *code_;

    CYScript(CYStatement *code) :
        code_(code)
    {
    }

    virtual void Replace(CYContext &context);
    virtual void Output(CYOutput &out) const;
};

struct CYNonLocal;
struct CYThisScope;

struct CYContext {
    CYOptions &options_;

    CYScope *scope_;
    CYThisScope *this_;
    CYIdentifier *super_;

    CYNonLocal *nonlocal_;
    CYNonLocal *nextlocal_;
    unsigned unique_;

    std::vector<CYIdentifier *> replace_;

    CYContext(CYOptions &options) :
        options_(options),
        scope_(NULL),
        this_(NULL),
        super_(NULL),
        nonlocal_(NULL),
        nextlocal_(NULL),
        unique_(0)
    {
    }

    void ReplaceAll(CYStatement *&statement) {
        if (statement == NULL)
            return;
        CYStatement *next(statement->next_);

        Replace(statement);
        ReplaceAll(next);

        if (statement == NULL)
            statement = next;
        else
            statement->SetNext(next);
    }

    template <typename Type_>
    void Replace(Type_ *&value) {
        for (;;) if (value == NULL)
            break;
        else {
            Type_ *replace(value->Replace(*this));
            if (replace != value)
                value = replace;
            else break;
        }
    }

    void NonLocal(CYStatement *&statements);
    CYIdentifier *Unique();
};

struct CYNonLocal {
    CYIdentifier *identifier_;

    CYNonLocal() :
        identifier_(NULL)
    {
    }

    CYIdentifier *Target(CYContext &context) {
        if (identifier_ == NULL)
            identifier_ = context.Unique();
        return identifier_;
    }
};

struct CYThisScope :
    CYNext<CYThisScope>
{
    CYIdentifier *identifier_;

    CYThisScope() :
        identifier_(NULL)
    {
    }

    CYIdentifier *Identifier(CYContext &context) {
        if (next_ != NULL)
            return next_->Identifier(context);
        if (identifier_ == NULL)
            identifier_ = context.Unique();
        return identifier_;
    }
};

struct CYBlock :
    CYStatement
{
    CYStatement *code_;

    CYBlock(CYStatement *code) :
        code_(code)
    {
    }

    CYCompact(Short)

    virtual CYStatement *Replace(CYContext &context);

    virtual void Output(CYOutput &out, CYFlags flags) const;

    virtual CYStatement *Return();
};

struct CYTarget;
struct CYVar;

struct CYForInInitializer {
    virtual CYStatement *Initialize(CYContext &context, CYExpression *value) = 0;

    virtual CYTarget *Replace(CYContext &context) = 0;
    virtual void Output(CYOutput &out, CYFlags flags) const = 0;
};

struct CYFunctionParameter;

struct CYNumber;
struct CYString;

struct CYExpression :
    CYThing
{
    virtual int Precedence() const = 0;

    virtual bool RightHand() const {
        return true;
    }

    virtual bool Eval() const {
        return false;
    }

    virtual CYTarget *AddArgument(CYContext &context, CYExpression *value);

    virtual void Output(CYOutput &out) const;
    virtual void Output(CYOutput &out, CYFlags flags) const = 0;
    void Output(CYOutput &out, int precedence, CYFlags flags) const;

    virtual CYExpression *Replace(CYContext &context) = 0;

    virtual CYExpression *Primitive(CYContext &context) {
        return NULL;
    }

    virtual CYFunctionParameter *Parameter() const;

    virtual CYNumber *Number(CYContext &context) {
        return NULL;
    }

    virtual CYString *String(CYContext &context) {
        return NULL;
    }

    virtual const char *Word() const {
        return NULL;
    }
};

struct CYTarget :
    CYExpression,
    CYForInInitializer
{
    virtual bool RightHand() const {
        return false;
    }

    virtual bool IsNew() const {
        return false;
    }

    virtual CYStatement *Initialize(CYContext &context, CYExpression *value);

    virtual CYTarget *Replace(CYContext &context) = 0;
    using CYExpression::Output;
};

#define CYAlphabetic(value) \
    virtual bool Alphabetic() const { \
        return value; \
    }

#define CYPrecedence(value) \
    static const int Precedence_ = value; \
    virtual int Precedence() const { \
        return Precedence_; \
    }

struct CYCompound :
    CYExpression
{
    CYExpression *expression_;
    CYExpression *next_;

    CYCompound(CYExpression *expression, CYExpression *next) :
        expression_(expression),
        next_(next)
    {
        _assert(expression_ != NULL);
        _assert(next != NULL);
    }

    CYPrecedence(17)

    virtual CYExpression *Replace(CYContext &context);
    void Output(CYOutput &out, CYFlags flags) const;

    virtual CYFunctionParameter *Parameter() const;
};

struct CYParenthetical :
    CYTarget
{
    CYExpression *expression_;

    CYParenthetical(CYExpression *expression) :
        expression_(expression)
    {
    }

    CYPrecedence(0)

    virtual CYTarget *Replace(CYContext &context);
    void Output(CYOutput &out, CYFlags flags) const;
};

struct CYBinding;

struct CYFunctionParameter :
    CYNext<CYFunctionParameter>,
    CYThing
{
    CYBinding *binding_;

    CYFunctionParameter(CYBinding *binding, CYFunctionParameter *next = NULL) :
        CYNext<CYFunctionParameter>(next),
        binding_(binding)
    {
    }

    void Replace(CYContext &context, CYStatement *&statements);
    void Output(CYOutput &out) const;
};

struct CYComprehension :
    CYNext<CYComprehension>,
    CYThing
{
    CYComprehension(CYComprehension *next = NULL) :
        CYNext<CYComprehension>(next)
    {
    }

    virtual CYFunctionParameter *Parameter(CYContext &context) const = 0;
    CYFunctionParameter *Parameters(CYContext &context) const;
    virtual CYStatement *Replace(CYContext &context, CYStatement *statement) const;
    virtual void Output(CYOutput &out) const = 0;
};

struct CYForInComprehension :
    CYComprehension
{
    CYBinding *binding_;
    CYExpression *iterable_;

    CYForInComprehension(CYBinding *binding, CYExpression *iterable, CYComprehension *next = NULL) :
        CYComprehension(next),
        binding_(binding),
        iterable_(iterable)
    {
    }

    virtual CYFunctionParameter *Parameter(CYContext &context) const;
    virtual CYStatement *Replace(CYContext &context, CYStatement *statement) const;
    virtual void Output(CYOutput &out) const;
};

struct CYForOfComprehension :
    CYComprehension
{
    CYBinding *binding_;
    CYExpression *iterable_;

    CYForOfComprehension(CYBinding *binding, CYExpression *iterable, CYComprehension *next = NULL) :
        CYComprehension(next),
        binding_(binding),
        iterable_(iterable)
    {
    }

    virtual CYFunctionParameter *Parameter(CYContext &context) const;
    virtual CYStatement *Replace(CYContext &context, CYStatement *statement) const;
    virtual void Output(CYOutput &out) const;
};

struct CYIfComprehension :
    CYComprehension
{
    CYExpression *test_;

    CYIfComprehension(CYExpression *test, CYComprehension *next = NULL) :
        CYComprehension(next),
        test_(test)
    {
    }

    virtual CYFunctionParameter *Parameter(CYContext &context) const;
    virtual CYStatement *Replace(CYContext &context, CYStatement *statement) const;
    virtual void Output(CYOutput &out) const;
};

struct CYArrayComprehension :
    CYTarget
{
    CYExpression *expression_;
    CYComprehension *comprehensions_;

    CYArrayComprehension(CYExpression *expression, CYComprehension *comprehensions) :
        expression_(expression),
        comprehensions_(comprehensions)
    {
    }

    CYPrecedence(0)

    virtual CYTarget *Replace(CYContext &context);
    virtual void Output(CYOutput &out, CYFlags flags) const;
};

struct CYLiteral :
    CYTarget
{
    CYLocation location_;

    CYPrecedence(0)

    virtual CYExpression *Primitive(CYContext &context) {
        return this;
    }
};

struct CYTrivial :
    CYLiteral
{
    virtual CYTarget *Replace(CYContext &context);
};

struct CYMagic :
    CYTarget
{
    CYPrecedence(0)
};

struct CYRange {
    uint64_t lo_;
    uint64_t hi_;

    CYRange(uint64_t lo, uint64_t hi) :
        lo_(lo), hi_(hi)
    {
    }

    bool operator [](uint8_t value) const {
        return !(value >> 7) && (value >> 6 ? hi_ : lo_) >> (value & 0x3f) & 0x1;
    }

    void operator()(uint8_t value) {
        if (value >> 7)
            return;
        (value >> 6 ? hi_ : lo_) |= uint64_t(0x1) << (value & 0x3f);
    }
};

extern CYRange DigitRange_;
extern CYRange WordStartRange_;
extern CYRange WordEndRange_;

struct CYString :
    CYTrivial,
    CYPropertyName
{
    const char *value_;
    size_t size_;

    CYString() :
        value_(NULL),
        size_(0)
    {
    }

    CYString(const char *value) :
        value_(value),
        size_(strlen(value))
    {
    }

    CYString(const char *value, size_t size) :
        value_(value),
        size_(size)
    {
    }

    CYString(const CYWord *word) :
        value_(word->Word()),
        size_(strlen(value_))
    {
    }

    const char *Value() const {
        return value_;
    }

    virtual CYIdentifier *Identifier() const;
    virtual const char *Word() const;

    virtual CYNumber *Number(CYContext &context);
    virtual CYString *String(CYContext &context);

    CYString *Concat(CYContext &out, CYString *rhs) const;
    virtual void Output(CYOutput &out, CYFlags flags) const;

    virtual CYExpression *PropertyName(CYContext &context);
    virtual void PropertyName(CYOutput &out) const;
};

struct CYElementValue;

struct CYSpan :
    CYNext<CYSpan>
{
    CYExpression *expression_;
    CYString *string_;

    CYSpan(CYExpression *expression, CYString *string, CYSpan *next) :
        CYNext<CYSpan>(next),
        expression_(expression),
        string_(string)
    {
    }

    CYElementValue *Replace(CYContext &context);
};

struct CYTemplate :
    CYTarget
{
    CYString *string_;
    CYSpan *spans_;

    CYTemplate(CYString *string, CYSpan *spans) :
        string_(string),
        spans_(spans)
    {
    }

    CYPrecedence(0)

    virtual CYString *String(CYContext &context);

    virtual CYTarget *Replace(CYContext &context);
    virtual void Output(CYOutput &out, CYFlags flags) const;
};

struct CYNumber :
    CYTrivial,
    CYPropertyName
{
    double value_;

    CYNumber(double value) :
        value_(value)
    {
    }

    double Value() const {
        return value_;
    }

    virtual CYNumber *Number(CYContext &context);
    virtual CYString *String(CYContext &context);

    virtual void Output(CYOutput &out, CYFlags flags) const;

    virtual CYExpression *PropertyName(CYContext &context);
    virtual void PropertyName(CYOutput &out) const;
};

struct CYComputed :
    CYPropertyName
{
    CYExpression *expression_;

    CYComputed(CYExpression *expression) :
        expression_(expression)
    {
    }

    virtual bool Computed() const {
        return true;
    }

    virtual CYExpression *PropertyName(CYContext &context);
    virtual void PropertyName(CYOutput &out) const;
};

struct CYRegEx :
    CYTrivial
{
    const char *value_;
    size_t size_;

    CYRegEx(const char *value, size_t size) :
        value_(value),
        size_(size)
    {
    }

    const char *Value() const {
        return value_;
    }

    virtual void Output(CYOutput &out, CYFlags flags) const;
};

struct CYNull :
    CYTrivial
{
    virtual CYNumber *Number(CYContext &context);
    virtual CYString *String(CYContext &context);

    virtual void Output(CYOutput &out, CYFlags flags) const;
};

struct CYThis :
    CYMagic
{
    virtual CYTarget *Replace(CYContext &context);
    virtual void Output(CYOutput &out, CYFlags flags) const;
};

struct CYBoolean :
    CYTrivial
{
    CYPrecedence(4)

    virtual bool RightHand() const {
        return true;
    }

    virtual bool Value() const = 0;
    virtual void Output(CYOutput &out, CYFlags flags) const;
};

struct CYFalse :
    CYBoolean
{
    virtual bool Value() const {
        return false;
    }

    virtual CYNumber *Number(CYContext &context);
    virtual CYString *String(CYContext &context);
};

struct CYTrue :
    CYBoolean
{
    virtual bool Value() const {
        return true;
    }

    virtual CYNumber *Number(CYContext &context);
    virtual CYString *String(CYContext &context);
};

struct CYVariable :
    CYTarget
{
    CYIdentifier *name_;

    CYVariable(CYIdentifier *name) :
        name_(name)
    {
    }

    CYVariable(const char *name) :
        name_(new($pool) CYIdentifier(name))
    {
    }

    CYPrecedence(0)

    virtual bool Eval() const {
        return strcmp(name_->Word(), "eval") == 0;
    }

    virtual CYTarget *Replace(CYContext &context);
    virtual void Output(CYOutput &out, CYFlags flags) const;

    virtual CYFunctionParameter *Parameter() const;
};

struct CYSymbol :
    CYTarget
{
    const char *name_;

    CYSymbol(const char *name) :
        name_(name)
    {
    }

    CYPrecedence(0)

    virtual CYTarget *Replace(CYContext &context);
    virtual void Output(CYOutput &out, CYFlags flags) const;
};

struct CYPrefix :
    CYExpression
{
    CYExpression *rhs_;

    CYPrefix(CYExpression *rhs) :
        rhs_(rhs)
    {
    }

    virtual bool Alphabetic() const = 0;
    virtual const char *Operator() const = 0;

    CYPrecedence(4)

    virtual CYExpression *Replace(CYContext &context);
    virtual void Output(CYOutput &out, CYFlags flags) const;
};

struct CYInfix :
    CYExpression
{
    CYExpression *lhs_;
    CYExpression *rhs_;

    CYInfix(CYExpression *lhs, CYExpression *rhs) :
        lhs_(lhs),
        rhs_(rhs)
    {
    }

    void SetLeft(CYExpression *lhs) {
        lhs_ = lhs;
    }

    virtual bool Alphabetic() const = 0;
    virtual const char *Operator() const = 0;

    virtual CYExpression *Replace(CYContext &context);
    virtual void Output(CYOutput &out, CYFlags flags) const;
};

struct CYPostfix :
    CYExpression
{
    CYExpression *lhs_;

    CYPostfix(CYExpression *lhs) :
        lhs_(lhs)
    {
    }

    virtual const char *Operator() const = 0;

    CYPrecedence(3)

    virtual CYExpression *Replace(CYContext &context);
    virtual void Output(CYOutput &out, CYFlags flags) const;
};

struct CYAssignment :
    CYExpression
{
    CYTarget *lhs_;
    CYExpression *rhs_;

    CYAssignment(CYTarget *lhs, CYExpression *rhs) :
        lhs_(lhs),
        rhs_(rhs)
    {
    }

    void SetRight(CYExpression *rhs) {
        rhs_ = rhs;
    }

    virtual const char *Operator() const = 0;

    CYPrecedence(16)

    virtual CYExpression *Replace(CYContext &context);
    virtual void Output(CYOutput &out, CYFlags flags) const;
};

struct CYArgument :
    CYNext<CYArgument>,
    CYThing
{
    CYWord *name_;
    CYExpression *value_;

    CYArgument(CYExpression *value, CYArgument *next = NULL) :
        CYNext<CYArgument>(next),
        name_(NULL),
        value_(value)
    {
    }

    CYArgument(CYWord *name, CYExpression *value, CYArgument *next = NULL) :
        CYNext<CYArgument>(next),
        name_(name),
        value_(value)
    {
    }

    CYArgument *Replace(CYContext &context);
    void Output(CYOutput &out) const;
};

struct CYClause :
    CYThing,
    CYNext<CYClause>
{
    CYExpression *value_;
    CYStatement *code_;

    CYClause(CYExpression *value, CYStatement *code) :
        value_(value),
        code_(code)
    {
    }

    void Replace(CYContext &context);
    virtual void Output(CYOutput &out) const;
};

struct CYElement :
    CYNext<CYElement>,
    CYThing
{
    CYElement(CYElement *next) :
        CYNext<CYElement>(next)
    {
    }

    virtual bool Elision() const = 0;

    virtual void Replace(CYContext &context) = 0;
};

struct CYElementValue :
    CYElement
{
    CYExpression *value_;

    CYElementValue(CYExpression *value, CYElement *next = NULL) :
        CYElement(next),
        value_(value)
    {
    }

    virtual bool Elision() const {
        return value_ == NULL;
    }

    virtual void Replace(CYContext &context);
    virtual void Output(CYOutput &out) const;
};

struct CYElementSpread :
    CYElement
{
    CYExpression *value_;

    CYElementSpread(CYExpression *value, CYElement *next = NULL) :
        CYElement(next),
        value_(value)
    {
    }

    virtual bool Elision() const {
        return false;
    }

    virtual void Replace(CYContext &context);
    virtual void Output(CYOutput &out) const;
};

struct CYArray :
    CYLiteral
{
    CYElement *elements_;

    CYArray(CYElement *elements = NULL) :
        elements_(elements)
    {
    }

    virtual CYTarget *Replace(CYContext &context);
    virtual void Output(CYOutput &out, CYFlags flags) const;
};

struct CYBinding {
    CYIdentifier *identifier_;
    CYExpression *initializer_;

    CYBinding(CYIdentifier *identifier, CYExpression *initializer = NULL) :
        identifier_(identifier),
        initializer_(initializer)
    {
    }

    CYTarget *Target(CYContext &context);

    virtual CYAssignment *Replace(CYContext &context, CYIdentifierKind kind);
    virtual void Output(CYOutput &out, CYFlags flags) const;
};

struct CYForLexical :
    CYForInInitializer
{
    bool constant_;
    CYBinding *binding_;

    CYForLexical(bool constant, CYBinding *binding) :
        constant_(constant),
        binding_(binding)
    {
    }

    virtual CYStatement *Initialize(CYContext &context, CYExpression *value);

    virtual CYTarget *Replace(CYContext &context);
    virtual void Output(CYOutput &out, CYFlags flags) const;
};

struct CYForVariable :
    CYForInInitializer
{
    CYBinding *binding_;

    CYForVariable(CYBinding *binding) :
        binding_(binding)
    {
    }

    virtual CYStatement *Initialize(CYContext &context, CYExpression *value);

    virtual CYTarget *Replace(CYContext &context);
    virtual void Output(CYOutput &out, CYFlags flags) const;
};

struct CYBindings :
    CYNext<CYBindings>,
    CYThing
{
    CYBinding *binding_;

    CYBindings(CYBinding *binding, CYBindings *next = NULL) :
        CYNext<CYBindings>(next),
        binding_(binding)
    {
    }

    CYExpression *Replace(CYContext &context, CYIdentifierKind kind);

    CYArgument *Argument(CYContext &context);
    CYFunctionParameter *Parameter(CYContext &context);

    virtual void Output(CYOutput &out) const;
    virtual void Output(CYOutput &out, CYFlags flags) const;
};

struct CYVar :
    CYForInitializer
{
    CYBindings *bindings_;

    CYVar(CYBindings *bindings) :
        bindings_(bindings)
    {
    }

    CYCompact(None)

    virtual CYForInitializer *Replace(CYContext &context);
    virtual void Output(CYOutput &out, CYFlags flags) const;
};

struct CYLexical :
    CYForInitializer
{
    bool constant_;
    CYBindings *bindings_;

    CYLexical(bool constant, CYBindings *bindings) :
        constant_(constant),
        bindings_(bindings)
    {
    }

    CYCompact(None)

    virtual CYForInitializer *Replace(CYContext &context);
    virtual void Output(CYOutput &out, CYFlags flags) const;
};

struct CYBuilder {
    CYList<CYBindings> bindings_;
    CYList<CYStatement> statements_;

    operator bool() const {
        return statements_ != NULL;
    }
};

struct CYProperty :
    CYNext<CYProperty>,
    CYThing
{
    CYPropertyName *name_;

    CYProperty(CYPropertyName *name, CYProperty *next = NULL) :
        CYNext<CYProperty>(next),
        name_(name)
    {
    }

    virtual bool Update() const;

    CYProperty *ReplaceAll(CYContext &context, CYBuilder &builder, CYExpression *self, bool update);
    void Replace(CYContext &context, CYBuilder &builder, CYExpression *self, bool protect);

    virtual void Replace(CYContext &context, CYBuilder &builder, CYExpression *self, CYExpression *name, bool protect) = 0;

    virtual void Replace(CYContext &context) = 0;
    virtual void Output(CYOutput &out) const;
};

struct CYPropertyValue :
    CYProperty
{
    CYExpression *value_;

    CYPropertyValue(CYPropertyName *name, CYExpression *value, CYProperty *next = NULL) :
        CYProperty(name, next),
        value_(value)
    {
    }

    virtual void Replace(CYContext &context, CYBuilder &builder, CYExpression *self, CYExpression *name, bool protect);
    virtual void Replace(CYContext &context);
    virtual void Output(CYOutput &out) const;
};

struct CYFor :
    CYStatement
{
    CYForInitializer *initializer_;
    CYExpression *test_;
    CYExpression *increment_;
    CYStatement *code_;

    CYFor(CYForInitializer *initializer, CYExpression *test, CYExpression *increment, CYStatement *code) :
        initializer_(initializer),
        test_(test),
        increment_(increment),
        code_(code)
    {
    }

    CYCompact(Long)

    virtual CYStatement *Replace(CYContext &context);
    virtual void Output(CYOutput &out, CYFlags flags) const;
};

struct CYForIn :
    CYStatement
{
    CYForInInitializer *initializer_;
    CYExpression *iterable_;
    CYStatement *code_;

    CYForIn(CYForInInitializer *initializer, CYExpression *iterable, CYStatement *code) :
        initializer_(initializer),
        iterable_(iterable),
        code_(code)
    {
    }

    CYCompact(Long)

    virtual CYStatement *Replace(CYContext &context);
    virtual void Output(CYOutput &out, CYFlags flags) const;
};

struct CYForInitialized :
    CYStatement
{
    CYBinding *binding_;
    CYExpression *iterable_;
    CYStatement *code_;

    CYForInitialized(CYBinding *binding, CYExpression *iterable, CYStatement *code) :
        binding_(binding),
        iterable_(iterable),
        code_(code)
    {
    }

    CYCompact(Long)

    virtual CYStatement *Replace(CYContext &context);
    virtual void Output(CYOutput &out, CYFlags flags) const;
};

struct CYForOf :
    CYStatement
{
    CYForInInitializer *initializer_;
    CYExpression *iterable_;
    CYStatement *code_;

    CYForOf(CYForInInitializer *initializer, CYExpression *iterable, CYStatement *code) :
        initializer_(initializer),
        iterable_(iterable),
        code_(code)
    {
    }

    CYCompact(Long)

    virtual CYStatement *Replace(CYContext &context);
    virtual void Output(CYOutput &out, CYFlags flags) const;
};

struct CYObject :
    CYLiteral
{
    CYProperty *properties_;

    CYObject(CYProperty *properties = NULL) :
        properties_(properties)
    {
    }

    CYTarget *Replace(CYContext &context, CYTarget *seed);

    virtual CYTarget *Replace(CYContext &context);
    void Output(CYOutput &out, CYFlags flags) const;
};

struct CYMember :
    CYTarget
{
    CYExpression *object_;
    CYExpression *property_;

    CYMember(CYExpression *object, CYExpression *property) :
        object_(object),
        property_(property)
    {
    }

    void SetLeft(CYExpression *object) {
        object_ = object;
    }
};

struct CYDirectMember :
    CYMember
{
    CYDirectMember(CYExpression *object, CYExpression *property) :
        CYMember(object, property)
    {
    }

    CYPrecedence(1)

    virtual CYTarget *Replace(CYContext &context);
    virtual void Output(CYOutput &out, CYFlags flags) const;
};

struct CYAttemptMember :
    CYMember
{
    CYAttemptMember(CYExpression *object, CYExpression *property) :
        CYMember(object, property)
    {
    }

    CYPrecedence(1)

    virtual CYTarget *Replace(CYContext &context);
    virtual void Output(CYOutput &out, CYFlags flags) const;
};

struct CYIndirectMember :
    CYMember
{
    CYIndirectMember(CYExpression *object, CYExpression *property) :
        CYMember(object, property)
    {
    }

    CYPrecedence(1)

    virtual CYTarget *Replace(CYContext &context);
    virtual void Output(CYOutput &out, CYFlags flags) const;
};

struct CYResolveMember :
    CYMember
{
    CYResolveMember(CYExpression *object, CYExpression *property) :
        CYMember(object, property)
    {
    }

    CYPrecedence(1)

    virtual CYTarget *Replace(CYContext &context);
    virtual void Output(CYOutput &out, CYFlags flags) const;
};

struct CYSubscriptMember :
    CYMember
{
    CYSubscriptMember(CYExpression *object, CYExpression *property) :
        CYMember(object, property)
    {
    }

    CYPrecedence(1)

    virtual CYTarget *Replace(CYContext &context);
    virtual void Output(CYOutput &out, CYFlags flags) const;
};

namespace cy {
namespace Syntax {

struct New :
    CYTarget
{
    CYExpression *constructor_;
    CYArgument *arguments_;

    New(CYExpression *constructor, CYArgument *arguments = NULL) :
        constructor_(constructor),
        arguments_(arguments)
    {
    }

    virtual int Precedence() const {
        return arguments_ == NULL ? 2 : 1;
    }

    virtual bool IsNew() const {
        return true;
    }

    virtual CYTarget *Replace(CYContext &context);
    virtual void Output(CYOutput &out, CYFlags flags) const;

    virtual CYTarget *AddArgument(CYContext &context, CYExpression *value);
};

} }

struct CYApply :
    CYTarget
{
    CYArgument *arguments_;

    CYApply(CYArgument *arguments = NULL) :
        arguments_(arguments)
    {
    }

    CYPrecedence(1)

    virtual CYTarget *AddArgument(CYContext &context, CYExpression *value);
};

struct CYCall :
    CYApply
{
    CYExpression *function_;

    CYCall(CYExpression *function, CYArgument *arguments = NULL) :
        CYApply(arguments),
        function_(function)
    {
    }

    virtual void Output(CYOutput &out, CYFlags flags) const;
    virtual CYTarget *Replace(CYContext &context);
};

struct CYEval :
    CYApply
{
    CYEval(CYArgument *arguments) :
        CYApply(arguments)
    {
    }

    virtual void Output(CYOutput &out, CYFlags flags) const;
    virtual CYTarget *Replace(CYContext &context);
};

struct CYRubyProc;

struct CYBraced :
    CYTarget
{
    CYTarget *lhs_;

    CYBraced(CYTarget *lhs = NULL) :
        lhs_(lhs)
    {
    }

    CYPrecedence(1)

    void SetLeft(CYTarget *lhs) {
        lhs_ = lhs;
    }
};

struct CYRubyBlock :
    CYBraced
{
    CYRubyProc *proc_;

    CYRubyBlock(CYTarget *lhs, CYRubyProc *proc) :
        CYBraced(lhs),
        proc_(proc)
    {
    }

    virtual CYTarget *Replace(CYContext &context);
    virtual void Output(CYOutput &out, CYFlags flags) const;

    virtual CYTarget *AddArgument(CYContext &context, CYExpression *value);
};

struct CYExtend :
    CYBraced
{
    CYObject object_;

    CYExtend(CYTarget *lhs, CYProperty *properties = NULL) :
        CYBraced(lhs),
        object_(properties)
    {
    }

    virtual CYTarget *Replace(CYContext &context);
    virtual void Output(CYOutput &out, CYFlags flags) const;
};

struct CYIf :
    CYStatement
{
    CYExpression *test_;
    CYStatement *true_;
    CYStatement *false_;

    CYIf(CYExpression *test, CYStatement *_true, CYStatement *_false = NULL) :
        test_(test),
        true_(_true),
        false_(_false)
    {
    }

    CYCompact(Long)

    virtual CYStatement *Replace(CYContext &context);
    virtual void Output(CYOutput &out, CYFlags flags) const;

    virtual CYStatement *Return();
};

struct CYDoWhile :
    CYStatement
{
    CYExpression *test_;
    CYStatement *code_;

    CYDoWhile(CYExpression *test, CYStatement *code) :
        test_(test),
        code_(code)
    {
    }

    CYCompact(None)

    virtual CYStatement *Replace(CYContext &context);
    virtual void Output(CYOutput &out, CYFlags flags) const;
};

struct CYWhile :
    CYStatement
{
    CYExpression *test_;
    CYStatement *code_;

    CYWhile(CYExpression *test, CYStatement *code) :
        test_(test),
        code_(code)
    {
    }

    CYCompact(Long)

    virtual CYStatement *Replace(CYContext &context);
    virtual void Output(CYOutput &out, CYFlags flags) const;
};

struct CYFunction {
    CYFunctionParameter *parameters_;
    CYStatement *code_;

    CYNonLocal *nonlocal_;
    bool implicit_;
    CYThisScope this_;
    CYIdentifier *super_;

    CYFunction(CYFunctionParameter *parameters, CYStatement *code) :
        parameters_(parameters),
        code_(code),
        nonlocal_(NULL),
        implicit_(false),
        super_(NULL)
    {
    }

    void Replace(CYContext &context);
    void Output(CYOutput &out) const;
};

struct CYFunctionExpression :
    CYFunction,
    CYTarget
{
    CYIdentifier *name_;

    CYFunctionExpression(CYIdentifier *name, CYFunctionParameter *parameters, CYStatement *code) :
        CYFunction(parameters, code),
        name_(name)
    {
    }

    CYPrecedence(0)

    CYTarget *Replace(CYContext &context) override;
    virtual void Output(CYOutput &out, CYFlags flags) const;
};

struct CYFatArrow :
    CYFunction,
    CYExpression
{
    CYFatArrow(CYFunctionParameter *parameters, CYStatement *code) :
        CYFunction(parameters, code)
    {
    }

    CYPrecedence(0)

    CYExpression *Replace(CYContext &context) override;
    virtual void Output(CYOutput &out, CYFlags flags) const;
};

struct CYRubyProc :
    CYFunction,
    CYTarget
{
    CYRubyProc(CYFunctionParameter *parameters, CYStatement *code) :
        CYFunction(parameters, code)
    {
    }

    CYPrecedence(0)

    CYTarget *Replace(CYContext &context) override;
    virtual void Output(CYOutput &out, CYFlags flags) const;
};

struct CYFunctionStatement :
    CYFunction,
    CYStatement
{
    CYIdentifier *name_;

    CYFunctionStatement(CYIdentifier *name, CYFunctionParameter *parameters, CYStatement *code) :
        CYFunction(parameters, code),
        name_(name)
    {
    }

    CYCompact(None)

    CYStatement *Replace(CYContext &context) override;
    virtual void Output(CYOutput &out, CYFlags flags) const;
};

struct CYPropertyMethod;

struct CYMethod :
    CYFunction,
    CYProperty
{
    CYMethod(CYPropertyName *name, CYFunctionParameter *parameters, CYStatement *code, CYProperty *next = NULL) :
        CYFunction(parameters, code),
        CYProperty(name, next)
    {
    }

    virtual CYFunctionExpression *Constructor();

    using CYProperty::Replace;
    virtual void Replace(CYContext &context);
};

struct CYPropertyGetter :
    CYMethod
{
    CYPropertyGetter(CYPropertyName *name, CYStatement *code, CYProperty *next = NULL) :
        CYMethod(name, NULL, code, next)
    {
    }

    virtual void Replace(CYContext &context, CYBuilder &builder, CYExpression *self, CYExpression *name, bool protect);
    virtual void Output(CYOutput &out) const;
};

struct CYPropertySetter :
    CYMethod
{
    CYPropertySetter(CYPropertyName *name, CYFunctionParameter *parameters, CYStatement *code, CYProperty *next = NULL) :
        CYMethod(name, parameters, code, next)
    {
    }

    virtual void Replace(CYContext &context, CYBuilder &builder, CYExpression *self, CYExpression *name, bool protect);
    virtual void Output(CYOutput &out) const;
};

struct CYPropertyMethod :
    CYMethod
{
    CYPropertyMethod(CYPropertyName *name, CYFunctionParameter *parameters, CYStatement *code, CYProperty *next = NULL) :
        CYMethod(name, parameters, code, next)
    {
    }

    bool Update() const override;

    virtual CYFunctionExpression *Constructor();

    virtual void Replace(CYContext &context, CYBuilder &builder, CYExpression *self, CYExpression *name, bool protect);
    virtual void Output(CYOutput &out) const;
};

struct CYClassTail :
    CYThing
{
    CYExpression *extends_;

    CYFunctionExpression *constructor_;
    CYList<CYProperty> instance_;
    CYList<CYProperty> static_;

    CYClassTail(CYExpression *extends) :
        extends_(extends),
        constructor_(NULL)
    {
    }

    void Output(CYOutput &out) const;
};

struct CYClassExpression :
    CYTarget
{
    CYIdentifier *name_;
    CYClassTail *tail_;

    CYClassExpression(CYIdentifier *name, CYClassTail *tail) :
        name_(name),
        tail_(tail)
    {
    }

    CYPrecedence(0)

    CYTarget *Replace(CYContext &context) override;
    virtual void Output(CYOutput &out, CYFlags flags) const;
};

struct CYClassStatement :
    CYStatement
{
    CYIdentifier *name_;
    CYClassTail *tail_;

    CYClassStatement(CYIdentifier *name, CYClassTail *tail) :
        name_(name),
        tail_(tail)
    {
    }

    CYCompact(Long)

    CYStatement *Replace(CYContext &context) override;
    virtual void Output(CYOutput &out, CYFlags flags) const;
};

struct CYSuperCall :
    CYTarget
{
    CYArgument *arguments_;

    CYSuperCall(CYArgument *arguments) :
        arguments_(arguments)
    {
    }

    CYPrecedence(2)

    CYTarget *Replace(CYContext &context) override;
    virtual void Output(CYOutput &out, CYFlags flags) const;
};

struct CYSuperAccess :
    CYTarget
{
    CYExpression *property_;

    CYSuperAccess(CYExpression *property) :
        property_(property)
    {
    }

    CYPrecedence(1)

    CYTarget *Replace(CYContext &context) override;
    virtual void Output(CYOutput &out, CYFlags flags) const;
};

struct CYExpress :
    CYForInitializer
{
    CYExpression *expression_;

    CYExpress(CYExpression *expression) :
        expression_(expression)
    {
        if (expression_ == NULL)
            throw;
    }

    CYCompact(None)

    CYForInitializer *Replace(CYContext &context) override;
    virtual void Output(CYOutput &out, CYFlags flags) const;

    virtual CYStatement *Return();
};

struct CYContinue :
    CYStatement
{
    CYIdentifier *label_;

    CYContinue(CYIdentifier *label) :
        label_(label)
    {
    }

    CYCompact(Short)

    CYStatement *Replace(CYContext &context) override;
    virtual void Output(CYOutput &out, CYFlags flags) const;
};

struct CYBreak :
    CYStatement
{
    CYIdentifier *label_;

    CYBreak(CYIdentifier *label) :
        label_(label)
    {
    }

    CYCompact(Short)

    CYStatement *Replace(CYContext &context) override;
    virtual void Output(CYOutput &out, CYFlags flags) const;
};

struct CYReturn :
    CYStatement
{
    CYExpression *value_;

    CYReturn(CYExpression *value) :
        value_(value)
    {
    }

    CYCompact(None)

    CYStatement *Replace(CYContext &context) override;
    virtual void Output(CYOutput &out, CYFlags flags) const;
};

struct CYYieldGenerator :
    CYExpression
{
    CYExpression *value_;

    CYYieldGenerator(CYExpression *value) :
        value_(value)
    {
    }

    CYPrecedence(0)

    CYExpression *Replace(CYContext &context) override;
    virtual void Output(CYOutput &out, CYFlags flags) const;
};

struct CYYieldValue :
    CYExpression
{
    CYExpression *value_;

    CYYieldValue(CYExpression *value) :
        value_(value)
    {
    }

    CYPrecedence(0)

    virtual CYExpression *Replace(CYContext &context);
    virtual void Output(CYOutput &out, CYFlags flags) const;
};

struct CYEmpty :
    CYForInitializer
{
    CYCompact(Short)

    virtual CYForInitializer *Replace(CYContext &context);
    virtual void Output(CYOutput &out, CYFlags flags) const;
};

struct CYFinally :
    CYThing
{
    CYStatement *code_;

    CYFinally(CYStatement *code) :
        code_(code)
    {
    }

    void Replace(CYContext &context);
    virtual void Output(CYOutput &out) const;
};

struct CYTypeSpecifier :
    CYThing
{
    virtual CYTarget *Replace(CYContext &context) = 0;
};

struct CYTypeError :
    CYTypeSpecifier
{
    CYTypeError() {
    }

    virtual CYTarget *Replace(CYContext &context);
    virtual void Output(CYOutput &out) const;
};

enum CYTypeSigning {
    CYTypeNeutral,
    CYTypeSigned,
    CYTypeUnsigned,
};

struct CYTypeCharacter :
    CYTypeSpecifier
{
    CYTypeSigning signing_;

    CYTypeCharacter(CYTypeSigning signing) :
        signing_(signing)
    {
    }

    virtual CYTarget *Replace(CYContext &context);
    virtual void Output(CYOutput &out) const;
};

struct CYTypeInt128 :
    CYTypeSpecifier
{
    CYTypeSigning signing_;

    CYTypeInt128(CYTypeSigning signing) :
        signing_(signing)
    {
    }

    virtual CYTarget *Replace(CYContext &context);
    virtual void Output(CYOutput &out) const;
};

struct CYTypeIntegral :
    CYTypeSpecifier
{
    CYTypeSigning signing_;
    int length_;

    CYTypeIntegral(CYTypeSigning signing, int length = 1) :
        signing_(signing),
        length_(length)
    {
    }

    CYTypeIntegral *Long() {
        if (length_ != 1 && length_ != 2)
            return NULL;
        ++length_;
        return this;
    }

    CYTypeIntegral *Short() {
        if (length_ != 1)
            return NULL;
        --length_;
        return this;
    }

    CYTypeIntegral *Signed() {
        if (signing_ != CYTypeNeutral)
            return NULL;
        signing_ = CYTypeSigned;
        return this;
    }

    CYTypeIntegral *Unsigned() {
        if (signing_ != CYTypeNeutral)
            return NULL;
        signing_ = CYTypeUnsigned;
        return this;
    }

    virtual CYTarget *Replace(CYContext &context);
    virtual void Output(CYOutput &out) const;
};

struct CYTypeFloating :
    CYTypeSpecifier
{
    int length_;

    CYTypeFloating(int length) :
        length_(length)
    {
    }

    virtual CYTarget *Replace(CYContext &context);
    virtual void Output(CYOutput &out) const;
};

struct CYTypeVoid :
    CYTypeSpecifier
{
    CYTypeVoid() {
    }

    virtual CYTarget *Replace(CYContext &context);
    virtual void Output(CYOutput &out) const;
};

enum CYTypeReferenceKind {
    CYTypeReferenceStruct,
    CYTypeReferenceEnum,
};

struct CYTypeReference :
    CYTypeSpecifier
{
    CYTypeReferenceKind kind_;
    CYIdentifier *name_;

    CYTypeReference(CYTypeReferenceKind kind, CYIdentifier *name) :
        kind_(kind),
        name_(name)
    {
    }

    virtual CYTarget *Replace(CYContext &context);
    virtual void Output(CYOutput &out) const;
};

struct CYTypeVariable :
    CYTypeSpecifier
{
    CYIdentifier *name_;

    CYTypeVariable(CYIdentifier *name) :
        name_(name)
    {
    }

    CYTypeVariable(const char *name) :
        name_(new($pool) CYIdentifier(name))
    {
    }

    virtual CYTarget *Replace(CYContext &context);
    virtual void Output(CYOutput &out) const;
};

struct CYTypeFunctionWith;

struct CYTypeModifier :
    CYNext<CYTypeModifier>
{
    CYTypeModifier(CYTypeModifier *next) :
        CYNext<CYTypeModifier>(next)
    {
    }

    virtual int Precedence() const = 0;

    virtual CYTarget *Replace_(CYContext &context, CYTarget *type) = 0;
    CYTarget *Replace(CYContext &context, CYTarget *type);

    virtual void Output(CYOutput &out, CYPropertyName *name) const = 0;
    void Output(CYOutput &out, int precedence, CYPropertyName *name, bool space) const;

    virtual CYTypeFunctionWith *Function() { return NULL; }
};

struct CYTypeArrayOf :
    CYTypeModifier
{
    CYExpression *size_;

    CYTypeArrayOf(CYExpression *size, CYTypeModifier *next = NULL) :
        CYTypeModifier(next),
        size_(size)
    {
    }

    CYPrecedence(1)

    virtual CYTarget *Replace_(CYContext &context, CYTarget *type);
    void Output(CYOutput &out, CYPropertyName *name) const override;
};

struct CYTypeConstant :
    CYTypeModifier
{
    CYTypeConstant(CYTypeModifier *next = NULL) :
        CYTypeModifier(next)
    {
    }

    CYPrecedence(0)

    virtual CYTarget *Replace_(CYContext &context, CYTarget *type);
    void Output(CYOutput &out, CYPropertyName *name) const override;
};

struct CYTypePointerTo :
    CYTypeModifier
{
    CYTypePointerTo(CYTypeModifier *next = NULL) :
        CYTypeModifier(next)
    {
    }

    CYPrecedence(0)

    virtual CYTarget *Replace_(CYContext &context, CYTarget *type);
    void Output(CYOutput &out, CYPropertyName *name) const override;
};

struct CYTypeVolatile :
    CYTypeModifier
{
    CYTypeVolatile(CYTypeModifier *next = NULL) :
        CYTypeModifier(next)
    {
    }

    CYPrecedence(0)

    virtual CYTarget *Replace_(CYContext &context, CYTarget *type);
    void Output(CYOutput &out, CYPropertyName *name) const override;
};

struct CYType :
    CYThing
{
    CYTypeSpecifier *specifier_;
    CYTypeModifier *modifier_;

    CYType(CYTypeSpecifier *specifier = NULL, CYTypeModifier *modifier = NULL) :
        specifier_(specifier),
        modifier_(modifier)
    {
    }

    inline CYType *Modify(CYTypeModifier *modifier) {
        CYSetLast(modifier_) = modifier;
        return this;
    }

    void Output(CYOutput &out, CYPropertyName *name) const;

    virtual CYTarget *Replace(CYContext &context);
    virtual void Output(CYOutput &out) const;

    CYTypeFunctionWith *Function();
};

struct CYTypedLocation :
    CYType
{
    CYLocation location_;

    CYTypedLocation(const CYLocation &location) :
        location_(location)
    {
    }
};

struct CYTypedName :
    CYTypedLocation
{
    CYPropertyName *name_;

    CYTypedName(const CYLocation &location, CYPropertyName *name = NULL) :
        CYTypedLocation(location),
        name_(name)
    {
    }
};

struct CYEncodedType :
    CYTarget
{
    CYType *typed_;

    CYEncodedType(CYType *typed) :
        typed_(typed)
    {
    }

    CYPrecedence(1)

    virtual CYTarget *Replace(CYContext &context);
    virtual void Output(CYOutput &out, CYFlags flags) const;
};

struct CYTypedParameter :
    CYNext<CYTypedParameter>,
    CYThing
{
    CYType *type_;
    CYIdentifier *name_;

    CYTypedParameter(CYType *type, CYIdentifier *name, CYTypedParameter *next = NULL) :
        CYNext<CYTypedParameter>(next),
        type_(type),
        name_(name)
    {
    }

    CYArgument *Argument(CYContext &context);
    CYFunctionParameter *Parameters(CYContext &context);
    CYExpression *TypeSignature(CYContext &context, CYExpression *prefix);

    virtual void Output(CYOutput &out) const;
};

struct CYTypedFormal {
    bool variadic_;
    CYTypedParameter *parameters_;

    CYTypedFormal(bool variadic) :
        variadic_(variadic),
        parameters_(NULL)
    {
    }
};

struct CYLambda :
    CYTarget
{
    CYType *typed_;
    CYTypedParameter *parameters_;
    CYStatement *code_;

    CYLambda(CYType *typed, CYTypedParameter *parameters, CYStatement *code) :
        typed_(typed),
        parameters_(parameters),
        code_(code)
    {
    }

    CYPrecedence(1)

    virtual CYTarget *Replace(CYContext &context);
    virtual void Output(CYOutput &out, CYFlags flags) const;
};

struct CYModule :
    CYNext<CYModule>,
    CYThing
{
    CYWord *part_;

    CYModule(CYWord *part, CYModule *next = NULL) :
        CYNext<CYModule>(next),
        part_(part)
    {
    }

    CYString *Replace(CYContext &context, const char *separator) const;
    void Output(CYOutput &out) const;
};

struct CYImport :
    CYStatement
{
    CYModule *module_;

    CYImport(CYModule *module) :
        module_(module)
    {
    }

    CYCompact(None)

    virtual CYStatement *Replace(CYContext &context);
    virtual void Output(CYOutput &out, CYFlags flags) const;
};

struct CYImportSpecifier :
    CYNext<CYImportSpecifier>
{
    CYWord *name_;
    CYIdentifier *binding_;

    CYImportSpecifier(CYWord *name, CYIdentifier *binding) :
        name_(name),
        binding_(binding)
    {
    }

    CYStatement *Replace(CYContext &context, CYIdentifier *module);
};

struct CYImportDeclaration :
    CYStatement
{
    CYImportSpecifier *specifiers_;
    CYString *module_;

    CYImportDeclaration(CYImportSpecifier *specifiers, CYString *module) :
        specifiers_(specifiers),
        module_(module)
    {
    }

    CYCompact(None)

    virtual CYStatement *Replace(CYContext &context);
    virtual void Output(CYOutput &out, CYFlags flags) const;
};

struct CYExternalExpression :
    CYTarget
{
    CYString *abi_;
    CYType *type_;
    CYPropertyName *name_;

    CYExternalExpression(CYString *abi, CYType *type, CYPropertyName *name) :
        abi_(abi),
        type_(type),
        name_(name)
    {
    }

    CYPrecedence(0)

    virtual CYTarget *Replace(CYContext &context);
    virtual void Output(CYOutput &out, CYFlags flags) const;
};

struct CYExternalDefinition :
    CYStatement
{
    CYString *abi_;
    CYType *type_;
    CYIdentifier *name_;

    CYExternalDefinition(CYString *abi, CYType *type, CYIdentifier *name) :
        abi_(abi),
        type_(type),
        name_(name)
    {
    }

    CYCompact(None)

    virtual CYStatement *Replace(CYContext &context);
    virtual void Output(CYOutput &out, CYFlags flags) const;
};

struct CYTypeExpression :
    CYTarget
{
    CYType *typed_;

    CYTypeExpression(CYType *typed) :
        typed_(typed)
    {
    }

    CYPrecedence(0)

    virtual CYTarget *Replace(CYContext &context);
    virtual void Output(CYOutput &out, CYFlags flags) const;
};

struct CYTypeDefinition :
    CYStatement
{
    CYType *type_;
    CYIdentifier *name_;

    CYTypeDefinition(CYType *type, CYIdentifier *name) :
        type_(type),
        name_(name)
    {
    }

    CYCompact(None)

    virtual CYStatement *Replace(CYContext &context);
    virtual void Output(CYOutput &out, CYFlags flags) const;
};

struct CYTypeBlockWith :
    CYTypeModifier
{
    CYTypedParameter *parameters_;

    CYTypeBlockWith(CYTypedParameter *parameters, CYTypeModifier *next = NULL) :
        CYTypeModifier(next),
        parameters_(parameters)
    {
    }

    CYPrecedence(0)

    virtual CYTarget *Replace_(CYContext &context, CYTarget *type);
    void Output(CYOutput &out, CYPropertyName *name) const override;
};

struct CYTypeFunctionWith :
    CYTypeModifier
{
    bool variadic_;
    CYTypedParameter *parameters_;

    CYTypeFunctionWith(bool variadic, CYTypedParameter *parameters, CYTypeModifier *next = NULL) :
        CYTypeModifier(next),
        variadic_(variadic),
        parameters_(parameters)
    {
    }

    CYPrecedence(1)

    virtual CYTarget *Replace_(CYContext &context, CYTarget *type);
    void Output(CYOutput &out, CYPropertyName *name) const override;

    virtual CYTypeFunctionWith *Function() { return this; }
};

struct CYTypeStructField :
    CYNext<CYTypeStructField>
{
    CYType *type_;
    CYPropertyName *name_;

    CYTypeStructField(CYType *type, CYPropertyName *name, CYTypeStructField *next = NULL) :
        CYNext<CYTypeStructField>(next),
        type_(type),
        name_(name)
    {
    }
};

struct CYStructTail :
    CYThing
{
    CYTypeStructField *fields_;

    CYStructTail(CYTypeStructField *fields) :
        fields_(fields)
    {
    }

    CYTarget *Replace(CYContext &context);
    virtual void Output(CYOutput &out) const;
};

struct CYTypeStruct :
    CYTypeSpecifier
{
    CYIdentifier *name_;
    CYStructTail *tail_;

    CYTypeStruct(CYIdentifier *name, CYStructTail *tail) :
        name_(name),
        tail_(tail)
    {
    }

    virtual CYTarget *Replace(CYContext &context);
    virtual void Output(CYOutput &out) const;
};

struct CYStructDefinition :
    CYStatement
{
    CYIdentifier *name_;
    CYStructTail *tail_;

    CYStructDefinition(CYIdentifier *name, CYStructTail *tail) :
        name_(name),
        tail_(tail)
    {
    }

    CYCompact(None)

    virtual CYStatement *Replace(CYContext &context);
    virtual void Output(CYOutput &out, CYFlags flags) const;
};

struct CYEnumConstant :
    CYNext<CYEnumConstant>
{
    CYIdentifier *name_;
    CYNumber *value_;

    CYEnumConstant(CYIdentifier *name, CYNumber *value, CYEnumConstant *next = NULL) :
        CYNext<CYEnumConstant>(next),
        name_(name),
        value_(value)
    {
    }
};

struct CYTypeEnum :
    CYTypeSpecifier
{
    CYIdentifier *name_;
    CYTypeSpecifier *specifier_;
    CYEnumConstant *constants_;

    CYTypeEnum(CYIdentifier *name, CYTypeSpecifier *specifier, CYEnumConstant *constants) :
        name_(name),
        specifier_(specifier),
        constants_(constants)
    {
    }

    virtual CYTarget *Replace(CYContext &context);
    virtual void Output(CYOutput &out) const;
};

namespace cy {
namespace Syntax {

struct Catch :
    CYThing
{
    CYIdentifier *name_;
    CYStatement *code_;

    Catch(CYIdentifier *name, CYStatement *code) :
        name_(name),
        code_(code)
    {
    }

    void Replace(CYContext &context);
    virtual void Output(CYOutput &out) const;
};

struct Try :
    CYStatement
{
    CYStatement *code_;
    Catch *catch_;
    CYFinally *finally_;

    Try(CYStatement *code, Catch *_catch, CYFinally *finally) :
        code_(code),
        catch_(_catch),
        finally_(finally)
    {
    }

    CYCompact(Short)

    virtual CYStatement *Replace(CYContext &context);
    virtual void Output(CYOutput &out, CYFlags flags) const;
};

struct Throw :
    CYStatement
{
    CYExpression *value_;

    Throw(CYExpression *value = NULL) :
        value_(value)
    {
    }

    CYCompact(None)

    virtual CYStatement *Replace(CYContext &context);
    virtual void Output(CYOutput &out, CYFlags flags) const;
};

} }

struct CYWith :
    CYStatement
{
    CYExpression *scope_;
    CYStatement *code_;

    CYWith(CYExpression *scope, CYStatement *code) :
        scope_(scope),
        code_(code)
    {
    }

    CYCompact(Long)

    virtual CYStatement *Replace(CYContext &context);
    virtual void Output(CYOutput &out, CYFlags flags) const;
};

struct CYSwitch :
    CYStatement
{
    CYExpression *value_;
    CYClause *clauses_;

    CYSwitch(CYExpression *value, CYClause *clauses) :
        value_(value),
        clauses_(clauses)
    {
    }

    CYCompact(Long)

    virtual CYStatement *Replace(CYContext &context);
    virtual void Output(CYOutput &out, CYFlags flags) const;
};

struct CYDebugger :
    CYStatement
{
    CYDebugger()
    {
    }

    CYCompact(None)

    virtual CYStatement *Replace(CYContext &context);
    virtual void Output(CYOutput &out, CYFlags flags) const;
};

struct CYCondition :
    CYExpression
{
    CYExpression *test_;
    CYExpression *true_;
    CYExpression *false_;

    CYCondition(CYExpression *test, CYExpression *_true, CYExpression *_false) :
        test_(test),
        true_(_true),
        false_(_false)
    {
    }

    CYPrecedence(15)

    virtual CYExpression *Replace(CYContext &context);
    virtual void Output(CYOutput &out, CYFlags flags) const;
};

struct CYAddressOf :
    CYPrefix
{
    CYAddressOf(CYExpression *rhs) :
        CYPrefix(rhs)
    {
    }

    virtual const char *Operator() const {
        return "&";
    }

    CYAlphabetic(false)

    virtual CYExpression *Replace(CYContext &context);
};

struct CYIndirect :
    CYTarget
{
    CYExpression *rhs_;

    CYIndirect(CYExpression *rhs) :
        rhs_(rhs)
    {
    }

    // XXX: this should be checked
    CYPrecedence(2)

    virtual CYTarget *Replace(CYContext &context);
    virtual void Output(CYOutput &out, CYFlags flags) const;
};

#define CYReplace \
    virtual CYExpression *Replace(CYContext &context);

#define CYPostfix_(op, name, ...) \
    struct CY ## name : \
        CYPostfix \
    { __VA_ARGS__ \
        CY ## name(CYExpression *lhs) : \
            CYPostfix(lhs) \
        { \
        } \
    \
        virtual const char *Operator() const { \
            return op; \
        } \
    };

#define CYPrefix_(alphabetic, op, name, ...) \
    struct CY ## name : \
        CYPrefix \
    { __VA_ARGS__ \
        CY ## name(CYExpression *rhs) : \
            CYPrefix(rhs) \
        { \
        } \
    \
        CYAlphabetic(alphabetic) \
    \
        virtual const char *Operator() const { \
            return op; \
        } \
    };

#define CYInfix_(alphabetic, precedence, op, name, ...) \
    struct CY ## name : \
        CYInfix \
    { __VA_ARGS__ \
        CY ## name(CYExpression *lhs, CYExpression *rhs) : \
            CYInfix(lhs, rhs) \
        { \
        } \
    \
        CYAlphabetic(alphabetic) \
        CYPrecedence(precedence) \
    \
        virtual const char *Operator() const { \
            return op; \
        } \
    };

#define CYAssignment_(op, name, ...) \
    struct CY ## name ## Assign : \
        CYAssignment \
    { __VA_ARGS__ \
        CY ## name ## Assign(CYTarget *lhs, CYExpression *rhs) : \
            CYAssignment(lhs, rhs) \
        { \
        } \
    \
        virtual const char *Operator() const { \
            return op; \
        } \
    };

CYPostfix_("++", PostIncrement)
CYPostfix_("--", PostDecrement)

CYPrefix_(true, "delete", Delete)
CYPrefix_(true, "void", Void)
CYPrefix_(true, "typeof", TypeOf)
CYPrefix_(false, "++", PreIncrement)
CYPrefix_(false, "--", PreDecrement)
CYPrefix_(false, "+", Affirm)
CYPrefix_(false, "-", Negate)
CYPrefix_(false, "~", BitwiseNot)
CYPrefix_(false, "!", LogicalNot)

CYInfix_(false, 5, "*", Multiply, CYReplace)
CYInfix_(false, 5, "/", Divide)
CYInfix_(false, 5, "%", Modulus)
CYInfix_(false, 6, "+", Add, CYReplace)
CYInfix_(false, 6, "-", Subtract)
CYInfix_(false, 7, "<<", ShiftLeft)
CYInfix_(false, 7, ">>", ShiftRightSigned)
CYInfix_(false, 7, ">>>", ShiftRightUnsigned)
CYInfix_(false, 8, "<", Less)
CYInfix_(false, 8, ">", Greater)
CYInfix_(false, 8, "<=", LessOrEqual)
CYInfix_(false, 8, ">=", GreaterOrEqual)
CYInfix_(true, 8, "instanceof", InstanceOf)
CYInfix_(true, 8, "in", In)
CYInfix_(false, 9, "==", Equal)
CYInfix_(false, 9, "!=", NotEqual)
CYInfix_(false, 9, "===", Identical)
CYInfix_(false, 9, "!==", NotIdentical)
CYInfix_(false, 10, "&", BitwiseAnd)
CYInfix_(false, 11, "^", BitwiseXOr)
CYInfix_(false, 12, "|", BitwiseOr)
CYInfix_(false, 13, "&&", LogicalAnd)
CYInfix_(false, 14, "||", LogicalOr)

CYAssignment_("=", )
CYAssignment_("*=", Multiply)
CYAssignment_("/=", Divide)
CYAssignment_("%=", Modulus)
CYAssignment_("+=", Add)
CYAssignment_("-=", Subtract)
CYAssignment_("<<=", ShiftLeft)
CYAssignment_(">>=", ShiftRightSigned)
CYAssignment_(">>>=", ShiftRightUnsigned)
CYAssignment_("&=", BitwiseAnd)
CYAssignment_("^=", BitwiseXOr)
CYAssignment_("|=", BitwiseOr)

#ifdef __clang__
# pragma clang diagnostic pop
#endif

#endif/*CYCRIPT_PARSER_HPP*/
