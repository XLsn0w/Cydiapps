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
#include <cstring>
#include <iostream>
#include <map>
#include <sstream>
#include <string>

#include <clang-c/Index.h>

#include "Bridge.hpp"
#include "Functor.hpp"
#include "Replace.hpp"
#include "Syntax.hpp"

static CXChildVisitResult CYVisit(CXCursor cursor, CXCursor parent, CXClientData arg) {
    (*reinterpret_cast<const Functor<void (CXCursor)> *>(arg))(cursor);
    return CXChildVisit_Continue;
}

static unsigned CYForChild(CXCursor cursor, const Functor<void (CXCursor)> &visitor) {
    return clang_visitChildren(cursor, &CYVisit, const_cast<void *>(static_cast<const void *>(&visitor)));
}

static bool CYOneChild(CXCursor cursor, const Functor<void (CXCursor)> &visitor) {
    bool visited(false);
    CYForChild(cursor, fun([&](CXCursor child) {
        _assert(!visited);
        visited = true;
        visitor(child);
    }));
    return visited;
}

struct CYCXString {
    CXString value_;

    CYCXString(CXString value) :
        value_(value)
    {
    }

    CYCXString(CXCursor cursor) :
        value_(clang_getCursorSpelling(cursor))
    {
    }

    CYCXString(CXCursorKind kind) :
        value_(clang_getCursorKindSpelling(kind))
    {
    }

    CYCXString(CXFile file) :
        value_(clang_getFileName(file))
    {
    }

    CYCXString(CXTranslationUnit unit, CXToken token) :
        value_(clang_getTokenSpelling(unit, token))
    {
    }

    ~CYCXString() {
        clang_disposeString(value_);
    }

    operator const char *() const {
        return clang_getCString(value_);
    }

    const char *Pool(CYPool &pool) const {
        return pool.strdup(*this);
    }

    bool operator ==(const char *rhs) const {
        const char *lhs(*this);
        return lhs == rhs || strcmp(lhs, rhs) == 0;
    }
};

template <void (&clang_get_Location)(CXSourceLocation, CXFile *, unsigned *, unsigned *, unsigned *) = clang_getSpellingLocation>
struct CYCXPosition {
    CXFile file_;
    unsigned line_;
    unsigned column_;
    unsigned offset_;

    CYCXPosition(CXSourceLocation location) {
        clang_get_Location(location, &file_, &line_, &column_, &offset_);
    }

    CYCXPosition(CXTranslationUnit unit, CXToken token) :
        CYCXPosition(clang_getTokenLocation(unit, token))
    {
    }

    CXSourceLocation Get(CXTranslationUnit unit) const {
        return clang_getLocation(unit, file_, line_, column_);
    }
};

template <void (&clang_get_Location)(CXSourceLocation, CXFile *, unsigned *, unsigned *, unsigned *)>
std::ostream &operator <<(std::ostream &out, const CYCXPosition<clang_get_Location> &position) {
    if (position.file_ != NULL)
        out << "[" << CYCXString(position.file_) << "]:";
    out << position.line_ << ":" << position.column_ << "@" << position.offset_;
    return out;
}

struct CYKey {
    unsigned priority_ = 0;

    std::string code_;
    unsigned flags_;
};

typedef std::map<std::string, CYKey> CYKeyMap;

struct CYChildBaton {
    CXTranslationUnit unit;
    CYKeyMap &keys;

    CYChildBaton(CXTranslationUnit unit, CYKeyMap &keys) :
        unit(unit),
        keys(keys)
    {
    }
};

struct CYTokens {
  private:
    CXTranslationUnit unit_;
    CXToken *tokens_;
    unsigned count_;
    unsigned valid_;

  public:
    CYTokens(CXTranslationUnit unit, CXSourceRange range) :
        unit_(unit)
    {
        clang_tokenize(unit_, range, &tokens_, &count_);


        // libclang's tokenizer is horribly broken and returns "extra" tokens.
        // this code goes back through the tokens and filters for good ones :/

        CYCXPosition<> end(clang_getRangeEnd(range));
        CYCXString file(end.file_);

        for (valid_ = 0; valid_ != count_; ++valid_) {
            CYCXPosition<> position(unit, tokens_[valid_]);
            _assert(CYCXString(position.file_) == file);
            if (position.offset_ >= end.offset_)
                break;
        }
    }

