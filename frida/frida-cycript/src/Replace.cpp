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

#include <iomanip>
#include <map>

#include "Replace.hpp"
#include "Syntax.hpp"

CYFunctionExpression *CYNonLocalize(CYContext &context, CYFunctionExpression *function) {
    function->nonlocal_ = context.nextlocal_;
    return function;
}

CYFunctionExpression *CYSuperize(CYContext &context, CYFunctionExpression *function) {
    function->super_ = context.super_;
    return function;
}

CYStatement *CYDefineProperty(CYExpression *object, CYExpression *name, bool configurable, bool enumerable, CYProperty *descriptor) {
    return $E($C3($M($V("Object"), $S("defineProperty")), object, name, $ CYObject(CYList<CYProperty>()
        ->* (configurable ? $ CYPropertyValue($S("configurable"), $ CYTrue()) : NULL)
        ->* (enumerable ? $ CYPropertyValue($S("enumerable"), $ CYTrue()) : NULL)
        ->* descriptor)));
}

static void CYImplicitReturn(CYStatement *&code) {
    if (CYStatement *&last = CYGetLast(code))
        last = last->Return();
}

CYExpression *CYAdd::Replace(CYContext &context) {
    CYInfix::Replace(context);

    CYString *lhs(dynamic_cast<CYString *>(lhs_));
    CYString *rhs(dynamic_cast<CYString *>(rhs_));

    if (lhs != NULL || rhs != NULL) {
        if (lhs == NULL) {
            lhs = lhs_->String(context);
            if (lhs == NULL)
                return this;
        } else if (rhs == NULL) {
            rhs = rhs_->String(context);
            if (rhs == NULL)
                return this;
        }

        return lhs->Concat(context, rhs);
    }

    if (CYNumber *lhn = lhs_->Number(context))
        if (CYNumber *rhn = rhs_->Number(context))
            return $D(lhn->Value() + rhn->Value());

    return this;
}

CYExpression *CYAddressOf::Replace(CYContext &context) {
    return $C0($M(rhs_, $S("$cya")));
}

CYTarget *CYApply::AddArgument(CYContext &context, CYExpression *value) {
    CYArgument **argument(&arguments_);
    while (*argument != NULL)
        argument = &(*argument)->next_;
    *argument = $ CYArgument(value);
    return this;
}

CYArgument *CYArgument::Replace(CYContext &context) { $T(NULL)
    context.Replace(value_);
    next_ = next_->Replace(context);

    if (value_ == NULL) {
        if (next_ == NULL)
            return NULL;
        else
            value_ = $U;
    }

    return this;
}

CYTarget *CYArray::Replace(CYContext &context) {
    CYForEach (element, elements_)
        element->Replace(context);
    return this;
}

CYTarget *CYArrayComprehension::Replace(CYContext &context) {
    CYIdentifier *cyv(context.Unique());

    return $C0($F(NULL, $P1($B(cyv), comprehensions_->Parameters(context)), $$
        ->* $E($ CYAssign($V(cyv), $ CYArray()))
        ->* comprehensions_->Replace(context, $E($C1($M($V(cyv), $S("push")), expression_)))
        ->* $ CYReturn($V(cyv))
    ));
}

CYExpression *CYAssignment::Replace(CYContext &context) {
    // XXX: this is a horrible hack but I'm a month over schedule :(
    if (CYSubscriptMember *subscript = dynamic_cast<CYSubscriptMember *>(lhs_))
        return $C2($M(subscript->object_, $S("$cys")), subscript->property_, rhs_);
    context.Replace(lhs_);
    context.Replace(rhs_);
    return this;
}

CYTarget *CYAttemptMember::Replace(CYContext &context) {
    CYIdentifier *value(context.Unique());

    return $C1($F(NULL, $P1($B(value)), $$
        ->* $ CYReturn($ CYCondition($V(value), $M($V(value), property_), $V(value)))
    ), object_);
}

CYStatement *CYBlock::Return() {
    CYImplicitReturn(code_);
    return this;
}

CYStatement *CYBlock::Replace(CYContext &context) {
    CYScope scope(true, context);
    context.ReplaceAll(code_);
    scope.Close(context);

    if (code_ == NULL)
        return $ CYEmpty();
    return this;
}

CYStatement *CYBreak::Replace(CYContext &context) {
    return this;
}

CYTarget *CYCall::Replace(CYContext &context) {
    // XXX: this also is a horrible hack but I'm still a month over schedule :(
    if (CYAttemptMember *member = dynamic_cast<CYAttemptMember *>(function_)) {
        CYIdentifier *value(context.Unique());

        return $C1($F(NULL, $P1($B(value)), $$
            ->* $ CYReturn($ CYCondition($V(value), $C($M($V(value), member->property_), arguments_), $V(value)))
        ), member->object_);
    }

    context.Replace(function_);
    arguments_->Replace(context);
    return this;
}

namespace cy {
namespace Syntax {

void Catch::Replace(CYContext &context) { $T()
    CYScope scope(true, context);

    name_ = name_->Replace(context, CYIdentifierCatch);

    context.ReplaceAll(code_);
    scope.Close(context);
}

} }

