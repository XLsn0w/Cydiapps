//
//  SiriObjects.h
//  AssistantExtensions
//	Version 1.0.2-1
//
//  Created by K3A.
//  Copyright (c) 2012 K3A.me. All rights reserved.
//
#pragma once
#include <Foundation/Foundation.h>

#ifdef SC_PRIVATE
# import "SiriObjects_private.h"
#endif

/// A structure representing location data (user position)
typedef struct 
{
    /// You should check this value. 
    /// False here means that location data are not available or your extensions is not permitted to access them.
    bool    valid; 
    float   altitude;
    float   direction;
    float   longitude;
    int     age;
    float   speed;
    float   latitude;
    float   verticalAccuracy;
    float   horizontalAccuracy;
    unsigned long timestamp;
} SOLocationData;

/// A protocol specifying methods of pattern match.
@protocol AEPatternMatch <NSObject>
@required
/// The Siri language selected at the time of input recognition was received 
-(NSString*)language;
/// The complete input phrase
-(NSString*)text;
/// Tokens of the input phrase
-(NSArray*)tokens;
/// A set of tokens of the input phrase
-(NSSet*)tokenSet;
/// User-supplied data
-(id)userInfo;

/// Returns a value of named element
-(NSString*)namedElement:(NSString*)name;
/// Returns a value of idexed element
-(NSString*)elementAtIndex:(unsigned)idx;
-(NSString*)firstElement;
-(NSString*)secondElement;
-(NSString*)thirdElement;
-(NSString*)fourthElement;
@end


/// Ordinary assistant object dictionary (NSMutableDictionary) containing class name, group and properties.
/// The dictionary is by default not deep-mutable, so you can change values for keys in this dictionary only.
typedef NSMutableDictionary SOObject;
/// Root assistant object (NSMutableDictionary). Like SOObject but also with aceId and refId in addition to the class, group and properties.
typedef SOObject SOAceObject; 

@protocol SECommand;
@protocol SESystem;


/** Protocol specifying methods for handling one concrete request.
 An object of an class conforming to this protocol is passed to handleSpeech in SECommand classes. */
@protocol SEContext <NSObject>
@required
/** Creates a dictionary representing an ordinary assistant object (does not send it yet)
 \param className Name of the class
 \param group Name of the object group
 \param props Properties of the object
 */
-(SOObject*)createObjectDict:(NSString*)className group:(NSString*)group properties:(NSDictionary*)props;

/** Creates a dictionary representing utterance view
 \param text A text to show and speak
 */
-(SOObject*)createAssistantUtteranceView:(NSString*)text;
/** Creates a dictionary representing utterance view
 \param text A text to show
 \param speakableText A text to speak
 */
-(SOObject*)createAssistantUtteranceView:(NSString*)text speakableText:(NSString*)speakableText;
/** Creates a dictionary representing utterance view
 \param text A text to show
 \param speakableText A text to speak
 \param dialogIdentifier Dialog identifier
 */
-(SOObject*)createAssistantUtteranceView:(NSString*)text speakableText:(NSString*)speakableText dialogIdentifier:(NSString*)dialogIdentifier;
/** Creates a dictionary representing a snippet
 \param snippetClass Name of the snippet class
 \param props Dictionary of snippet properties
 */
-(SOObject*)createSnippet:(NSString*)snippetClass properties:(NSDictionary*)props;

/** Sends a root assistant object to the client
 */
-(BOOL)sendAceObject:(NSString*)className group:(NSString*)group properties:(NSDictionary*)props;

/** Sends "request completed" to the client
 */
-(BOOL)sendRequestCompleted;

/** Sends AddViews ace command to the client
 \param views Array of views to send
 */
-(BOOL)sendAddViews:(NSArray*)views;

/** Sends AddViews ace command to the client
 \param views Array of views to send
 \param dialogPhase Dialog phase, e.g. Reflection (will be replaced), Completion, Summary, Clarification, Error, Acknowledgement
 \param scrollToTop Should scroll to top
 \param temporary Temporary flag
 */