    CYTokens(CXTranslationUnit unit, CXCursor cursor) :
        CYTokens(unit, clang_getCursorExtent(cursor))
    {
    }

    ~CYTokens() {
        clang_disposeTokens(unit_, tokens_, count_);
    }

    operator CXToken *() const {
        return tokens_;
    }

    size_t size() const {
        return valid_;
    }
};

static CYUTF8String CYCXPoolUTF8Range(CYPool &pool, CXSourceRange range) {
    CYCXPosition<> start(clang_getRangeStart(range));
    CYCXPosition<> end(clang_getRangeEnd(range));
    CYCXString file(start.file_);
    _assert(file == CYCXString(end.file_));

    CYPool temp;
    size_t size;
    char *data(static_cast<char *>(CYPoolFile(temp, file, &size)));
    _assert(start.offset_ <= size && end.offset_ <= size && start.offset_ <= end.offset_);

    CYUTF8String code;
    code.size = end.offset_ - start.offset_;
    code.data = pool.strndup(data + start.offset_, code.size);
    return code;
}

static CYExpression *CYTranslateExpression(CXTranslationUnit unit, CXCursor cursor) {
    switch (CXCursorKind kind = clang_getCursorKind(cursor)) {
        case CXCursor_CallExpr: {
            CYExpression *function(NULL);
            CYList<CYArgument> arguments;
            CYForChild(cursor, fun([&](CXCursor child) {
                CYExpression *expression(CYTranslateExpression(unit, child));
                if (function == NULL)
                    function = expression;
                else
                    arguments->*$C_(expression);
            }));
            return $C(function, arguments);
        } break;

        case CXCursor_DeclRefExpr: {
            return $V(CYCXString(cursor).Pool($pool));
        } break;

        case CXCursor_IntegerLiteral: {
            // libclang doesn't provide any reasonable way to do this
            // note: clang_tokenize doesn't work if this is a macro
            // the token range starts inside the macro but ends after it
            // the tokenizer freaks out and either fails with 0 tokens
            // or returns some massive number of tokens ending here :/

            CYUTF8String token(CYCXPoolUTF8Range($pool, clang_getCursorExtent(cursor)));
            double value(CYCastDouble(token));
            if (std::isnan(value))
                return $V(token.data);
            return $ CYNumber(value);
        } break;

        case CXCursor_CStyleCastExpr:
            // XXX: most of the time, this is a "NoOp" integer cast; but we should check it

        case CXCursor_UnexposedExpr:
            // there is a very high probability that this is actually an "ImplicitCastExpr"
            // "Douglas Gregor" <dgregor@apple.com> err'd on the incorrect side of this one
            // http://lists.llvm.org/pipermail/cfe-commits/Week-of-Mon-20110926/046998.html

        case CXCursor_ParenExpr: {
            CYExpression *pass(NULL);
            CYOneChild(cursor, fun([&](CXCursor child) {
                pass = CYTranslateExpression(unit, child);
            }));
            return pass;
        } break;

        default:
            //std::cerr << "E:" << CYCXString(kind) << std::endl;
            _assert(false);
    }
}

static CYStatement *CYTranslateStatement(CXTranslationUnit unit, CXCursor cursor) {
    switch (CXCursorKind kind = clang_getCursorKind(cursor)) {
        case CXCursor_ReturnStmt: {
            CYExpression *value(NULL);
            CYOneChild(cursor, fun([&](CXCursor child) {
                value = CYTranslateExpression(unit, child);
            }));
            return $ CYReturn(value);
        } break;

        default:
            //std::cerr << "S:" << CYCXString(kind) << std::endl;
            _assert(false);
    }
}

static CYStatement *CYTranslateBlock(CXTranslationUnit unit, CXCursor cursor) {
    CYList<CYStatement> statements;
    CYForChild(cursor, fun([&](CXCursor child) {
        statements->*CYTranslateStatement(unit, child);
    }));
    return $ CYBlock(statements);
}