CYTarget *CYClassExpression::Replace(CYContext &context) {
    CYBuilder builder;

    CYIdentifier *super(context.Unique());

    CYIdentifier *old(context.super_);
    context.super_ = super;

    CYIdentifier *constructor(context.Unique());
    CYForEach (member, tail_->static_)
        member->Replace(context, builder, $V(constructor), true);

    CYIdentifier *prototype(context.Unique());
    CYForEach (member, tail_->instance_)
        member->Replace(context, builder, $V(prototype), true);

    if (tail_->constructor_ == NULL)
        tail_->constructor_ = $ CYFunctionExpression(NULL, NULL, NULL);
    tail_->constructor_->name_ = name_;
    tail_->constructor_ = CYSuperize(context, tail_->constructor_);

    context.super_ = old;

    return $C1($ CYFunctionExpression(NULL, $P($B(super)), $$
        ->* $ CYVar($B1($B(constructor, tail_->constructor_)))
        ->* $ CYVar($B1($B(prototype, $ CYFunctionExpression(NULL, NULL, NULL))))
        ->* $E($ CYAssign($M($V(prototype), $S("prototype")), $M($V(super), $S("prototype"))))
        ->* $E($ CYAssign($V(prototype), $N($V(prototype))))
        ->* CYDefineProperty($V(prototype), $S("constructor"), false, false, $ CYPropertyValue($S("value"), $V(constructor)))
        ->* $ CYVar(builder.bindings_)
        ->* builder.statements_
        ->* CYDefineProperty($V(constructor), $S("prototype"), false, false, $ CYPropertyValue($S("value"), $V(prototype)))
        ->* $ CYReturn($V(constructor))
    ), tail_->extends_ ? tail_->extends_ : $V($I("Object")));
}

CYStatement *CYClassStatement::Replace(CYContext &context) {
    return $ CYVar($B1($B(name_, $ CYClassExpression(name_, tail_))));
}

void CYClause::Replace(CYContext &context) { $T()
    context.Replace(value_);
    context.ReplaceAll(code_);
    next_->Replace(context);
}

CYExpression *CYCompound::Replace(CYContext &context) {
    context.Replace(expression_);
    context.Replace(next_);

    if (CYCompound *compound = dynamic_cast<CYCompound *>(expression_)) {
        expression_ = compound->expression_;
        compound->expression_ = compound->next_;
        compound->next_ = next_;
        next_ = compound;
    }

    return this;
}

CYFunctionParameter *CYCompound::Parameter() const {
    CYFunctionParameter *next(next_->Parameter());
    if (next == NULL)
        return NULL;

    CYFunctionParameter *parameter(expression_->Parameter());
    if (parameter == NULL)
        return NULL;

    parameter->SetNext(next);
    return parameter;
}

CYFunctionParameter *CYComprehension::Parameters(CYContext &context) const { $T(NULL)
    CYFunctionParameter *next(next_->Parameters(context));
    if (CYFunctionParameter *parameter = Parameter(context)) {
        parameter->SetNext(next);
        return parameter;
    } else
        return next;
}

CYStatement *CYComprehension::Replace(CYContext &context, CYStatement *statement) const {
    return next_ == NULL ? statement : next_->Replace(context, statement);
}

CYExpression *CYComputed::PropertyName(CYContext &context) {
    return expression_;
}

CYExpression *CYCondition::Replace(CYContext &context) {
    context.Replace(test_);
    context.Replace(true_);
    context.Replace(false_);
    return this;
}

void CYContext::NonLocal(CYStatement *&statements) {
    CYContext &context(*this);

    if (nextlocal_ != NULL && nextlocal_->identifier_ != NULL) {
        CYIdentifier *cye($I("$cye")->Replace(context, CYIdentifierGlobal));
        CYIdentifier *unique(nextlocal_->identifier_->Replace(context, CYIdentifierGlobal));

        CYStatement *declare(
            $ CYVar($B1($B(unique, $ CYObject()))));

        cy::Syntax::Catch *rescue(
            $ cy::Syntax::Catch(cye, $$
                ->* $ CYIf($ CYIdentical($M($V(cye), $S("$cyk")), $V(unique)), $$
                    ->* $ CYReturn($M($V(cye), $S("$cyv"))))
                ->* $ cy::Syntax::Throw($V(cye))));

        context.Replace(declare);
        rescue->Replace(context);

        statements = $$
            ->* declare
            ->* $ cy::Syntax::Try(statements, rescue, NULL);
    }
}

CYIdentifier *CYContext::Unique() {
    return $ CYIdentifier($pool.strcat("$cy", $pool.itoa(unique_++), NULL));
}

CYStatement *CYContinue::Replace(CYContext &context) {
    return this;
}

CYStatement *CYDebugger::Replace(CYContext &context) {
    return this;
}

CYTarget *CYBinding::Target(CYContext &context) {
    return $V(identifier_);
}

CYAssignment *CYBinding::Replace(CYContext &context, CYIdentifierKind kind) {
    identifier_ = identifier_->Replace(context, kind);

    if (initializer_ == NULL)
        return NULL;

    CYAssignment *value($ CYAssign(Target(context), initializer_));
    initializer_ = NULL;
    return value;
}

CYExpression *CYBindings::Replace(CYContext &context, CYIdentifierKind kind) { $T(NULL)
    CYAssignment *assignment(binding_->Replace(context, kind));
    CYExpression *compound(next_->Replace(context, kind));

    if (assignment != NULL)
        if (compound == NULL)
            compound = assignment;
        else
            compound = $ CYCompound(assignment, compound);
    return compound;
}

CYFunctionParameter *CYBindings::Parameter(CYContext &context) { $T(NULL)
    return $ CYFunctionParameter($ CYBinding(binding_->identifier_), next_->Parameter(context));
}

CYArgument *CYBindings::Argument(CYContext &context) { $T(NULL)
    return $ CYArgument(binding_->initializer_, next_->Argument(context));
}

CYTarget *CYDirectMember::Replace(CYContext &context) {
    context.Replace(object_);
    context.Replace(property_);
    return this;
}

CYStatement *CYDoWhile::Replace(CYContext &context) {
    context.Replace(test_);
    context.ReplaceAll(code_);
    return this;
}