-(BOOL)sendAddViews:(NSArray*)views dialogPhase:(NSString*)dialogPhase scrollToTop:(BOOL)scrollToTop temporary:(BOOL)temporary;

/** Create a snippet and send it immediately to the client
 \param snippetClass Name of the snippet class
 \param props Properties for the snippet class
 */
-(BOOL)sendAddViewsSnippet:(NSString*)snippetClass properties:(NSDictionary*)props;
/** Create a snippet and send it immediately to the client
 \param snippetClass Name of the snippet class
 \param properties Properties for the snippet class
 \param dialogPhase Dialog phase, e.g. Reflection (will be replaced), Completion, Summary, Clarification, Error, Acknowledgement
 \param scrollToTop Should scroll to top
 \param temporary Temporary flag
 */
-(BOOL)sendAddViewsSnippet:(NSString*)snippetClass properties:(NSDictionary*)props dialogPhase:(NSString*)dialogPhase scrollToTop:(BOOL)scrollToTop temporary:(BOOL)temporary;

/** Create utterance (text) and send it immediately to the client
 \param text Text to send
 */
-(BOOL)sendAddViewsUtteranceView:(NSString*)text;
/** Create utterance (text) and send it immediately to the client
 \param text Text to send
 \param speakableText Text to speak (different from what is displayed)
 */
-(BOOL)sendAddViewsUtteranceView:(NSString*)text speakableText:(NSString*)speakableText;
/** Create utterance (text) and send it immediately to the client
 \param text Text to send
 \param speakableText Text to speak (different from what is displayed)
 \param dialogPhase Dialog phase, e.g. Reflection (will be replaced), Completion, Summary, Clarification, Error, Acknowledgement
 */
-(BOOL)sendAddViewsUtteranceView:(NSString*)text speakableText:(NSString*)speakableText dialogPhase:(NSString*)dialogPhase scrollToTop:(BOOL)scrollToTop temporary:(BOOL)temporary;
/** Create utterance (text) and send it immediately to the client
 \param text Text to send
 \param speakableText Text to speak (different from what is displayed)
 \param dialogPhase Dialog phase, e.g. Reflection (will be replaced), Completion, Summary, Clarification, Error, Acknowledgement
 \param listen Whether to listen for user response just after speaking the text. If YES, next request will be sent to the same SECommand.
 \since 1.0.1
 */
-(BOOL)sendAddViewsUtteranceView:(NSString*)text speakableText:(NSString*)speakableText dialogPhase:(NSString*)dialogPhase scrollToTop:(BOOL)scrollToTop temporary:(BOOL)temporary listenAfterSpeaking:(BOOL)listen; //SINCE 1.0.1

/** Returns the most recent location data.
 \param show If TRUE, may show "Getting your current location..." reflection if location is not yet cached. Default TRUE.
 \since 1.0.2
 */
-(SOLocationData)getLocationDataShowReflection:(BOOL)show; //SINCE 1.0.2

/** Sends the object to the client (assistant). 
 Normally should be used only inside clientToServerObject/serverToClientObject methods. 
 \param obj The object to send
 \since 1.0.2
 */
-(BOOL)sendAceObjectToClient:(SOAceObject*)obj; //SINCE 1.0.2
/** Sends the object to the server (remote side). 
 Normally should be used only inside clientToServerObject/serverToClientObject methods. 
 \param obj The object to send
 \since 1.0.2
 */
-(BOOL)sendAceObjectToServer:(SOAceObject*)obj; //SINCE 1.0.2
/** Blocks the rest of communication for the request represented by this context (both ways).
 This means that the extension will handle everything to serve the rest of the request.
 Normally should be used only inside clientToServerObject/serverToClientObject methods. 
 \param obj The object to send
 \since 1.0.2
 */ 
-(void)blockRestOfRequest; //SINCE 1.0.2

/** Request exclusive mode which will cause to send all future requests to commands class from which this method was called. Exclusive mode can be ended by calling endExclusiveMode or dismissing the assistant.
 \since 1.0.2
 */
