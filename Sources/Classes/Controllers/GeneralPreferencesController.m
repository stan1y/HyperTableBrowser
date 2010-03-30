//
//  GeneralPreferencesController.m
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 30/3/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import "GeneralPreferencesController.h"


@implementation GeneralPreferencesController

- (NSString *)title
{
	return NSLocalizedString(@"General", @"Title of 'General' preference pane");
}

- (NSString *)identifier
{
	return @"GeneralPreferencesPane";
}

- (NSImage *)image
{
	return [NSImage imageNamed:@"NSPreferencesGeneral"];
}
@end