static CYType *CYDecodeType(CXType type);
static void CYParseType(CXType type, CYType *typed);

static void CYParseEnumeration(CXCursor cursor, CYType *typed) {
    CYList<CYEnumConstant> constants;

    CYForChild(cursor, fun([&](CXCursor child) {
        if (clang_getCursorKind(child) == CXCursor_EnumConstantDecl)
            constants->*$ CYEnumConstant($I($pool.strdup(CYCXString(child))), $D(clang_getEnumConstantDeclValue(child)));
    }));

    CYType *integer(CYDecodeType(clang_getEnumDeclIntegerType(cursor)));
    typed->specifier_ = $ CYTypeEnum(NULL, integer->specifier_, constants);
}

static void CYParseStructure(CXCursor cursor, CYType *typed) {
    CYList<CYTypeStructField> fields;
    CYForChild(cursor, fun([&](CXCursor child) {
        if (clang_getCursorKind(child) == CXCursor_FieldDecl)
            fields->*$ CYTypeStructField(CYDecodeType(clang_getCursorType(child)), $I(CYCXString(child).Pool($pool)));
    }));

    typed->specifier_ = $ CYTypeStruct(NULL, $ CYStructTail(fields));
}

static void CYParseCursor(CXType type, CXCursor cursor, CYType *typed) {
    CYCXString spelling(cursor);

    switch (CXCursorKind kind = clang_getCursorKind(cursor)) {
        case CXCursor_EnumDecl:
            if (spelling[0] != '\0')
                typed->specifier_ = $ CYTypeReference(CYTypeReferenceEnum, $I(spelling.Pool($pool)));
            else
                CYParseEnumeration(cursor, typed);
        break;

        case CXCursor_StructDecl: {
            if (spelling[0] != '\0')
                typed->specifier_ = $ CYTypeReference(CYTypeReferenceStruct, $I(spelling.Pool($pool)));
            else
                CYParseStructure(cursor, typed);
        } break;

        case CXCursor_UnionDecl: {
            _assert(false);
        } break;

        default:
            std::cerr << "C:" << CYCXString(kind) << std::endl;
            _assert(false);
            break;
    }
}

static CYTypedParameter *CYParseSignature(CXType type, CYType *typed) {
    CYParseType(clang_getResultType(type), typed);
    CYList<CYTypedParameter> parameters;
    for (int i(0), e(clang_getNumArgTypes(type)); i != e; ++i)
        parameters->*$ CYTypedParameter(CYDecodeType(clang_getArgType(type, i)), NULL);
    return parameters;
}

static void CYParseFunction(CXType type, CYType *typed) {
    typed = typed->Modify($ CYTypeFunctionWith(clang_isFunctionTypeVariadic(type), CYParseSignature(type, typed)));
}