void CYElementSpread::Replace(CYContext &context) {
    context.Replace(value_);
}

void CYElementValue::Replace(CYContext &context) {
    context.Replace(value_);
}

CYForInitializer *CYEmpty::Replace(CYContext &context) {
    return NULL;
}

CYTarget *CYEncodedType::Replace(CYContext &context) {
    return typed_->Replace(context);
}

CYTarget *CYEval::Replace(CYContext &context) {
    context.scope_->Damage();
    if (arguments_ != NULL)
        arguments_->value_ = $C1($M($V("Cycript"), $S("compile")), arguments_->value_);
    return $C($V("eval"), arguments_);
}

CYStatement *CYExpress::Return() {
    return $ CYReturn(expression_);
}

CYForInitializer *CYExpress::Replace(CYContext &context) {
    context.Replace(expression_);
    return this;
}

CYTarget *CYExpression::AddArgument(CYContext &context, CYExpression *value) {
    return $C1(this, value);
}

CYFunctionParameter *CYExpression::Parameter() const {
    return NULL;
}

CYTarget *CYExtend::Replace(CYContext &context) {
    return object_.Replace(context, lhs_);
}

CYStatement *CYExternalDefinition::Replace(CYContext &context) {
    return $E($ CYAssign($V(name_), $ CYExternalExpression(abi_, type_, name_)));
}

CYTarget *CYExternalExpression::Replace(CYContext &context) {
    CYExpression *expression(name_->Number(context));
    if (expression == NULL)
        expression = $C2($V("dlsym"), $V("RTLD_DEFAULT"), name_->PropertyName(context));
    return $C1(type_->Replace(context), expression);
}

CYNumber *CYFalse::Number(CYContext &context) {
    return $D(0);
}

CYString *CYFalse::String(CYContext &context) {
    return $S("false");
}

CYExpression *CYFatArrow::Replace(CYContext &context) {
    CYFunctionExpression *function($ CYFunctionExpression(NULL, parameters_, code_));
    function->this_.SetNext(context.this_);
    return function;
}

void CYFinally::Replace(CYContext &context) { $T()
    CYScope scope(true, context);
    context.ReplaceAll(code_);
    scope.Close(context);
}

CYStatement *CYFor::Replace(CYContext &context) {
    CYScope outer(true, context);
    context.Replace(initializer_);

    context.Replace(test_);

    {
        CYScope inner(true, context);
        context.ReplaceAll(code_);
        inner.Close(context);
    }

    context.Replace(increment_);

    outer.Close(context);
    return this;
}

CYStatement *CYForLexical::Initialize(CYContext &context, CYExpression *value) {
    if (value == NULL) {
        if (binding_->initializer_ == NULL)
            return NULL;
        value = binding_->initializer_;
    }

    return $ CYLexical(constant_, $B1($ CYBinding(binding_->identifier_, value)));
}

CYTarget *CYForLexical::Replace(CYContext &context) {
    _assert(binding_->Replace(context, CYIdentifierLexical) == NULL);
    return binding_->Target(context);
}

CYStatement *CYForIn::Replace(CYContext &context) {
    CYScope scope(true, context);
    context.Replace(initializer_);
    context.Replace(iterable_);
    context.ReplaceAll(code_);
    scope.Close(context);
    return this;
}

CYStatement *CYForInitialized::Replace(CYContext &context) {
    CYAssignment *assignment(binding_->Replace(context, CYIdentifierVariable));
    return $ CYBlock($$
        ->* (assignment == NULL ? NULL : $ CYExpress(assignment))
        ->* $ CYForIn(binding_->Target(context), iterable_, code_));
}

CYFunctionParameter *CYForInComprehension::Parameter(CYContext &context) const {
    return $ CYFunctionParameter(binding_);
}

CYStatement *CYForInComprehension::Replace(CYContext &context, CYStatement *statement) const {
    return $ CYForIn(binding_->Target(context), iterable_, CYComprehension::Replace(context, statement));
}

CYStatement *CYForOf::Replace(CYContext &context) {
    CYIdentifier *item(context.Unique()), *list(context.Unique());

    return $ CYBlock($$
        ->* initializer_->Initialize(context, NULL)
        ->* $ CYLexical(false, $B2($B(list, iterable_), $B(item)))
        ->* $ CYForIn($V(item), $V(list), $ CYBlock($$
            ->* initializer_->Initialize(context, $M($V(list), $V(item)))
            ->* code_
    )));
}

CYFunctionParameter *CYForOfComprehension::Parameter(CYContext &context) const {
    return $ CYFunctionParameter(binding_);
}

CYStatement *CYForOfComprehension::Replace(CYContext &context, CYStatement *statement) const {
    CYIdentifier *cys(context.Unique());

    return $ CYBlock($$
        ->* $ CYLexical(false, $B1($B(cys, iterable_)))
        ->* $ CYForIn(binding_->Target(context), $V(cys), $ CYBlock($$
            ->* $E($ CYAssign(binding_->Target(context), $M($V(cys), binding_->Target(context))))
            ->* CYComprehension::Replace(context, statement)
    )));
}

CYStatement *CYForVariable::Initialize(CYContext &context, CYExpression *value) {
    if (value == NULL) {
        if (binding_->initializer_ == NULL)
            return NULL;
        value = binding_->initializer_;
    }

    return $ CYVar($B1($ CYBinding(binding_->identifier_, value)));
}

CYTarget *CYForVariable::Replace(CYContext &context) {
    _assert(binding_->Replace(context, CYIdentifierVariable) == NULL);
    return binding_->Target(context);
}

