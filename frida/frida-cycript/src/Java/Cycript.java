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

import java.lang.reflect.Field;
import java.lang.reflect.InvocationHandler;
import java.lang.reflect.Method;
import java.lang.reflect.Proxy;

public class Cycript {

public static Method GetMethod(Class<?> type, String name, Class... types) {
    try {
        return type.getMethod(name, types);
    } catch (NoSuchMethodException e) {
        throw new RuntimeException();
    }
}

public static final Method Object$equals = GetMethod(Object.class, "equals", Object.class);
public static final Method Object$hashCode = GetMethod(Object.class, "hashCode");

public static native void delete(long protect);

public static native Object handle(long protect, String property, Object[] arguments)
    throws Throwable;

public static class Wrapper
    extends RuntimeException
    implements InvocationHandler
{
    private long protect_;

    public Wrapper(long protect) {
        protect_ = protect;
    }

    protected void finalize()
        throws Throwable
    {
        delete(protect_);
    }

    public long getProtect() {
        return protect_;
    }

    public Object call(String property, Object[] arguments) {
        try {
            return handle(protect_, property, arguments);
        } catch (Throwable throwable) {
            return new RuntimeException(throwable);
        }
    }

    public String toString() {
        return call("toString", null).toString();
    }

    public Object invoke(Object proxy, Method method, Object[] args)
        throws Throwable
    {
        if (false)
            return null;
        else if (method.equals(Object$equals))
            // XXX: this assumes there is only one proxy
            return proxy == args[0];
        else if (method == Object$hashCode)
            // XXX: this assumes there is only one wrapper
            return hashCode();
        else
            return handle(protect_, method.getName(), args);
    }
}

public static Object proxy(Class proxy, Wrapper wrapper) {
    return Proxy.newProxyInstance(proxy.getClassLoader(), new Class[] {proxy}, wrapper);
}

}
