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

#ifndef CYCRIPT_JAVASCRIPT_HPP
#define CYCRIPT_JAVASCRIPT_HPP

#include <set>
#include <string>

#include "Pooling.hpp"
#include "String.hpp"
#include "Utility.hpp"

const char *CYExecute(CYPool &pool, CYUTF8String code);
void CYCancel();

void CYAttach(const char *device_id, const char *host, const char *target);
void CYDetach();
void CYSetArgs(const char *argv0, const char *script, int argc, const char *argv[]);
void CYGarbageCollect();
void CYDestroyContext();

#endif/*CYCRIPT_JAVASCRIPT_HPP*/