// XXX: this is evil evil black magic. don't ask, don't tell... don't believe!
#define MappingSet "0etnirsoalfucdphmgyvbxTwSNECAFjDLkMOIBPqzRH$_WXUVGYKQJZ"
//#define MappingSet "0abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ$_"

void CYFunction::Replace(CYContext &context) {
    CYThisScope *_this(context.this_);
    context.this_ = &this_;
    context.this_ = CYGetLast(context.this_);

    CYIdentifier *super(context.super_);
    context.super_ = super_;

    CYNonLocal *nonlocal(context.nonlocal_);
    CYNonLocal *nextlocal(context.nextlocal_);

    bool localize;
    if (nonlocal_ != NULL) {
        localize = false;
        context.nonlocal_ = nonlocal_;
    } else {
        localize = true;
        nonlocal_ = $ CYNonLocal();
        context.nextlocal_ = nonlocal_;
    }

    CYScope scope(!localize, context);

    $I("arguments")->Replace(context, CYIdentifierMagic);

    parameters_->Replace(context, code_);

    context.ReplaceAll(code_);

    if (implicit_)
        CYImplicitReturn(code_);

    if (CYIdentifier *identifier = this_.identifier_) {
        context.scope_->Declare(context, identifier, CYIdentifierVariable);
        code_ = $$
            ->* $E($ CYAssign($V(identifier), $ CYThis()))
            ->* code_;
    }

    if (localize)
        context.NonLocal(code_);

    context.nextlocal_ = nextlocal;
    context.nonlocal_ = nonlocal;

    context.super_ = super;
    context.this_ = _this;

    scope.Close(context, code_);
}

CYTarget *CYFunctionExpression::Replace(CYContext &context) {
    CYScope scope(false, context);
    if (name_ != NULL)
        name_ = name_->Replace(context, CYIdentifierOther);

    CYFunction::Replace(context);
    scope.Close(context);
    return this;
}

void CYFunctionParameter::Replace(CYContext &context, CYStatement *&statements) { $T()
    CYAssignment *assignment(binding_->Replace(context, CYIdentifierArgument));

    next_->Replace(context, statements);

    if (assignment != NULL)
        statements = $$
            ->* $ CYIf($ CYIdentical($ CYTypeOf(binding_->Target(context)), $S("undefined")), $$
                ->* $E(assignment))
            ->* statements;
}

CYStatement *CYFunctionStatement::Replace(CYContext &context) {
    name_ = name_->Replace(context, CYIdentifierOther);
    CYFunction::Replace(context);
    return this;
}

CYIdentifier *CYIdentifier::Replace(CYContext &context, CYIdentifierKind kind) {
    if (next_ == this)
        return this;
    if (next_ != NULL)
        return next_->Replace(context, kind);
    next_ = context.scope_->Declare(context, this, kind)->identifier_;
    return next_;
}

CYStatement *CYIf::Return() {
    CYImplicitReturn(true_);
    CYImplicitReturn(false_);
    return this;
}

CYStatement *CYIf::Replace(CYContext &context) {
    context.Replace(test_);
    context.ReplaceAll(true_);
    context.ReplaceAll(false_);
    return this;
}

CYFunctionParameter *CYIfComprehension::Parameter(CYContext &context) const {
    return NULL;
}

CYStatement *CYIfComprehension::Replace(CYContext &context, CYStatement *statement) const {
    return $ CYIf(test_, CYComprehension::Replace(context, statement));
}

CYStatement *CYImport::Replace(CYContext &context) {
    return $ CYVar($B1($B($I(module_->part_->Word()), $C1($V("require"), module_->Replace(context, "/")))));
}

CYStatement *CYImportDeclaration::Replace(CYContext &context) {
    CYIdentifier *module(context.Unique());

    CYList<CYStatement> statements;
    CYForEach (specifier, specifiers_)
        statements->*specifier->Replace(context, module);

    return $ CYBlock($$
        ->* $ CYLexical(false, $B1($B(module, $C1($V("require"), module_))))
        ->* statements);
}

CYStatement *CYImportSpecifier::Replace(CYContext &context, CYIdentifier *module) {
    binding_ = binding_->Replace(context, CYIdentifierLexical);

    CYExpression *import($V(module));
    if (name_ != NULL)
        import = $M(import, $S(name_));
    return $E($ CYAssign($V(binding_), import));
}

CYTarget *CYIndirect::Replace(CYContext &context) {
    return $M(rhs_, $S("$cyi"));
}

CYTarget *CYIndirectMember::Replace(CYContext &context) {
    return $M($ CYIndirect(object_), property_);
}

CYExpression *CYInfix::Replace(CYContext &context) {
    context.Replace(lhs_);
    context.Replace(rhs_);
    return this;
}

CYStatement *CYLabel::Replace(CYContext &context) {
    context.Replace(statement_);
    return this;
}

CYTarget *CYLambda::Replace(CYContext &context) {
    return $N2($V("Functor"), $ CYFunctionExpression(NULL, parameters_->Parameters(context), code_), parameters_->TypeSignature(context, typed_->Replace(context)));
}

CYForInitializer *CYLexical::Replace(CYContext &context) {
    if (CYExpression *expression = bindings_->Replace(context, CYIdentifierLexical))
        return $E(expression);
    return $ CYEmpty();
}

CYFunctionExpression *CYMethod::Constructor() {
    return NULL;
}

void CYMethod::Replace(CYContext &context) {
    CYFunction::Replace(context);
}

CYString *CYModule::Replace(CYContext &context, const char *separator) const {
    if (next_ == NULL)
        return $ CYString(part_);
    return $ CYString($pool.strcat(next_->Replace(context, separator)->Value(), separator, part_->Word(), NULL));
}

