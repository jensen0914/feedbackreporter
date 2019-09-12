/*
 * Copyright 2008-2019, Torsten Curdt
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

#import "FRConsoleLog.h"
#import "FRConstants.h"
#import "FRApplication.h"

#import <asl.h>
#import <unistd.h>

#define FR_CONSOLELOG_TIME 0
#define FR_CONSOLELOG_TEXT 1

@implementation FRConsoleLog

+ (NSString*) logSince:(NSDate*)since maxSize:(nullable NSNumber*)maximumSize
{
    assert(since);

    NSUInteger consoleOutputLength = 0;
    NSUInteger rawConsoleLinesCapacity = 100;
    NSUInteger consoleLinesProcessed = 0;

    char ***rawConsoleLines = malloc(rawConsoleLinesCapacity * sizeof(char **));
    NSMutableString *consoleString = [[NSMutableString alloc] init];
    NSMutableArray *consoleLines = [[NSMutableArray alloc] init];

    // We want the dates and times to be displayed in a standardised form (ISO 8601).
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    // ASL does not work in App Sandbox, even with an entitlement of:
    //   com.apple.security.temporary-exception.files.absolute-path.read-only
    // for:
    //   /private/var/log/asl/
    // ASL is deprecated starting in macOS 10.12, so this will likely never change.
    aslmsg query = asl_new(ASL_TYPE_QUERY);
    if (query == NULL) {
        NSLog(@"asl_new returned NULL. If you are using App Sandbox or Hardened Runtime, even an entitlement to /private/var/log/asl/ doesn't seem to work.");
    }
    else {
        NSString *applicationName = [FRApplication applicationName];
        NSString *sinceString = [NSString stringWithFormat:@"%01f", [since timeIntervalSince1970]];

        asl_set_query(query, ASL_KEY_SENDER, [applicationName UTF8String], ASL_QUERY_OP_EQUAL);
        asl_set_query(query, ASL_KEY_TIME, [sinceString UTF8String], ASL_QUERY_OP_GREATER_EQUAL);

        // This function is very slow. <rdar://problem/7695589>
        aslresponse response = asl_search(NULL, query);

        asl_free(query);

        // Loop through the query response, grabbing the results into a local store for processing
        if (response == NULL) {
            NSLog(@"asl_search returned NULL. If you are using App Sandbox or Hardened Runtime, even an entitlement to /private/var/log/asl/ doesn't seem to work.");
        }
        else {

            aslmsg msg = NULL;

            while (NULL != (msg = aslresponse_next(response))) {

                const char *msgTime = asl_get(msg, ASL_KEY_TIME);
                
                if (msgTime == NULL) {
                    continue;
                }
                
                const char *msgText = asl_get(msg, ASL_KEY_MSG);

                if (msgText == NULL) {
                    continue;
                }

                // Ensure sufficient capacity to store this line in the local cache
                consoleLinesProcessed++;
                if (consoleLinesProcessed > rawConsoleLinesCapacity) {
                    rawConsoleLinesCapacity *= 2;
                    rawConsoleLines = reallocf(rawConsoleLines, rawConsoleLinesCapacity * sizeof(char **));
                }

                // Add a new entry for this console line
                char **rawLineContents = malloc(2 * sizeof(char *));
                
                size_t length = strlen(msgTime) + 1;
                rawLineContents[FR_CONSOLELOG_TIME] = malloc(length);
                strlcpy(rawLineContents[FR_CONSOLELOG_TIME], msgTime, length);

                length = strlen(msgText) + 1;
                rawLineContents[FR_CONSOLELOG_TEXT] = malloc(length);
                strlcpy(rawLineContents[FR_CONSOLELOG_TEXT], msgText, length);

                rawConsoleLines[consoleLinesProcessed-1] = rawLineContents;
            }

            aslresponse_free(response);

            // Loop through the console lines in reverse order, converting to NSStrings
            if (consoleLinesProcessed) {
                for (NSInteger i = consoleLinesProcessed - 1; i >= 0; i--) {
                    char **line = rawConsoleLines[i];
                    double dateInterval = strtod(line[FR_CONSOLELOG_TIME], NULL);
                    NSDate *date = [NSDate dateWithTimeIntervalSince1970:dateInterval];
                    NSString *dateString = [dateFormatter stringFromDate:date];
                    NSString *lineString = [NSString stringWithUTF8String:line[FR_CONSOLELOG_TEXT]];
                    NSString *fullString = [NSString stringWithFormat:@"%@: %@\n", dateString, lineString];
                    [consoleLines addObject:fullString];

                    // If a maximum size has been provided, respect it and abort if necessary
                    if (maximumSize != nil) {
                        NSString* lastLine = [consoleLines lastObject];
                        consoleOutputLength += [lastLine length];
                        if (consoleOutputLength > [maximumSize unsignedIntegerValue]) {
                            break;
                        }
                    }
                }
            }
        }
    }

    // Convert the console lines array to an output string
    for (NSString *line in [consoleLines reverseObjectEnumerator]) {
        [consoleString appendString:line];
    }

    // Free data stores
    for (NSUInteger i = 0; i < consoleLinesProcessed; i++) {
        free(rawConsoleLines[i][FR_CONSOLELOG_TEXT]);
        free(rawConsoleLines[i][FR_CONSOLELOG_TIME]);
        free(rawConsoleLines[i]);
    }
    free(rawConsoleLines);

    return consoleString;
}

@end