static void CYParseType(CXType type, CYType *typed) {
    switch (CXTypeKind kind = type.kind) {
        case CXType_Unexposed: {
            CXType result(clang_getResultType(type));
            if (result.kind == CXType_Invalid)
                CYParseCursor(type, clang_getTypeDeclaration(type), typed);
            else
                // clang marks function pointers as Unexposed but still supports them
                CYParseFunction(type, typed);
        } break;

        case CXType_Bool: typed->specifier_ = $ CYTypeVariable("bool"); break;
        case CXType_WChar: typed->specifier_ = $ CYTypeVariable("wchar_t"); break;
        case CXType_Float: typed->specifier_ = $ CYTypeFloating(0); break;
        case CXType_Double: typed->specifier_ = $ CYTypeFloating(1); break;
        case CXType_LongDouble: typed->specifier_ = $ CYTypeFloating(2); break;

        case CXType_Char_U: typed->specifier_ = $ CYTypeCharacter(CYTypeNeutral); break;
        case CXType_Char_S: typed->specifier_ = $ CYTypeCharacter(CYTypeNeutral); break;
        case CXType_SChar: typed->specifier_ = $ CYTypeCharacter(CYTypeSigned); break;
        case CXType_UChar: typed->specifier_ = $ CYTypeCharacter(CYTypeUnsigned); break;

        case CXType_Short: typed->specifier_ = $ CYTypeIntegral(CYTypeSigned, 0); break;
        case CXType_UShort: typed->specifier_ = $ CYTypeIntegral(CYTypeUnsigned, 0); break;

        case CXType_Int: typed->specifier_ = $ CYTypeIntegral(CYTypeSigned, 1); break;
        case CXType_UInt: typed->specifier_ = $ CYTypeIntegral(CYTypeUnsigned, 1); break;

        case CXType_Long: typed->specifier_ = $ CYTypeIntegral(CYTypeSigned, 2); break;
        case CXType_ULong: typed->specifier_ = $ CYTypeIntegral(CYTypeUnsigned, 2); break;

        case CXType_LongLong: typed->specifier_ = $ CYTypeIntegral(CYTypeSigned, 3); break;
        case CXType_ULongLong: typed->specifier_ = $ CYTypeIntegral(CYTypeUnsigned, 3); break;

        case CXType_Int128: typed->specifier_ = $ CYTypeInt128(CYTypeSigned); break;
        case CXType_UInt128: typed->specifier_ = $ CYTypeInt128(CYTypeUnsigned); break;

        case CXType_BlockPointer: {
            CXType pointee(clang_getPointeeType(type));
            _assert(!clang_isFunctionTypeVariadic(pointee));
            typed = typed->Modify($ CYTypeBlockWith(CYParseSignature(pointee, typed)));
        } break;

        case CXType_ConstantArray:
            CYParseType(clang_getArrayElementType(type), typed);
            typed = typed->Modify($ CYTypeArrayOf($D(clang_getArraySize(type))));
        break;

        case CXType_Enum:
            typed->specifier_ = $ CYTypeVariable($pool.strdup(CYCXString(clang_getTypeSpelling(type))));
        break;

        case CXType_FunctionProto:
            CYParseFunction(type, typed);
        break;

        case CXType_IncompleteArray:
            // XXX: I probably should not decay to Pointer
            CYParseType(clang_getArrayElementType(type), typed);
            typed = typed->Modify($ CYTypePointerTo());
        break;

        case CXType_ObjCClass:
            typed->specifier_ = $ CYTypeVariable("Class");
        break;

        case CXType_ObjCId:
            typed->specifier_ = $ CYTypeVariable("id");
        break;

        case CXType_ObjCInterface:
            typed->specifier_ = $ CYTypeVariable($pool.strdup(CYCXString(clang_getTypeSpelling(type))));
        break;

        case CXType_ObjCObjectPointer: {
            CXType pointee(clang_getPointeeType(type));
            if (pointee.kind != CXType_Unexposed) {
                CYParseType(pointee, typed);
                typed = typed->Modify($ CYTypePointerTo());
            } else
                // Clang seems to have internal typedefs for id and Class that are awkward
                _assert(false);
        } break;

        case CXType_ObjCSel:
            typed->specifier_ = $ CYTypeVariable("SEL");
        break;

        case CXType_Pointer:
            CYParseType(clang_getPointeeType(type), typed);
            typed = typed->Modify($ CYTypePointerTo());
        break;

        case CXType_Record:
            typed->specifier_ = $ CYTypeReference(CYTypeReferenceStruct, $I($pool.strdup(CYCXString(clang_getTypeSpelling(type)))));
        break;

        case CXType_Typedef:
            // use the declaration in order to isolate the name of the typedef itself
            typed->specifier_ = $ CYTypeVariable($pool.strdup(CYCXString(clang_getTypeDeclaration(type))));
        break;

        case CXType_Elaborated:
            CYParseType(clang_Type_getNamedType(type), typed);
        break;

        case CXType_Vector:
            _assert(false);
        break;

        case CXType_Void:
            typed->specifier_ = $ CYTypeVoid();
        break;

        default:
            std::cerr << "T:" << CYCXString(clang_getTypeKindSpelling(kind)) << std::endl;
            std::cerr << "_: " << CYCXString(clang_getTypeSpelling(type)) << std::endl;
            _assert(false);
    }

    if (clang_isConstQualifiedType(type))
        typed = typed->Modify($ CYTypeConstant());
}