CYExpression *CYMultiply::Replace(CYContext &context) {
    CYInfix::Replace(context);

    if (CYNumber *lhn = lhs_->Number(context))
        if (CYNumber *rhn = rhs_->Number(context))
            return $D(lhn->Value() * rhn->Value());

    return this;
}

namespace cy {
namespace Syntax {

CYTarget *New::AddArgument(CYContext &context, CYExpression *value) {
    CYSetLast(arguments_) = $ CYArgument(value);
    return this;
}

CYTarget *New::Replace(CYContext &context) {
    context.Replace(constructor_);
    arguments_->Replace(context);
    return this;
}

} }

CYNumber *CYNull::Number(CYContext &context) {
    return $D(0);
}

CYString *CYNull::String(CYContext &context) {
    return $S("null");
}

CYNumber *CYNumber::Number(CYContext &context) {
    return this;
}

CYString *CYNumber::String(CYContext &context) {
    // XXX: there is a precise algorithm for this
    return $S($pool.sprintf(24, "%.17g", Value()));
}

CYExpression *CYNumber::PropertyName(CYContext &context) {
    return String(context);
}

CYTarget *CYObject::Replace(CYContext &context, CYTarget *seed) {
    CYBuilder builder;
    if (properties_ != NULL)
        properties_ = properties_->ReplaceAll(context, builder, $ CYThis(), seed != this);

    if (builder) {
        return $C1($M($ CYFunctionExpression(NULL, builder.bindings_->Parameter(context),
            builder.statements_
                ->* $ CYReturn($ CYThis())
        ), $S("call")), seed, builder.bindings_->Argument(context));
    }

    CYForEach (property, properties_)
        property->Replace(context);
    return seed;
}

CYTarget *CYObject::Replace(CYContext &context) {
    return Replace(context, this);
}

CYTarget *CYParenthetical::Replace(CYContext &context) {
    // XXX: return expression_;
    context.Replace(expression_);
    return this;
}

CYExpression *CYPostfix::Replace(CYContext &context) {
    context.Replace(lhs_);
    return this;
}

CYExpression *CYPrefix::Replace(CYContext &context) {
    context.Replace(rhs_);
    return this;
}

CYProperty *CYProperty::ReplaceAll(CYContext &context, CYBuilder &builder, CYExpression *self, bool update) {
    update |= Update();
    if (update)
        Replace(context, builder, self, false);
    if (next_ != NULL)
        next_ = next_->ReplaceAll(context, builder, self, update);
    return update ? next_ : this;
}

void CYProperty::Replace(CYContext &context, CYBuilder &builder, CYExpression *self, bool protect) {
    CYExpression *name(name_->PropertyName(context));
    if (name_->Computed()) {
        CYIdentifier *unique(context.Unique());
        builder.bindings_
            ->* $B1($B(unique, name));
        name = $V(unique);
    }

    Replace(context, builder, self, name, protect);
}

bool CYProperty::Update() const {
    return name_->Computed();
}

void CYPropertyGetter::Replace(CYContext &context, CYBuilder &builder, CYExpression *self, CYExpression *name, bool protect) {
    CYIdentifier *unique(context.Unique());
    builder.bindings_
        ->* $B1($B(unique, CYSuperize(context, $ CYFunctionExpression(NULL, parameters_, code_))));
    builder.statements_
        ->* CYDefineProperty(self, name, true, !protect, $ CYPropertyValue($S("get"), $V(unique)));
}

CYFunctionExpression *CYPropertyMethod::Constructor() {
    return name_->Constructor() ? $ CYFunctionExpression(NULL, parameters_, code_) : NULL;
}

void CYPropertyMethod::Replace(CYContext &context, CYBuilder &builder, CYExpression *self, CYExpression *name, bool protect) {
    CYIdentifier *unique(context.Unique());
    builder.bindings_
        ->* $B1($B(unique, CYSuperize(context, $ CYFunctionExpression(NULL, parameters_, code_))));
    builder.statements_
        ->* (!protect ? $E($ CYAssign($M(self, name), $V(unique))) :
            CYDefineProperty(self, name, true, !protect, $ CYPropertyValue($S("value"), $V(unique), $ CYPropertyValue($S("writable"), $ CYTrue()))));
}

bool CYPropertyMethod::Update() const {
    return true;
}

void CYPropertySetter::Replace(CYContext &context, CYBuilder &builder, CYExpression *self, CYExpression *name, bool protect) {
    CYIdentifier *unique(context.Unique());
    builder.bindings_
        ->* $B1($B(unique, CYSuperize(context, $ CYFunctionExpression(NULL, parameters_, code_))));
    builder.statements_
        ->* CYDefineProperty(self, name, true, !protect, $ CYPropertyValue($S("set"), $V(unique)));
}

void CYPropertyValue::Replace(CYContext &context, CYBuilder &builder, CYExpression *self, CYExpression *name, bool protect) {
    _assert(!protect);
    CYIdentifier *unique(context.Unique());
    builder.bindings_
        ->* $B1($B(unique, value_));
    builder.statements_
        ->* $E($ CYAssign($M(self, name), $V(unique)));
}

void CYPropertyValue::Replace(CYContext &context) {
    context.Replace(value_);
}

