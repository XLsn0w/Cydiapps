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

#ifndef SIG_PARSE_H
#define SIG_PARSE_H

#include "Pooling.hpp"
#include "sig/types.hpp"

namespace sig {

typedef Type *(*Callback)(CYPool &pool, Aggregate *aggregate);
void Parse(CYPool &pool, struct Signature *signature, const char *name, Callback callback);

const char *Unparse(CYPool &pool, const struct Signature *signature);
const char *Unparse(CYPool &pool, const struct Type *type);

void Copy(CYPool &pool, Signature &lhs, const Signature &rhs);

}

#endif/*SIG_PARSE_H*/
