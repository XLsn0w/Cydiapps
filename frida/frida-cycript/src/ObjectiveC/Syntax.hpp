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

#ifndef CYCRIPT_OBJECTIVEC_SYNTAX_HPP
#define CYCRIPT_OBJECTIVEC_SYNTAX_HPP

#include "../Syntax.hpp"

struct CYInstanceLiteral :
    CYTarget
{
    CYNumber *number_;

    CYInstanceLiteral(CYNumber *number) :
        number_(number)
    {
    }

    CYPrecedence(1)

    virtual CYTarget *Replace(CYContext &context);
    virtual void Output(CYOutput &out, CYFlags flags) const;
};

struct CYObjCBlock :
    CYTarget
{
    CYType *typed_;
    CYTypedParameter *parameters_;
    CYStatement *code_;

    CYObjCBlock(CYType *typed, CYTypedParameter *parameters, CYStatement *code) :
        typed_(typed),
        parameters_(parameters),
        code_(code)
    {
    }

    CYPrecedence(1)

    virtual CYTarget *Replace(CYContext &context);
    virtual void Output(CYOutput &out, CYFlags flags) const;
};

struct CYBox :
    CYTarget
{
    CYExpression *value_;

    CYBox(CYExpression *value) :
        value_(value)
    {
    }

    CYPrecedence(1)

    virtual CYTarget *Replace(CYContext &context);
    virtual void Output(CYOutput &out, CYFlags flags) const;
};

struct CYObjCArray :
    CYTarget
{
    CYElement *elements_;

    CYObjCArray(CYElement *elements = NULL) :
        elements_(elements)
    {
    }

    CYPrecedence(0)

    virtual CYTarget *Replace(CYContext &context);
    virtual void Output(CYOutput &out, CYFlags flags) const;
};

struct CYObjCKeyValue :
    CYNext<CYObjCKeyValue>
{
    CYExpression *key_;
    CYExpression *value_;

    CYObjCKeyValue(CYExpression *key, CYExpression *value, CYObjCKeyValue *next) :
        CYNext<CYObjCKeyValue>(next),
        key_(key),
        value_(value)
    {
    }
};

struct CYObjCDictionary :
    CYTarget
{
    CYObjCKeyValue *pairs_;

    CYObjCDictionary(CYObjCKeyValue *pairs) :
        pairs_(pairs)
    {
    }

    CYPrecedence(0)

    virtual CYTarget *Replace(CYContext &context);
    virtual void Output(CYOutput &out, CYFlags flags) const;
};

struct CYSelectorPart :
    CYNext<CYSelectorPart>,
    CYThing
{
    CYWord *name_;
    bool value_;

    CYSelectorPart(CYWord *name, bool value, CYSelectorPart *next = NULL) :
        CYNext<CYSelectorPart>(next),
        name_(name),
        value_(value)
    {
    }

    CYString *Replace(CYContext &context);
    virtual void Output(CYOutput &out) const;
};

struct CYSelector :
    CYLiteral
{
    CYSelectorPart *parts_;

    CYSelector(CYSelectorPart *parts) :
        parts_(parts)
    {
    }

    CYPrecedence(1)

    virtual CYTarget *Replace(CYContext &context);
    virtual void Output(CYOutput &out, CYFlags flags) const;
};

struct CYImplementationField :
    CYNext<CYImplementationField>
{
    CYType *type_;
    CYPropertyName *name_;

    CYImplementationField(CYType *type, CYPropertyName *name, CYImplementationField *next = NULL) :
        CYNext<CYImplementationField>(next),
        type_(type),
        name_(name)
    {
    }

    CYStatement *Replace(CYContext &context) const;
    void Output(CYOutput &out) const;
};

struct CYMessageParameter :
    CYNext<CYMessageParameter>
{
    CYWord *name_;
    CYType *type_;
    CYIdentifier *identifier_;

    CYMessageParameter(CYWord *name, CYType *type = NULL, CYIdentifier *identifier = NULL, CYMessageParameter *next = NULL) :
        CYNext<CYMessageParameter>(next),
        name_(name),
        type_(type),
        identifier_(identifier)
    {
    }

    CYFunctionParameter *Parameters(CYContext &context) const;
    CYSelector *Selector(CYContext &context) const;
    CYSelectorPart *SelectorPart(CYContext &context) const;
    CYExpression *TypeSignature(CYContext &context) const;
};

struct CYMessage :
    CYNext<CYMessage>
{
    bool instance_;
    CYType *type_;
    CYMessageParameter *parameters_;
    CYBlock code_;

    CYMessage(bool instance, CYType *type, CYMessageParameter *parameters, CYStatement *code) :
        instance_(instance),
        type_(type),
        parameters_(parameters),
        code_(code)
    {
    }

    CYStatement *Replace(CYContext &context, bool replace) const;
    void Output(CYOutput &out) const;

    CYExpression *TypeSignature(CYContext &context) const;
};

struct CYProtocol :
    CYNext<CYProtocol>,
    CYThing
{
    CYExpression *name_;

    CYProtocol(CYExpression *name, CYProtocol *next = NULL) :
        CYNext<CYProtocol>(next),
        name_(name)
    {
    }

    CYStatement *Replace(CYContext &context) const;
    void Output(CYOutput &out) const;
};

struct CYImplementation :
    CYStatement
{
    CYIdentifier *name_;
    CYExpression *extends_;
    CYProtocol *protocols_;
    CYImplementationField *fields_;
    CYMessage *messages_;

    CYImplementation(CYIdentifier *name, CYExpression *extends, CYProtocol *protocols, CYImplementationField *fields, CYMessage *messages) :
        name_(name),
        extends_(extends),
        protocols_(protocols),
        fields_(fields),
        messages_(messages)
    {
    }

    CYCompact(None)

    virtual CYStatement *Replace(CYContext &context);
    virtual void Output(CYOutput &out, CYFlags flags) const;
};

struct CYCategory :
    CYStatement
{
    CYIdentifier *name_;
    CYMessage *messages_;

    CYCategory(CYIdentifier *name, CYMessage *messages) :
        name_(name),
        messages_(messages)
    {
    }

    CYCompact(None)

    virtual CYStatement *Replace(CYContext &context);
    virtual void Output(CYOutput &out, CYFlags flags) const;
};

struct CYSend :
    CYTarget
{
    CYArgument *arguments_;

    CYSend(CYArgument *arguments) :
        arguments_(arguments)
    {
    }

    CYPrecedence(0)

    virtual void Output(CYOutput &out, CYFlags flags) const;
};

struct CYSendDirect :
    CYSend
{
    CYExpression *self_;

    CYSendDirect(CYExpression *self, CYArgument *arguments) :
        CYSend(arguments),
        self_(self)
    {
    }

    virtual CYTarget *Replace(CYContext &context);
    virtual void Output(CYOutput &out, CYFlags flags) const;
};

struct CYSendSuper :
    CYSend
{
    CYSendSuper(CYArgument *arguments) :
        CYSend(arguments)
    {
    }

    virtual CYTarget *Replace(CYContext &context);
    virtual void Output(CYOutput &out, CYFlags flags) const;
};

#endif/*CYCRIPT_OBJECTIVEC_SYNTAX_HPP*/