void CYScript::Replace(CYContext &context) {
    CYScope scope(false, context);
    context.scope_->Damage();

    context.nextlocal_ = $ CYNonLocal();
    context.ReplaceAll(code_);
    context.NonLocal(code_);

    scope.Close(context, code_);

    unsigned offset(0);

    for (std::vector<CYIdentifier *>::const_iterator i(context.replace_.begin()); i != context.replace_.end(); ++i) {
        const char *name;
        if (context.options_.verbose_)
            name = $pool.strcat("$", $pool.itoa(offset++), NULL);
        else {
            char id[8];
            id[7] = '\0';

          id:
            unsigned position(7), local(offset++ + 1);

            do {
                unsigned index(local % (sizeof(MappingSet) - 1));
                local /= sizeof(MappingSet) - 1;
                id[--position] = MappingSet[index];
            } while (local != 0);

            if (scope.Lookup(context, id + position) != NULL)
                goto id;
            // XXX: at some point, this could become a keyword

            name = $pool.strmemdup(id + position, 7 - position);
        }

        CYIdentifier *identifier(*i);
        _assert(identifier->next_ == identifier);
        identifier->next_ = $I(name);
    }
}

CYTarget *CYResolveMember::Replace(CYContext &context) {
    return $M($M(object_, $S("$cyr")), property_);
}

CYStatement *CYReturn::Replace(CYContext &context) {
    if (context.nonlocal_ != NULL) {
        CYProperty *value(value_ == NULL ? NULL : $ CYPropertyValue($S("$cyv"), value_));
        return $ cy::Syntax::Throw($ CYObject(
            $ CYPropertyValue($S("$cyk"), $V(context.nonlocal_->Target(context)), value)
        ));
    }

    context.Replace(value_);
    return this;
}

CYTarget *CYRubyBlock::Replace(CYContext &context) {
    return lhs_->AddArgument(context, proc_->Replace(context));
}

CYTarget *CYRubyBlock::AddArgument(CYContext &context, CYExpression *value) {
    return Replace(context)->AddArgument(context, value);
}

CYTarget *CYRubyProc::Replace(CYContext &context) {
    CYFunctionExpression *function($ CYFunctionExpression(NULL, parameters_, code_));
    function = CYNonLocalize(context, function);
    function->implicit_ = true;
    return function;
}

CYScope::CYScope(bool transparent, CYContext &context) :
    transparent_(transparent),
    parent_(context.scope_),
    damaged_(false),
    shadow_(NULL),
    internal_(NULL)
{
    _assert(!transparent_ || parent_ != NULL);
    context.scope_ = this;
}

void CYScope::Damage() {
    damaged_ = true;
    if (parent_ != NULL)
        parent_->Damage();
}

CYIdentifierFlags *CYScope::Lookup(CYContext &context, const char *word) {
    CYForEach (i, internal_)
        if (strcmp(i->identifier_->Word(), word) == 0)
            return i;
    return NULL;
}

CYIdentifierFlags *CYScope::Lookup(CYContext &context, CYIdentifier *identifier) {
    return Lookup(context, identifier->Word());
}

CYIdentifierFlags *CYScope::Declare(CYContext &context, CYIdentifier *identifier, CYIdentifierKind kind) {
    _assert(identifier->next_ == NULL || identifier->next_ == identifier);

    CYIdentifierFlags *existing(Lookup(context, identifier));
    if (existing == NULL)
        internal_ = $ CYIdentifierFlags(identifier, kind, internal_);
    ++internal_->count_;
    if (existing == NULL)
        return internal_;

    if (kind == CYIdentifierGlobal);
    else if (existing->kind_ == CYIdentifierGlobal || existing->kind_ == CYIdentifierMagic)
        existing->kind_ = kind;
    else if (existing->kind_ == CYIdentifierLexical || kind == CYIdentifierLexical)
        _assert(false);
    else if (transparent_ && existing->kind_ == CYIdentifierArgument && kind == CYIdentifierVariable)
        _assert(false);
    // XXX: throw new SyntaxError() instead of these asserts

    return existing;
}

void CYScope::Merge(CYContext &context, const CYIdentifierFlags *flags) {
    _assert(flags->identifier_->next_ == flags->identifier_);
    CYIdentifierFlags *existing(Declare(context, flags->identifier_, flags->kind_));
    flags->identifier_->next_ = existing->identifier_;

    existing->count_ += flags->count_;
    if (existing->offset_ < flags->offset_)
        existing->offset_ = flags->offset_;
}

void CYScope::Close(CYContext &context, CYStatement *&statements) {
    Close(context);

    CYList<CYBindings> bindings;

    CYForEach (i, internal_)
        if (i->kind_ == CYIdentifierVariable)
            bindings
                ->* $ CYBindings($ CYBinding(i->identifier_));

    if (bindings) {
        CYVar *var($ CYVar(bindings));
        var->SetNext(statements);
        statements = var;
    }
}

void CYScope::Close(CYContext &context) {
    context.scope_ = parent_;

    CYForEach (i, internal_) {
        _assert(i->identifier_->next_ == i->identifier_);
    switch (i->kind_) {
        case CYIdentifierLexical: {
            if (!damaged_) {
                CYIdentifier *replace(context.Unique());
                replace->next_ = replace;
                i->identifier_->next_ = replace;
                i->identifier_ = replace;
            }

            if (!transparent_)
                i->kind_ = CYIdentifierVariable;
            else
                parent_->Declare(context, i->identifier_, CYIdentifierVariable);
        } break;

        case CYIdentifierVariable: {
            if (transparent_) {
                parent_->Declare(context, i->identifier_, i->kind_);
                i->kind_ = CYIdentifierGlobal;
            }
        } break;
    default:; } }

    if (damaged_)
        return;

    typedef std::multimap<unsigned, CYIdentifier *> CYIdentifierOffsetMap;
    CYIdentifierOffsetMap offsets;

    CYForEach (i, internal_) {
        _assert(i->identifier_->next_ == i->identifier_);
    switch (i->kind_) {
        case CYIdentifierArgument:
        case CYIdentifierVariable:
            offsets.insert(CYIdentifierOffsetMap::value_type(i->offset_, i->identifier_));
        break;
    default:; } }

    unsigned offset(0);

    for (CYIdentifierOffsetMap::const_iterator i(offsets.begin()); i != offsets.end(); ++i) {
        if (offset < i->first)
            offset = i->first;
        CYIdentifier *identifier(i->second);

        if (offset >= context.replace_.size())
            context.replace_.resize(offset + 1, NULL);
        CYIdentifier *&replace(context.replace_[offset++]);

        if (replace == NULL)
            replace = identifier;
        else {
            _assert(replace->next_ == replace);
            identifier->next_ = replace;
        }
    }

    if (parent_ == NULL)
        return;

    CYForEach (i, internal_) {
    switch (i->kind_) {
        case CYIdentifierGlobal: {
            if (i->offset_ < offset)
                i->offset_ = offset;
            parent_->Merge(context, i);
        } break;
    default:; } }
}