-(void)beginExclusiveMode;

/** Ends the exclusive mode. 
 \since 1.0.2
 */
-(void)endExclusiveMode;

/** Hides assistant. This is needed for openURL with "xxx://" schemes, while "xxx:" schems doesn't need this. */
-(void)dismissAssistant;//SINCE 1.0.2

/** Returns a boolean indicating whether the current request has been completed (by calling sendRequestCompleted). */
-(BOOL)requestHasCompleted;

/** Returns an object which handled the request or nil if the request has not been handled yet. */
-(NSObject<SECommand>*)object;

/** Returns a string with refId of the current request. */
-(NSString*)refId;
@end
// --- end of SEContext ---


/** Protocol specifying methods of an extension class representing snippet.
 Instances of these classes will be created for every snippet creation request.
 A class representing snippet can derive from UIView or just represent some proxy class creating it's UIView on demand.
 Don't forget you really should prefix your class with some shortcut, e.g. K3AAwesomeSnippet!
 */
@protocol SESnippet <NSObject>
@optional
/// Initializes a snippet by properties 
-(id)initWithProperties:(NSDictionary*)props;
/// Initializes a snippet by properties and system
-(id)initWithProperties:(NSDictionary*)props system:(id<SESystem>)system;
/// Returns a view representing snippet, can be self if the conforming class is already UIView
-(id)view;
@end




/** Protocol specifying methods for manipulation with AssistantExtension core, an object conforming to this protocol is is passed via initWithSystem to NSPrincipal class of the extension.
 */
@protocol SESystem <NSObject>
@required
/// Register a command class
-(BOOL)registerCommand:(Class)cls;
/// Register a snippet class
-(BOOL)registerSnippet:(Class)cls;

/** Filter classes which can be sent to clientToServerObject. If this method is not called, all classes will be sent so that the extension can handle every packet of the communication. It's recommended to use this method if you are modifying only one or few classes.
 \param allowedClasses An array of NSString* objects representing class names of objects.
 \since 1.0.2
 */
-(BOOL)setClientToServerFilter:(NSArray*)allowedClasses; //SINCE 1.0.2
/** Filter classes which can be sent to serverToClientObject. If this method is not called, all classes will be sent so that the extension can handle every packet of the communication. It's recommended to use this method if you are modifying only one or few classes.
 \param allowedClasses An array of NSString* objects representing class names of objects.
 \since 1.0.2
 */
-(BOOL)setServerToClientFilter:(NSArray*)allowedClasses; //SINCE 1.0.2

/** Returns the localized version of the input string in currently selected Siri language. 
 If language strings are not defined for that language, input string will be returned as is, or If language strings are defined for English, those will be used.
 \param text Text to translate.
 \since 1.0.2
 */
-(NSString*)localizedString:(NSString*)text; //SINCE 1.0.2
/** Returns the localized version of the input string in specified language. 
 If language strings are not defined for that language, input string will be returned as is, or If language strings are defined for English, those will be used.
 \param text Text to translate.
 \param lang Language code.
 \since 1.0.2
 */
-(NSString*)localizedString:(NSString*)text inLanguage:(NSString*)lang; //SINCE 1.0.2

/** Removes all previously registered patterns for the current extension. 
 \since 1.0.2
 */ 
-(void)removeAllPatterns;

/** Registers the AEX pattern. This method should be called only from patternsForLang:inSystem: method of commands class.
 \param text Text to translate.
 \param target An object to call selector on when the pattern is matched.
 \param sel A selector to use, default handlePatternMatch:context:.
 \param user User-supplied NSObject pointer with any data. Can be nil.
 \since 1.0.2
 */
-(BOOL)registerPattern:(NSString*)pattern target:(id)target selector:(SEL)sel userInfo:(id)user; //SINCE 1.0.2
-(BOOL)registerPattern:(NSString*)pattern target:(id)target selector:(SEL)sel; //SINCE 1.0.2
-(BOOL)registerPattern:(NSString*)pattern selector:(SEL)sel userInfo:(id)user; //SINCE 1.0.2
-(BOOL)registerPattern:(NSString*)pattern selector:(SEL)sel; //SINCE 1.0.2
-(BOOL)registerPattern:(NSString*)pattern userInfo:(id)user; //SINCE 1.0.2
-(BOOL)registerPattern:(NSString*)pattern; //SINCE 1.0.2

