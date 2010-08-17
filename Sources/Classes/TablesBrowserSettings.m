//
//  TablesBrowserSettings.m
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 11/8/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import "TablesBrowserSettings.h"


@implementation TablesBrowserSettings

- (NSString *)title
{
	return NSLocalizedString(@"Tables", @"Tables Browser preferences");
}

- (NSString *)identifier
{
	return @"TablesBrowserPreferencesPane";
}

- (NSImage *)image
{
	return [NSImage imageNamed:@"NSPreferencesGeneral"];
}

@end