static CYType *CYDecodeType(CXType type) {
    CYType *typed($ CYType(NULL));
    CYParseType(type, typed);
    return typed;
}

static CXChildVisitResult CYChildVisit(CXCursor cursor, CXCursor parent, CXClientData arg) {
    CYChildBaton &baton(*static_cast<CYChildBaton *>(arg));
    CXTranslationUnit &unit(baton.unit);

    CXChildVisitResult result(CXChildVisit_Continue);
    CYCXString spelling(cursor);
    std::string name(spelling);
    std::ostringstream value;
    unsigned priority(2);
    unsigned flags(CYBridgeHold);

    /*CXSourceLocation location(clang_getCursorLocation(cursor));
    CYCXPosition<> position(location);
    std::cerr << spelling << " " << position << std::endl;*/

    try { switch (CXCursorKind kind = clang_getCursorKind(cursor)) {
        case CXCursor_EnumConstantDecl: {
            value << clang_getEnumConstantDeclValue(cursor);
        } break;

        case CXCursor_EnumDecl: {
            // the enum constants are implemented separately *also*
            // XXX: maybe move output logic to function we can call
            result = CXChildVisit_Recurse;

            if (spelling[0] == '\0')
                goto skip;
            // XXX: this was blindly copied from StructDecl
            if (!clang_isCursorDefinition(cursor))
                priority = 1;

            CYLocalPool pool;

            CYType typed;
            CYParseEnumeration(cursor, &typed);

            CYOptions options;
            CYOutput out(*value.rdbuf(), options);
            CYTypeExpression(&typed).Output(out, CYNoBFC);

            value << ".withName(\"" << name << "\")";
            name = "$cye" + name;
            flags = CYBridgeType;
        } break;

        case CXCursor_MacroDefinition: {
            CXSourceRange range(clang_getCursorExtent(cursor));
            CYTokens tokens(unit, range);
            _assert(tokens.size() != 0);

            CXCursor cursors[tokens.size()];
            clang_annotateTokens(unit, tokens, tokens.size(), cursors);

            CYLocalPool local;
            CYList<CYFunctionParameter> parameters;
            unsigned offset(1);

            if (tokens.size() != 1) {
                CYCXPosition<> start(clang_getRangeStart(range));
                CYCXString first(unit, tokens[offset]);
                if (first == "(") {
                    CYCXPosition<> paren(unit, tokens[offset]);
                    if (start.offset_ + strlen(spelling) == paren.offset_) {
                        for (;;) {
                            _assert(++offset != tokens.size());
                            CYCXString token(unit, tokens[offset]);
                            parameters->*$P($B($I(token.Pool($pool))));
                            _assert(++offset != tokens.size());
                            CYCXString comma(unit, tokens[offset]);
                            if (comma == ")")
                                break;
                            _assert(comma == ",");
                        }
                        ++offset;
                    }
                }
            }

            std::ostringstream body;
            for (unsigned i(offset); i != tokens.size(); ++i) {
                CYCXString token(unit, tokens[i]);
                if (i != offset)
                    body << " ";
                body << token;
            }

            if (!parameters)
                value << body.str();
            else {
                CYOptions options;
                CYOutput out(*value.rdbuf(), options);
                out << '(' << "function" << '(';
                out << parameters;
                out << ')' << '{';
                out << "return" << ' ';
                value << body.str();
                out << ';' << '}' << ')';
            }
        } break;

        case CXCursor_StructDecl: {
            if (spelling[0] == '\0')
                goto skip;
            if (!clang_isCursorDefinition(cursor))
                priority = 1;

            CYLocalPool pool;

            CYType typed;
            CYParseStructure(cursor, &typed);

            CYOptions options;
            CYOutput out(*value.rdbuf(), options);
            CYTypeExpression(&typed).Output(out, CYNoBFC);

            value << ".withName(\"" << name << "\")";
            name = "$cys" + name;
            flags = CYBridgeType;
        } break;

        case CXCursor_TypedefDecl: {
            CYLocalPool local;

            CYType *typed(CYDecodeType(clang_getTypedefDeclUnderlyingType(cursor)));
            if (typed->specifier_ == NULL)
                value << "(typedef " << CYCXString(clang_getTypeSpelling(clang_getTypedefDeclUnderlyingType(cursor))) << ")";
            else {
                CYOptions options;
                CYOutput out(*value.rdbuf(), options);
                CYTypeExpression(typed).Output(out, CYNoBFC);
            }
        } break;

        case CXCursor_FunctionDecl:
        case CXCursor_VarDecl: {
            std::string label;

            CYList<CYFunctionParameter> parameters;
            CYStatement *code(NULL);

            CYLocalPool local;

            CYForChild(cursor, fun([&](CXCursor child) {
                switch (CXCursorKind kind = clang_getCursorKind(child)) {
                    case CXCursor_AsmLabelAttr:
                        label = CYCXString(child);
                        break;

                    case CXCursor_CompoundStmt:
                        code = CYTranslateBlock(unit, child);
                        break;

                    case CXCursor_ParmDecl:
                        parameters->*$P($B($I(CYCXString(child).Pool($pool))));
                        break;

                    case CXCursor_IntegerLiteral:
                    case CXCursor_ObjCClassRef:
                    case CXCursor_TypeRef:
                    case CXCursor_UnexposedAttr:
                        break;

                    default:
                        //std::cerr << "A:" << CYCXString(child) << std::endl;
                        break;
                }
            }));

            if (label.empty()) {
                label = spelling;
                label = '_' + label;
            } else if (label[0] != '_')
                goto skip;

            if (code == NULL) {
                value << "*";
                CXType type(clang_getCursorType(cursor));
                CYType *typed(CYDecodeType(type));
                CYOptions options;
                CYOutput out(*value.rdbuf(), options);
                CYTypeExpression(typed).Output(out, CYNoBFC);
                value << ".pointerTo()(dlsym(RTLD_DEFAULT,'" << label.substr(1) << "'))";
            } else {
                CYOptions options;
                CYOutput out(*value.rdbuf(), options);
                CYFunctionExpression *function($ CYFunctionExpression(NULL, parameters, code));
                function->Output(out, CYNoBFC);
                //std::cerr << value.str() << std::endl;
            }
        } break;

        default:
            result = CXChildVisit_Recurse;
            goto skip;
        break;
    } {
        CYKey &key(baton.keys[name]);
        if (key.priority_ <= priority) {
            key.priority_ = priority;
            key.code_ = value.str();
            key.flags_ = flags;
        }
    } } catch (const CYException &error) {
        CYPool pool;
        //std::cerr << error.PoolCString(pool) << std::endl;
    }

  skip:
    return result;
}

