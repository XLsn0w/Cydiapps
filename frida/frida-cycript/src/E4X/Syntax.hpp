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

#ifndef CYCRIPT_E4X_SYNTAX_HPP
#define CYCRIPT_E4X_SYNTAX_HPP

#include "Syntax.hpp"

struct CYDefaultXMLNamespace :
    CYStatement
{
    CYExpression *expression_;

    CYDefaultXMLNamespace(CYExpression *expression) :
        expression_(expression)
    {
    }

    virtual CYStatement *Replace(CYContext &context);
    virtual void Output(CYOutput &out, CYFlags flags) const;
};

struct CYPropertyIdentifier {
};

struct CYSelector
{
};

struct CYWildcard :
    CYPropertyIdentifier,
    CYSelector
{
    virtual CYExpression *Replace(CYContext &context);
    virtual void Output(CYOutput &out, CYFlags flags) const;
};

struct CYQualified :
    CYPropertyIdentifier
{
    CYSelector *namespace_;
    CYSelector *name_;

    CYQualified(CYSelector *_namespace, CYSelector *name) :
        namespace_(_namespace),
        name_(name)
    {
    }
};

struct CYPropertyVariable :
    CYExpression
{
    CYPropertyIdentifier *identifier_;

    CYPropertyVariable(CYPropertyIdentifier *identifier) :
        identifier_(identifier)
    {
    }

    CYPrecedence(0)

    virtual CYExpression *Replace(CYContext &context);
    virtual void Output(CYOutput &out, CYFlags flags) const;
};

struct CYAttribute :
    CYPropertyIdentifier
{
    CYQualified *identifier_;

    CYAttribute(CYQualified *identifier) :
        identifier_(identifier)
    {
    }
};

#endif/*CYCRIPT_E4X_SYNTAX_HPP*/
