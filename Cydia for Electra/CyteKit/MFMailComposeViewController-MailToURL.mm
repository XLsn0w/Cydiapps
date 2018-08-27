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

#include "CyteKit/MFMailComposeViewController-MailToURL.h"

#include <objc/runtime.h>
#include <dlfcn.h>

static void $MFMailComposeViewController$setMailToURL$(MFMailComposeViewController *self, SEL _cmd, NSURL *url) {
    NSString *scheme([url scheme]);

    if (scheme == nil || ![[scheme lowercaseString] isEqualToString:@"mailto"])
        [NSException raise:NSInvalidArgumentException format:@"-[MFMailComposeViewController setMailToURL:] - non-mailto: URL"];

    NSString *href([url absoluteString]);
    NSRange question([href rangeOfString:@"?"]);

    NSMutableArray *to([NSMutableArray arrayWithCapacity:1]);

    NSString *target, *query;
    if (question.location == NSNotFound) {
        target = [href substringFromIndex:7];
        query = nil;
    } else {
        target = [href substringWithRange:NSMakeRange(7, question.location - 7)];
        query = [href substringFromIndex:(question.location + 1)];
    }

    if ([target length] != 0)
        [to addObject:target];

    if (query != nil && [query length] != 0) {
        NSMutableArray *cc([NSMutableArray arrayWithCapacity:1]);
        NSMutableArray *bcc([NSMutableArray arrayWithCapacity:1]);

        for (NSString *assign in [query componentsSeparatedByString:@"&"]) {
            NSRange equal([assign rangeOfString:@"="]);
            if (equal.location == NSNotFound)
                continue;

            NSString *name([assign substringToIndex:equal.location]);
            NSString *value([assign substringFromIndex:(equal.location + 1)]);
            value = [value stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

            if (false);
            else if ([name isEqualToString:@"attachment"]) {
                if (NSData *data = [NSData dataWithContentsOfFile:value])
                    [self addAttachmentData:data mimeType:@"application/octet-stream" fileName:[value lastPathComponent]];
            } else if ([name isEqualToString:@"bcc"])
                [bcc addObject:value];
            else if ([name isEqualToString:@"body"])
                [self setMessageBody:value isHTML:NO];
            else if ([name isEqualToString:@"cc"])
                [cc addObject:value];
            else if ([name isEqualToString:@"subject"])
                [self setSubject:value];
            else if ([name isEqualToString:@"to"])
                [to addObject:value];
        }

        [self setCcRecipients:cc];
        [self setBccRecipients:bcc];
    }

    [self setToRecipients:to];
}

__attribute__((__constructor__)) static void MFMailComposeViewController_CyteMailToURL() {
    dlopen("/System/Library/Frameworks/MessageUI.framework/MessageUI", RTLD_GLOBAL | RTLD_LAZY);
    if (Class MFMailComposeViewController = objc_getClass("MFMailComposeViewController"))
        class_addMethod(MFMailComposeViewController, @selector(setMailToURL:), (IMP) $MFMailComposeViewController$setMailToURL$, "v12@0:4@8");
}
