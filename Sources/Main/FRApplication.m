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

#import "FRApplication.h"
#import "FRConstants.h"

@implementation FRApplication

+ (nullable NSString*) applicationBundleVersion
{
	// CFBundleVersion is documented as not localizable.
    NSString *bundleVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey: @"CFBundleVersion"];
    
    return bundleVersion;
}

+ (nullable NSString*) applicationShortVersion
{
    // CFBundleShortVersionString is documented as localizable, so prefer a localized value if available.
    NSString *shortVersion = [[[NSBundle mainBundle] localizedInfoDictionary] objectForKey: @"CFBundleShortVersionString"];
    
    if (!shortVersion) {
        shortVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey: @"CFBundleShortVersionString"];
    }
    
    return shortVersion;
}

+ (nullable NSString*) applicationVersion
{
    NSString *bundleVersion = [self applicationBundleVersion];
    NSString *shortVersion = [self applicationShortVersion];
    
    // Make a version string like the Cocoa About Box does, ex: "2.3.6 (345684)".
    NSString* fullVersion = nil;
    if (shortVersion && bundleVersion) {
        fullVersion = [NSString stringWithFormat:@"%@ (%@)", shortVersion, bundleVersion];
    }
	
    return fullVersion;
}


+ (nullable NSString*) applicationName
{
    // CFBundleExecutable is not localizable.
    NSString *applicationName = [[[NSBundle mainBundle] infoDictionary] objectForKey: @"CFBundleExecutable"];
    
    return applicationName;
}

+ (nullable NSString*) applicationIdentifier
{
    // CFBundleIdentifier is not localizable.
    NSString *applicationIdentifier = [[[NSBundle mainBundle] infoDictionary] objectForKey: @"CFBundleIdentifier"];

    return applicationIdentifier;
}

+ (nullable NSString*) feedbackURL
{
    NSString *target = [[[NSBundle mainBundle] infoDictionary] objectForKey: PLIST_KEY_TARGETURL];

    if (target == nil) {
        return nil;
    }

    target = [target stringByReplacingOccurrencesOfString:@"%@" withString:[FRApplication applicationName]];

    return target;
}


@end
