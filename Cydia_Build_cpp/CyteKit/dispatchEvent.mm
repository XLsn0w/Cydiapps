/* Cydia - iPhone UIKit Front-End for Debian APT
 * Copyright (C) 2008-2015  Jay Freeman (saurik)
*/

/* GNU General Public License, Version 3 {{{ */
/*
 * Cydia is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published
 * by the Free Software Foundation, either version 3 of the License,
 * or (at your option) any later version.
 *
 * Cydia is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Cydia.  If not, see <http://www.gnu.org/licenses/>.
**/
/* }}} */

#include "CyteKit/UCPlatform.h"

#include "CyteKit/dispatchEvent.h"
#include "CyteKit/WebThreadLocked.hpp"

#include "Substrate.hpp"

@implementation UIWebDocumentView (CyteDispatchEvent)

- (void) dispatchEvent:(NSString *)event {
    WebThreadLocked lock;

    NSString *script([NSString stringWithFormat:@
        "(function() {"
            "var event = this.document.createEvent('Events');"
            "event.initEvent('%@', false, false);"
            "this.document.dispatchEvent(event);"
        "})();"
    , event]);

    NSMutableArray *frames([NSMutableArray arrayWithObjects:
        [[self webView] mainFrame]
    , nil]);

    while (WebFrame *frame = [frames lastObject]) {
        WebScriptObject *object([frame windowObject]);
        [object evaluateWebScript:script];
        [frames removeLastObject];
        [frames addObjectsFromArray:[frame childFrames]];
    }
}

@end

MSHook(void, UIWebBrowserView$_webTouchEventsRecognized$, UIWebBrowserView *self, SEL _cmd, UIWebTouchEventsGestureRecognizer *recognizer) {
    _UIWebBrowserView$_webTouchEventsRecognized$(self, _cmd, recognizer);

    switch ([recognizer type]) {
        case WebEventTouchEnd:
            [self dispatchEvent:@"CydiaTouchEnd"];
        break;

        case WebEventTouchCancel:
            [self dispatchEvent:@"CydiaTouchCancel"];
        break;
    }
}

__attribute__((__constructor__)) static void $() {
    if (Class $UIWebBrowserView = objc_getClass("UIWebBrowserView")) {
        if (Method method = class_getInstanceMethod($UIWebBrowserView, @selector(_webTouchEventsRecognized:))) {
            _UIWebBrowserView$_webTouchEventsRecognized$ = reinterpret_cast<void (*)(UIWebBrowserView *, SEL, UIWebTouchEventsGestureRecognizer *)>(method_getImplementation(method));
            method_setImplementation(method, reinterpret_cast<IMP>(&$UIWebBrowserView$_webTouchEventsRecognized$));
        }
    }
}
