/* XXX: this message is ultra-lame */
var _assert = function (expr, value) {
    if (!expr) {
        var message = "_assert(" + value + ")";
        console.log(message);
        throw message;
    }
}

// Compatibility {{{
if (typeof Array.prototype.push != "function")
    Array.prototype.push = function (value) {
        this[this.length] = value;
    };
// }}}

var $ = function (arg, doc) {
    if (this.magic_ != $.prototype.magic_)
        return new $(arg);

    if (arg == null)
        arg = [];

    var type = $.type(arg);

    if (type == "function")
        $.ready(arg);
    else if (type == "string") {
        if (typeof doc == 'undefined')
            doc = document;
        if (arg.charAt(0) == '#') {
            /* XXX: this is somewhat incorrect-a-porter */
            var element = doc.getElementById(arg.substring(1));
            return $(element == null ? [] : [element]);
        } else if (arg.charAt(0) == '.')
            return $(doc.getElementsByClassName(arg.substring(1)));
        else
            return $([doc]).descendants(arg);
    } else if (typeof arg.length != 'undefined') {
        _assert(typeof doc == 'undefined', "non-query with document to $");
        this.set(arg);
        return this;
    } else _assert(false, "unknown argument to $: " + typeof arg);
};

$.xml = function (value) {
    return value
        .replace(/&/, "&amp;")
        .replace(/</, "&lt;")
        .replace(/>/, "&gt;")
        .replace(/"/, "&quot;")
        .replace(/'/, "&apos;")
    ;
}

$.type = function (value) {
    var type = typeof value;

    if ((type == "function" || type == "object") && value.toString != null) {
        var string = value.toString();
        if (string.substring(0, 8) == "[object ")
            return string.substring(8, string.length - 1);
    }

    return type;
};

(function () {
    var ready_ = null;

    $.ready = function (_function) {
        if (ready_ == null) {
            ready_ = [];

            document.addEventListener("DOMContentLoaded", function () {
                for (var i = 0; i != ready_.length; ++i)
                    ready_[i]();
            }, false);
        }

        ready_.push(_function);
    };
})();

/* XXX: verify arg3 overflow */
$.each = function (values, _function, arg0, arg1, arg2) {
    for (var i = 0, e = values.length; i != e; ++i)
        _function(values[i], arg0, arg1, arg2);
};

/* XXX: verify arg3 overflow */
$.map = function (values, _function, arg0, arg1, arg2) {
    var mapped = [];
    for (var i = 0, e = values.length; i != e; ++i)
        mapped.push(_function(values[i], arg0, arg1, arg2));
    return mapped;
};

$.array = function (values) {
    if (values.constructor == Array)
        return values;
    _assert(typeof values.length != 'undefined', "$.array on underlying non-array");
    var array = [];
    for (var i = 0; i != values.length; ++i)
        array.push(values[i]);
    return array;
};

$.document = function (node) {
    for (;;) {
        var parent = node.parentNode;
        if (parent == null)
            return node;
        node = parent;
    }
};

$.reclass = function (_class) {
    return new RegExp('(\\s|^)' + _class + '(\\s|$)');
};

$.prototype = {
    magic_: 2041085062,

    add: function (nodes) {
        Array.prototype.push.apply(this, $.array(nodes));
    },

    at: function (name, value) {
        if (typeof value == 'undefined')
            return $.map(this, function (node) {
                return node.getAttribute(name);
            });
        else if (value == null)
            $.each(this, function (node) {
                node.removeAttribute();
            });
        else
            $.each(this, function (node) {
                node.setAttribute(name, value);
            });
    },

    set: function (nodes) {
        this.length = 0;
        this.add(nodes);
    },

    /* XXX: verify arg3 overflow */
    each: function (_function, arg0, arg1, arg2) {
        $.each(this, function (node) {
            _function($([node]), arg0, arg1, arg2);
        });
    },

    css: function (name, value) {
        $.each(this, function (node) {
            node.style[name] = value;
        });
    },

    addClass: function (_class) {
        $.each(this, function (node) {
            if (!$([node]).hasClass(_class)[0])
                node.className += " " + _class;
        });
    },

    blur: function () {
        $.each(this, function (node) {
            node.blur();
        });
    },

    focus: function () {
        $.each(this, function (node) {
            node.focus();
        });
    },

    removeClass: function (_class) {
        $.each(this, function (node) {
            node.className = node.className.replace($.reclass(_class), ' ');
        });
    },

    hasClass: function (_class) {
        return $.map(this, function (node) {
            return node.className.match($.reclass(_class));
        });
    },

    append: function (children) {
        if ($.type(children) == "string")
            $.each(this, function (node) {
                var doc = $.document(node);

                // XXX: implement wrapper system
                var div = doc.createElement("div");
                div.innerHTML = children;

                while (div.childNodes.length != 0) {
                    var child = div.childNodes[0];
                    node.appendChild(child);
                }
            });
        else
            $.each(this, function (node) {
                $.each(children, function (child) {
                    node.appendChild(child);
                });
            });
    },

    xpath: function (expression) {
        var value = $([]);

        $.each(this, function (node) {
            var doc = $.document(node);
            var results = doc.evaluate(expression, node, null, XPathResult.ANY_TYPE, null);
            var result;
            while (result = results.iterateNext())
                value.add([result]);
        });

        return value;
    },

    clone: function (deep) {
        return $($.map(this, function (node) {
            return node.cloneNode(deep);
        }));
    },

    descendants: function (expression) {
        var descendants = $([]);

        $.each(this, function (node) {
            var nodes = node.getElementsByTagName(expression);
            descendants.add(nodes);
        });

        return descendants;
    },

    remove: function () {
        $.each(this, function (node) {
            node.parentNode.removeChild(node);
        });
    }
};

$.scroll = function (x, y) {
    window.scrollTo(x, y);
};

// XXX: document.all?
$.all = function (doc) {
    if (typeof doc == 'undefined')
        doc = document;
    return $(doc.getElementsByTagName("*"));
};

$.inject = function (a, b) {
    if ($.type(a) == "string") {
        $.prototype[a] = function (value) {
            if (typeof value == 'undefined')
                return $.map(this, function (node) {
                    return b.get(node);
                });
            else
                $.each(this, function (node, value) {
                    b.set(node, value);
                }, value);
        };
    } else for (var name in a)
        $.inject(name, a[name]);
};

$.inject({
    _default: {
        get: function (node) {
            return node.style.defaultValue;
        },
        set: function (node, value) {
            node.style.defaultValue = value;
        }
    },

    height: {
        get: function (node) {
            return node.height;
        },
        set: function (node, value) {
            node.height = value;
        }
    },

    html: {
        get: function (node) {
            return node.innerHTML;
        },
        set: function (node, value) {
            node.innerHTML = value;
        }
    },

    href: {
        get: function (node) {
            return node.href;
        },
        set: function (node, value) {
            node.href = value;
        }
    },

    name: {
        get: function (node) {
            return node.name;
        },
        set: function (node, value) {
            node.name = value;
        }
    },

    parent: {
        get: function (node) {
            return node.parentNode;
        }
    },

    src: {
        get: function (node) {
            return node.src;
        },
        set: function (node, value) {
            node.src = value;
        }
    },

    type: {
        get: function (node) {
            return node.localName;
        }
    },

    value: {
        get: function (node) {
            return node.value;
        },
        set: function (node, value) {
            // XXX: do I really need this?
            if (true || node.localName != "select")
                node.value = value;
            else {
                var options = node.options;
                for (var i = 0, e = options.length; i != e; ++i)
                    if (options[i].value == value) {
                        if (node.selectedIndex != i)
                            node.selectedIndex = i;
                        break;
                    }
            }
        }
    },

    width: {
        get: function (node) {
            return node.offsetWidth;
        }
    }
});

// Query String Parsing {{{
$.query = function () {
    var args = {};

    var search = location.search;
    if (search != null) {
        _assert(search[0] == "?", "query string without ?");

        var values = search.substring(1).split("&");
        for (var index in values) {
            var value = values[index]
            var equal = value.indexOf("=");
            var name;

            if (equal == -1) {
                name = value;
                value = null;
            } else {
                name = value.substring(0, equal);
                value = value.substring(equal + 1);
                value = decodeURIComponent(value);
            }

            name = decodeURIComponent(name);
            if (typeof args[name] == "undefined")
                args[name] = [];
            if (value != null)
                args[name].push(value);
        }
    }

    return args;
};
// }}}
// Event Registration {{{
// XXX: unable to remove registration
$.prototype.event = function (event, _function) {
    $.each(this, function (node) {
        // XXX: smooth over this pointer ugliness
        if (node.addEventListener)
            node.addEventListener(event, _function, false);
        else if (node.attachEvent)
            node.attachEvent("on" + event, _function);
        else
            // XXX: multiple registration SNAFU
            node["on" + event] = _function;
    });
};

$.each([
    "click", "load", "submit"
], function (event) {
    $.prototype[event] = function (_function) {
        if (typeof _function == 'undefined')
            _assert(false, "undefined function to $.[event]");
        else
            this.event(event, _function);
    };
});
// }}}
// Timed Animation {{{
$.interpolate = function (duration, event) {
    var start = new Date();

    var next = function () {
        setTimeout(update, 0);
    };

    var update = function () {
        var time = new Date() - start;

        if (time >= duration)
            event(1);
        else {
            event(time / duration);
            next();
        }
    };

    next();
};
// }}}
// AJAX Requests {{{
// XXX: abstract and implement other cases
$.xhr = function (url, method, headers, data, events) {
    var xhr = new XMLHttpRequest();
    xhr.open(method, url, true);

    for (var name in headers)
        xhr.setRequestHeader(name.replace(/_/, "-"), headers[name]);

    if (events == null)
        events = {};

    xhr.onreadystatechange = function () {
        if (xhr.readyState == 4) {
            var status = xhr.status;
            var text = xhr.responseText;
            if (events.response != null)
                events.response(status, text);
            if (status == 200) {
                if (events.success != null)
                    events.success(text);
            } else {
                if (events.failure != null)
                    events.failure(status);
            }
        }
    };

    xhr.send(data);
};

$.call = function (url, post, onsuccess) {
    var events = {};

    if (onsuccess != null)
        events.complete = function (text) {
            onsuccess(eval(text));
        };

    if (post == null)
        $.xhr(url, "POST", null, null, events);
    else
        $.xhr(url, "POST", {
            Content_Type: "application/json"
        }, $.json(post), events);
};
// }}}
// WWW Form URL Encoder {{{
$.form = function (parameters) {
    var data = "";

    var ampersand = false;
    for (var name in parameters) {
        if (!ampersand)
            ampersand = true;
        else
            data += "&";

        var value = parameters[name];

        data += escape(name);
        data += "=";
        data += escape(value);
    }

    return data;
};
// }}}
// JSON Serializer {{{
$.json = function (value) {
    if (value == null)
        return "null";

    var type = $.type(value);

    if (type == "number")
        return value;
    else if (type == "string")
        return "\"" + value
            .replace(/\\/, "\\\\")
            .replace(/\t/, "\\t")
            .replace(/\r/, "\\r")
            .replace(/\n/, "\\n")
            .replace(/"/, "\\\"")
        + "\"";
    else if (value.constructor == Array) {
        var json = "[";
        var comma = false;

        for (var i = 0; i != value.length; ++i) {
            if (!comma)
                comma = true;
            else
                json += ",";

            json += $.json(value[i]);
        }

        return json + "]";
    } else if (
        value.constructor == Object &&
        value.toString() == "[object Object]"
    ) {
        var json = "{";
        var comma = false;

        for (var name in value) {
            if (!comma)
                comma = true;
            else
                json += ",";

            json += name + ":" + $.json(value[name]);
        }
        return json + "}";
    } else {
        return value;
    }
};
// }}}