/** Registers the pattern defined in Patterns.plist file located in language directory of the current Siri language. If the Patterns.plist file is not found in the directory for current Siri language, AE will look for it in "en" directory. If not found there as well, it will look for it in the extension bundle (so that it can be used for every language). 
 This method should be called only from patternsForLang:inSystem: method of commands class.
 \param name Name of the pattern in the Patterns.plist file.
 \param target An object to call selector on when the pattern is matched.
 \param sel A selector to use, default handlePatternMatch:context:.
 \param user User-supplied NSObject pointer with any data. Can be nil.
 \since 1.0.2
 */
-(BOOL)registerNamedPattern:(NSString*)name target:(id)target selector:(SEL)sel userInfo:(id)user; //SINCE 1.0.2
-(BOOL)registerNamedPattern:(NSString*)name target:(id)target selector:(SEL)sel; //SINCE 1.0.2
-(BOOL)registerNamedPattern:(NSString*)name selector:(SEL)sel userInfo:(id)user; //SINCE 1.0.2
-(BOOL)registerNamedPattern:(NSString*)name selector:(SEL)sel; //SINCE 1.0.2
-(BOOL)registerNamedPattern:(NSString*)name userInfo:(id)user; //SINCE 1.0.2
-(BOOL)registerNamedPattern:(NSString*)name; //SINCE 1.0.2

/** Registers all patterns defined in Patterns.plist file located in language directory of the current Siri language. If the Patterns.plist file is not found in the directory for current Siri language, AE will look for it in "en" directory. If not found there as well, it will look for it in the extension bundle (so that it can be used for every language). 
 This method should be called only from patternsForLang:inSystem: method of commands class.
 \param target An object to call selector on when the pattern is matched.
 \param sel A selector to use, default handlePatternMatch:context:.
 \param user User-supplied NSObject pointer with any data. Can be nil.
 \since 1.0.2
 */
-(BOOL)registerAllNamedPatternsForTarget:(id)target selector:(SEL)sel userInfo:(id)user;
-(BOOL)registerAllNamedPatternsForTarget:(id)target selector:(SEL)sel;
-(BOOL)registerAllNamedPatternsForSelector:(SEL)sel userInfo:(id)user;
-(BOOL)registerAllNamedPatternsForSelector:(SEL)sel;
-(BOOL)registerAllNamedPatternsWithUserInfo:(id)user;
-(BOOL)registerAllNamedPatterns;


/// Returns the version string of AssistantExtensions
-(NSString*)systemVersion; //SINCE 1.0.1
@end




/** Protocol specifying methods of an extension class handling commands.
 Classes conforming to this protocol are initialized just after loading bundle and will remain in memory.
 Don't forget you really should prefix your class with some shortcut, e.g. K3AAwesomeCommand!
 */
@protocol SECommand <NSObject>
@optional
/** Allows the extension to react to recognized text.
 \param text Recognized text
 \param tokens An ordered array of lowercase tokens representing recognized words
 \param tokenset An unordered set of tokens for fast search - recommended parameter for keyword-matching
 \param ctx Context representing the current request also allowing to send responses
 */
-(BOOL)handleSpeech:(NSString*)text tokens:(NSArray*)tokens tokenSet:(NSSet*)tokenset context:(id<SEContext>)ctx;

/** Default method for handling pattern match. Can be different depending on which registration method was used. 
 \param match Pattern match result, can be nil when called for the second time (e.g. after "listenAfterSpeaking" request).
 \param ctx Context representing the current request also allowing to send responses.
 */
-(BOOL)handlePatternMatch:(id<AEPatternMatch>)match context:(id<SEContext>)ctx;

