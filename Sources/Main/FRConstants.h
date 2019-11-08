/*
 * Copyright 2008-2017, Torsten Curdt
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// String. URL where to POST results to. Any occurance of "%@" in the string
// will be replaced with the value of CFBundleExecutable from the Info.plist.
// If nothing is specified, you must instead implement the targetUrlForFeedbackReport
// delegate message. (optional)
#define PLIST_KEY_TARGETURL             @"FRFeedbackReporter.targetURL"

// Integer. Truncates the console log to not send more than x hours into the past.
// If nothing is specified, defaults to 24 hours. (optional)
#define PLIST_KEY_LOGHOURS              @"FRFeedbackReporter.logHours"

// String. The default e-mail address to select in case there is no selection saved in
// the preferences. The options are 'anonymous' and 'firstEmail'. If nothing
// is specified, 'anonymous' is selected. (optional)
#define PLIST_KEY_DEFAULTSENDER         @"FRFeedbackReporter.defaultSender"

// Integer. The number of characters a console log is truncated to. If not specified,
// no truncation takes place. (optional)
#define PLIST_KEY_MAXCONSOLELOGSIZE     @"FRFeedbackReporter.maxConsoleLogSize"

// Integer. The maximum number of bytes that the HTTP POST can contain. If not specified,
// a maximum of 100 megabytes is used. (optional)
#define PLIST_KEY_MAXPOSTSIZE           @"FRFeedbackReporter.maxPOSTSize"

// String. Set the value of this key to 'YES' to present a checkbox where the user
// can switch on and off the sending of details information. If not specified,
// defaults to 'NO', hence no checkbox is shown.
// If the user checks off the 'send details' option, just the e-mail address,
// the comment, the type of report, and the application version are transmitted
// to the server. (optional)
#define PLIST_KEY_SENDDETAILSISOPTIONAL @"FRFeedbackReporter.sendDetailsIsOptional"

// String. If set to 'YES' the application will exit after an exception has been caught.
// If not specified, defaults to 'NO'. (optional)
#define PLIST_KEY_EXITAFTEREXCEPTION    @"FRFeedbackReporter.exitAfterException"


// Keys stored in the user defaults.
#define DEFAULTS_KEY_LASTCRASHCHECKDATE @"FRFeedbackReporter.lastCrashCheckDate"
#define DEFAULTS_KEY_LASTSUBMISSIONDATE @"FRFeedbackReporter.lastSubmissionDate"
#define DEFAULTS_KEY_SENDEREMAIL        @"FRFeedbackReporter.sender"


// POST fields filled by default.
// If you want to add custom ones, see the customParametersForFeedbackReport: delegate message.
#define POST_KEY_TYPE           @"type"
#define POST_KEY_EMAIL          @"email"
#define POST_KEY_MESSAGE        @"comment"
#define POST_KEY_SYSTEM         @"system"
#define POST_KEY_CONSOLE        @"console"
#define POST_KEY_CRASHES        @"crashes"
#define POST_KEY_SHELL          @"shell"
#define POST_KEY_PREFERENCES    @"preferences"
#define POST_KEY_EXCEPTION      @"exception"
#define POST_KEY_VERSION_SHORT  @"version_short"  // Corresponds to CFBundleShortVersionString.
#define POST_KEY_VERSION_BUNDLE @"version_bundle" // Corresponds to CFBundleVersion.
#define POST_KEY_VERSION        @"version"        // Above 2 combined as "CFBundleShortVersionString (CFBundleVersion)"
