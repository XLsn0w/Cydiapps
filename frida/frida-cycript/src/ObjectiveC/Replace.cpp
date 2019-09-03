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

static CYExpression *MessageType(CYContext &context, CYType *type, CYMessageParameter *next, CYExpression *extra = NULL) {
    CYExpression *left($C0($M(type->Replace(context), $S("toString"))));
    if (extra != NULL)
        left = $ CYAdd(left, extra);

    if (next == NULL || next->type_ == NULL)
        return left;

    CYExpression *right(next->TypeSignature(context));
    if (right == NULL)
        return NULL;

    return $ CYAdd(left, right);
}

CYStatement *CYCategory::Replace(CYContext &context) {
    CYVariable *cyc($V("$cyc")), *cys($V("$cys"));

    return $E($C1($F(NULL, $P6($B($I("$cys")), $B($I("$cyp")), $B($I("$cyc")), $B($I("$cyn")), $B($I("$cyt")), $B($I("$cym"))), $$->*
        $E($ CYAssign($V("$cyp"), $C1($V("object_getClass"), cys)))->*
        $E($ CYAssign(cyc, cys))->*
        $E($ CYAssign($V("$cym"), $C1($V("object_getClass"), cyc)))->*
        messages_->Replace(context, true)
    ), $C1($V("objc_getClass"), $S(name_))));
}

CYStatement *CYImplementation::Replace(CYContext &context) {
    CYVariable *cyc($V("$cyc")), *cys($V("$cys"));

    return $E($C1($F(NULL, $P6($B($I("$cys")), $B($I("$cyp")), $B($I("$cyc")), $B($I("$cyn")), $B($I("$cyt")), $B($I("$cym"))), $$->*
        $E($ CYAssign($V("$cyp"), $C1($V("object_getClass"), cys)))->*
        $E($ CYAssign(cyc, $C3($V("objc_allocateClassPair"), cys, $S(name_), $D(0))))->*
        $E($ CYAssign($V("$cym"), $C1($V("object_getClass"), cyc)))->*
        protocols_->Replace(context)->*
        fields_->Replace(context)->*
        messages_->Replace(context, false)->*
        $E($C1($V("objc_registerClassPair"), cyc))->*
        $ CYReturn(cyc)
    ), extends_ == NULL ? $ CYNull() : extends_));
}

CYStatement *CYImplementationField::Replace(CYContext &context) const { $T(NULL)
    CYVariable *cyn($V("$cyn"));
    CYVariable *cyt($V("$cyt"));

    CYExpression *type($C0($M(type_->Replace(context), $S("toString"))));

    return $ CYBlock($$->*
        $E($ CYAssign(cyt, type))->*
        $E($ CYAssign(cyn, $N1($V("Type"), cyt)))->*
        $E($C5($V("class_addIvar"), $V("$cyc"), name_->PropertyName(context), $M(cyn, $S("size")), $M(cyn, $S("alignment")), cyt))->*
        next_->Replace(context)
    );
}

CYTarget *CYInstanceLiteral::Replace(CYContext &context) {
    return $N1($V("Instance"), number_);
}

CYStatement *CYMessage::Replace(CYContext &context, bool replace) const { $T(NULL)
    CYVariable *cyn($V("$cyn"));
    CYVariable *cyt($V("$cyt"));
    CYVariable *self($V("self"));
    CYVariable *_class($V(instance_ ? "$cys" : "$cyp"));

    return $ CYBlock($$->*
        next_->Replace(context, replace)->*
        $E($ CYAssign(cyn, parameters_->Selector(context)))->*
        $E($ CYAssign(cyt, TypeSignature(context)))->*
        $E($C4($V(replace ? "class_replaceMethod" : "class_addMethod"),
            $V(instance_ ? "$cyc" : "$cym"),
            cyn,
            $N2($V("Functor"), $F(NULL, $P2($B($I("self")), $B($I("_cmd")), parameters_->Parameters(context)), $$->*
                $ CYVar($B1($B($I("$cyr"), $N2($V("objc_super"), self, _class))))->*
                $ CYReturn($C1($M($F(NULL, NULL, code_.code_), $S("call")), self))
            ), cyt),
            cyt
        ))
    );
}