/** Allows the extension to register recognition patterns for the specified language.
 This is the preferred way for handling the recognized text. If implemented in the class, this method will be called after init/initWithSystem as well as after the user changes Siri language. You have to use supplied system pointer to register patterns. All previous patterns (registered for previous language) will be removed before calling this method.
 \param lang Language code of the currently selected Siri language.
 \param system The system pointer used for registering patterns. The same as the one passed by initWithSystem.
 */
-(void)patternsForLang:(NSString*)lang inSystem:(id<SESystem>)system;

/** If this method is implemented, it will be called instead of "init" method. The supplied SESystem is the same as the one used for initializing SEExtension and remain the same for the life of your extension.
 \since 1.0.2
 */
-(id)initWithSystem:(id<SESystem>)system;

/** Will be called after the user dismisses the assistant. 
 Used mostly for cleaning up changes in system like removing additional view controllers.
 \since 1.0.2
 */
-(void)assistantDismissed;

@end




/// Protocol specifying methods of the extension's principal class
@protocol SEExtension <NSObject>

@required
/// The first method which is called on your class, system is where you register commands and snippets
-(id)initWithSystem:(id<SESystem>)system;

@optional
/** Optional method for intercepting and modifying client-to-servrer communication.
 You should not need this and you should not use it unless you are sure what you are doing.
 If your extension implements this method, it will be called each time a new object is about to be sent.
 The object is passed as a deep-mutable dictionary (=deep-mutable SOObject), so you can modify it's keys/values as well as keys/values of all sub-dictionaries and sub-arrays and return modified.
 If this method returns nil, the original object will not be sent.
 If you need to block the rest of communication for that particular request, call [ctx sendRequestCompleted];
 If you need to handle only a few specific classes, set filter by calling setServerToClientFilter on SESystem (in initWithSystem).
 \param dict An object to be sent from the client to the server
 \param ctx A context (request) for which the communication is happening
 \since 1.0.2
 */
-(SOObject*)clientToServerObject:(SOObject*)dict context:(id<SEContext>)ctx;
/** Optional method for intercepting and modifying client-to-servrer communication.
 You should not need this and you should not use it unless you are sure what you are doing.
 If your extension implements this method, it will be called each time a new object is about to be sent.
 The object is passed as a deep-mutable dictionary (=deep-mutable SOObject), so you can modify it's keys/values as well as keys/values of all sub-dictionaries and sub-arrays and return modified.
 If this method returns nil, the original object will not be sent.
 If you need to block the rest of communication for that particular request, call [ctx sendRequestCompleted];
 If you need to handle only a few specific classes, set filter by calling setServerToClientFilter on SESystem (in initWithSystem).
 \param dict An object to be sent from the server to the client
 \param ctx A context (request) for which the communication is happening
 \since 1.0.2
 */
-(SOObject*)serverToClientObject:(SOObject*)dict context:(id<SEContext>)ctx;

/**  Extension author 
 \deprecated Since 1.0.2, developers should use Info.plist of an extension for specifying those metadata.
 */
-(NSString*)author;
/**  Extension name 
 \deprecated Since 1.0.2, developers should use Info.plist of an extension for specifying those metadata.
 */
-(NSString*)name;
/**  Extension description 
 \deprecated Since 1.0.2, developers should use Info.plist of an extension for specifying those metadata.
 */
-(NSString*)description;
/**  Extension website URL 
 \deprecated Since 1.0.2, developers should use Info.plist of an extension for specifying those metadata.
 */
-(NSString*)website;
/** Minimal SiriExtensions version requirement 
 \since 1.0.1
 \deprecated Since 1.0.2, developers should use Info.plist of an extension for specifying those metadata.
 */
-(NSString*)versionRequirement;

@optional
/** Will be called after the user dismisses the assistant.
 Used mostly for cleaning up changes in system like removing additional view controllers.
 \since 1.0.2
 */
-(void)assistantDismissed;

/** Will be called after the assistant is activated.
 \since 1.0.2
 */
-(void)assistantActivatedWithContext:(id<SEContext>)ctx;

@end
// vim:ft=objc