CYTarget *CYSubscriptMember::Replace(CYContext &context) {
    return $C1($M(object_, $S("$cyg")), property_);
}

CYElementValue *CYSpan::Replace(CYContext &context) { $T(NULL)
    return $ CYElementValue(expression_, $ CYElementValue(string_, next_->Replace(context)));
}

CYStatement *CYStatement::Return() {
    return this;
}

CYString *CYString::Concat(CYContext &context, CYString *rhs) const {
    size_t size(size_ + rhs->size_);
    char *value($ char[size + 1]);
    memcpy(value, value_, size_);
    memcpy(value + size_, rhs->value_, rhs->size_);
    value[size] = '\0';
    return $S(value, size);
}

CYIdentifier *CYString::Identifier() const {
    if (const char *word = Word())
        return $ CYIdentifier(word);
    return NULL;
}

CYNumber *CYString::Number(CYContext &context) {
    // XXX: there is a precise algorithm for this
    return NULL;
}

CYExpression *CYString::PropertyName(CYContext &context) {
    return this;
}

CYString *CYString::String(CYContext &context) {
    return this;
}

CYStatement *CYStructDefinition::Replace(CYContext &context) {
    CYTarget *target(tail_->Replace(context));
    if (name_ != NULL)
        target = $C1($M(target, $S("withName")), $S(name_->Word()));
    return $ CYLexical(false, $B1($B($I($pool.strcat(name_->Word(), "$cy", NULL)), target)));
}

CYTarget *CYStructTail::Replace(CYContext &context) {
    CYList<CYElementValue> types;
    CYList<CYElementValue> names;

    CYForEach (field, fields_) {
        types->*$ CYElementValue(field->type_->Replace(context));

        CYExpression *name;
        if (field->name_ == NULL)
            name = NULL;
        else
            name = field->name_->PropertyName(context);
        names->*$ CYElementValue(name);
    }

    return $N2($V("Type"), $ CYArray(types), $ CYArray(names));
}

CYTarget *CYSuperAccess::Replace(CYContext &context) {
    return $C1($M($M($M($V(context.super_), $S("prototype")), property_), $S("bind")), $ CYThis());
}

CYTarget *CYSuperCall::Replace(CYContext &context) {
    return $C($C1($M($V(context.super_), $S("bind")), $ CYThis()), arguments_);
}

CYTarget *CYSymbol::Replace(CYContext &context) {
    return $C1($M($V("Symbol"), $S("for")), $S(name_));
}

CYStatement *CYSwitch::Replace(CYContext &context) {
    context.Replace(value_);
    clauses_->Replace(context);
    return this;
}

CYStatement *CYTarget::Initialize(CYContext &context, CYExpression *value) {
    if (value == NULL)
        return NULL;
    return $E($ CYAssign(this, value));
}

CYTarget *CYTemplate::Replace(CYContext &context) {
    return $C2($M($M($M($V("String"), $S("prototype")), $S("concat")), $S("apply")), $S(""), $ CYArray($ CYElementValue(string_, spans_->Replace(context))));
}

CYString *CYTemplate::String(CYContext &context) {
    // XXX: implement this over local concat
    if (spans_ != NULL)
        return NULL;
    return string_;
}

CYTarget *CYThis::Replace(CYContext &context) {
    if (context.this_ != NULL)
        return $V(context.this_->Identifier(context));
    return this;
}

namespace cy {
namespace Syntax {

CYStatement *Throw::Replace(CYContext &context) {
    context.Replace(value_);
    return this;
}

} }

CYTarget *CYTrivial::Replace(CYContext &context) {
    return this;
}

CYNumber *CYTrue::Number(CYContext &context) {
    return $D(1);
}

CYString *CYTrue::String(CYContext &context) {
    return $S("true");
}

namespace cy {
namespace Syntax {

CYStatement *Try::Replace(CYContext &context) {
    CYScope scope(true, context);
    context.ReplaceAll(code_);
    scope.Close(context);

    catch_->Replace(context);
    finally_->Replace(context);
    return this;
}

} }

CYTarget *CYTypeArrayOf::Replace_(CYContext &context, CYTarget *type) {
    return next_->Replace(context, $ CYCall($ CYDirectMember(type, $ CYString("arrayOf")), $ CYArgument(size_)));
}

CYTarget *CYTypeBlockWith::Replace_(CYContext &context, CYTarget *type) {
    return next_->Replace(context, $ CYCall($ CYDirectMember(type, $ CYString("blockWith")), parameters_->Argument(context)));
}

CYTarget *CYTypeCharacter::Replace(CYContext &context) {
    switch (signing_) {
        case CYTypeNeutral: return $V("char");
        case CYTypeSigned: return $V("schar");
        case CYTypeUnsigned: return $V("uchar");
        default: _assert(false);
    }
}