int main(int argc, const char *argv[]) {
    CXIndex index(clang_createIndex(0, 0));

    const char *file(argv[1]);

    unsigned offset(2);

    CXTranslationUnit unit(clang_parseTranslationUnit(index, file, argv + offset, argc - offset, NULL, 0, CXTranslationUnit_DetailedPreprocessingRecord));

    for (unsigned i(0), e(clang_getNumDiagnostics(unit)); i != e; ++i) {
        CXDiagnostic diagnostic(clang_getDiagnostic(unit, i));
        CYCXString spelling(clang_getDiagnosticSpelling(diagnostic));
        std::cerr << spelling << std::endl;
    }

    CYKeyMap keys;
    CYChildBaton baton(unit, keys);
    clang_visitChildren(clang_getTranslationUnitCursor(unit), &CYChildVisit, &baton);

    for (CYKeyMap::const_iterator key(keys.begin()); key != keys.end(); ++key) {
        std::string code(key->second.code_);
        for (size_t i(0), e(code.size()); i != e; ++i)
            if (code[i] <= 0 || code[i] >= 0x7f || code[i] == '\n')
                goto skip;
        std::cout << key->first << "|" << key->second.flags_ << "\"" << code << "\"" << std::endl;
    skip:; }

    clang_disposeTranslationUnit(unit);
    clang_disposeIndex(index);

    return 0;
}