CYExpression *CYMessage::TypeSignature(CYContext &context) const {
    return MessageType(context, type_, parameters_, $S("@:"));
}

CYFunctionParameter *CYMessageParameter::Parameters(CYContext &context) const { $T(NULL)
    CYFunctionParameter *next(next_->Parameters(context));
    return type_ == NULL ? next : $ CYFunctionParameter($B(identifier_), next);
}

CYSelector *CYMessageParameter::Selector(CYContext &context) const {
    return $ CYSelector(SelectorPart(context));
}

CYSelectorPart *CYMessageParameter::SelectorPart(CYContext &context) const { $T(NULL)
    CYSelectorPart *next(next_->SelectorPart(context));
    return name_ == NULL ? next : $ CYSelectorPart(name_, type_ != NULL, next);
}

CYExpression *CYMessageParameter::TypeSignature(CYContext &context) const {
    return MessageType(context, type_, next_);
}

CYTarget *CYBox::Replace(CYContext &context) {
    return $C1($M($V("Instance"), $S("box")), value_);
}

CYTarget *CYObjCArray::Replace(CYContext &context) {
    size_t count(0);
    CYForEach (element, elements_)
        ++count;
    return $ CYSendDirect($V("NSArray"), $C_($ CYWord("arrayWithObjects"), $ CYArray(elements_), $C_($ CYWord("count"), $D(count))));
}

CYTarget *CYObjCDictionary::Replace(CYContext &context) {
    CYList<CYElement> keys;
    CYList<CYElement> values;
    size_t count(0);

    CYForEach (pair, pairs_) {
        keys->*$ CYElementValue(pair->key_);
        values->*$ CYElementValue(pair->value_);
        ++count;
    }

    return $ CYSendDirect($V("NSDictionary"), $C_($ CYWord("dictionaryWithObjects"), $ CYArray(values), $C_($ CYWord("forKeys"), $ CYArray(keys), $C_($ CYWord("count"), $D(count)))));
}

CYTarget *CYObjCBlock::Replace(CYContext &context) {
    // XXX: wtf is happening here?
    return $C1($ CYTypeExpression(($ CYType(*typed_))->Modify($ CYTypeBlockWith(parameters_))), $ CYFunctionExpression(NULL, parameters_->Parameters(context), code_));
}

CYStatement *CYProtocol::Replace(CYContext &context) const { $T(NULL)
    return $ CYBlock($$->*
        next_->Replace(context)->*
        $E($C2($V("class_addProtocol"),
            $V("$cyc"), name_
        ))
    );
}

CYTarget *CYSelector::Replace(CYContext &context) {
    return $C1($V("sel_registerName"), parts_->Replace(context));
}

CYString *CYSelectorPart::Replace(CYContext &context) {
    std::ostringstream str;
    CYForEach (part, this) {
        if (part->name_ != NULL)
            str << part->name_->Word();
        if (part->value_)
            str << ':';
    }
    return $S($pool.strdup(str.str().c_str()));
}

CYTarget *CYSendDirect::Replace(CYContext &context) {
    std::ostringstream name;
    CYArgument **argument(&arguments_);
    CYSelectorPart *selector(NULL), *current(NULL);

    while (*argument != NULL) {
        if ((*argument)->name_ != NULL) {
            CYSelectorPart *part($ CYSelectorPart((*argument)->name_, (*argument)->value_ != NULL));
            if (selector == NULL)
                selector = part;
            if (current != NULL)
                current->SetNext(part);
            current = part;
            (*argument)->name_ = NULL;
        }

        if ((*argument)->value_ == NULL)
            *argument = (*argument)->next_;
        else
            argument = &(*argument)->next_;
    }

    return $C2($V("objc_msgSend"), self_, selector->Replace(context), arguments_);
}

CYTarget *CYSendSuper::Replace(CYContext &context) {
    return $ CYSendDirect($V("$cyr"), arguments_);
}