CYTarget *CYTypeConstant::Replace_(CYContext &context, CYTarget *type) {
    return next_->Replace(context, $ CYCall($ CYDirectMember(type, $ CYString("constant"))));
}

CYStatement *CYTypeDefinition::Replace(CYContext &context) {
    return $ CYLexical(false, $B1($B(name_, $ CYTypeExpression(type_))));
}

CYTarget *CYTypeEnum::Replace(CYContext &context) {
    CYList<CYProperty> properties;
    CYForEach (constant, constants_)
        properties->*$ CYPropertyValue($S(constant->name_->Word()), constant->value_);
    CYObject *constants($ CYObject(properties));

    if (specifier_ == NULL)
        return $N1($V("Type"), constants);
    else
        return $C1($M(specifier_->Replace(context), $S("enumFor")), constants);
}

CYTarget *CYTypeError::Replace(CYContext &context) {
    _assert(false);
    return NULL;
}

CYTarget *CYTypeExpression::Replace(CYContext &context) {
    return typed_->Replace(context);
}

CYTarget *CYTypeFloating::Replace(CYContext &context) {
    switch (length_) {
        case 0: return $V("float");
        case 1: return $V("double");
        case 2: return $V("longdouble");
        default: _assert(false);
    }
}

CYTarget *CYTypeInt128::Replace(CYContext &context) {
    return $V(signing_ == CYTypeUnsigned ? "uint128" : "int128");
}

CYTarget *CYTypeIntegral::Replace(CYContext &context) {
    bool u(signing_ == CYTypeUnsigned);
    switch (length_) {
        case 0: return $V(u ? "ushort" : "short");
        case 1: return $V(u ? "uint" : "int");
        case 2: return $V(u ? "ulong" : "long");
        case 3: return $V(u ? "ulonglong" : "longlong");
        default: _assert(false);
    }
}

CYTarget *CYTypeModifier::Replace(CYContext &context, CYTarget *type) { $T(type)
    return Replace_(context, type);
}

CYTarget *CYTypeFunctionWith::Replace_(CYContext &context, CYTarget *type) {
    CYList<CYArgument> arguments(parameters_->Argument(context));
    if (variadic_)
        arguments->*$C_($ CYNull());
    return next_->Replace(context, $ CYCall($ CYDirectMember(type, $ CYString("functionWith")), arguments));
}

CYTarget *CYTypePointerTo::Replace_(CYContext &context, CYTarget *type) {
    return next_->Replace(context, $ CYCall($ CYDirectMember(type, $ CYString("pointerTo"))));
}

CYTarget *CYTypeReference::Replace(CYContext &context) {
    const char *prefix;
    switch (kind_) {
        case CYTypeReferenceStruct: prefix = "$cys"; break;
        case CYTypeReferenceEnum: prefix = "$cye"; break;
        default: _assert(false);
    }

    return $V($pool.strcat(prefix, name_->Word(), NULL));
}

CYTarget *CYTypeStruct::Replace(CYContext &context) {
    CYTarget *target(tail_->Replace(context));
    if (name_ != NULL)
        target = $C1($M(target, $S("withName")), $S(name_->Word()));
    return target;
}

CYTarget *CYTypeVariable::Replace(CYContext &context) {
    return $V(name_);
}

CYTarget *CYTypeVoid::Replace(CYContext &context) {
    return $N1($V("Type"), $ CYString("v"));
}

CYTarget *CYTypeVolatile::Replace_(CYContext &context, CYTarget *type) {
    return next_->Replace(context, $ CYCall($ CYDirectMember(type, $ CYString("volatile"))));
}

CYTarget *CYType::Replace(CYContext &context) {
    return modifier_->Replace(context, specifier_->Replace(context));
}

CYTypeFunctionWith *CYType::Function() {
    CYTypeModifier *&modifier(CYGetLast(modifier_));
    if (modifier == NULL)
        return NULL;

    CYTypeFunctionWith *function(modifier->Function());
    if (function == NULL)
        return NULL;

    modifier = NULL;
    return function;
}

CYArgument *CYTypedParameter::Argument(CYContext &context) { $T(NULL)
    return $ CYArgument(type_->Replace(context), next_->Argument(context));
}

CYFunctionParameter *CYTypedParameter::Parameters(CYContext &context) { $T(NULL)
    return $ CYFunctionParameter($ CYBinding(name_ ? name_ : context.Unique()), next_->Parameters(context));
}

CYExpression *CYTypedParameter::TypeSignature(CYContext &context, CYExpression *prefix) { $T(prefix)
    return next_->TypeSignature(context, $ CYAdd(prefix, type_->Replace(context)));
}

CYForInitializer *CYVar::Replace(CYContext &context) {
    if (CYExpression *expression = bindings_->Replace(context, CYIdentifierVariable))
        return $E(expression);
    return $ CYEmpty();
}

CYTarget *CYVariable::Replace(CYContext &context) {
    name_ = name_->Replace(context, CYIdentifierGlobal);
    return this;
}

CYFunctionParameter *CYVariable::Parameter() const {
    return $ CYFunctionParameter($ CYBinding(name_));
}

CYStatement *CYWhile::Replace(CYContext &context) {
    context.Replace(test_);
    context.ReplaceAll(code_);
    return this;
}

CYStatement *CYWith::Replace(CYContext &context) {
    context.Replace(scope_);
    CYScope scope(true, context);
    scope.Damage();
    context.ReplaceAll(code_);
    scope.Close(context);
    return this;
}

CYExpression *CYWord::PropertyName(CYContext &context) {
    return $S(this);
}
