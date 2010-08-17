//
//  UpdateSettings.m
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 11/8/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import "UpdateSettings.h"


@implementation UpdateSettings

- (NSString *)title
{
	return NSLocalizedString(@"Updates", @"Updates Preferences");
}

- (NSString *)identifier
{
	return @"UpdatesPreferencesPane";
}

- (NSImage *)image
{
	return [NSImage imageNamed:@"NSPreferencesGeneral"];
}

@end
