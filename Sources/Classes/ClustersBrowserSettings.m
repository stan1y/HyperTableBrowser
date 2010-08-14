//
//  ClustersBrowserSettings.m
//  Ore Foundry
//
//  Created by Stanislav Yudin on 11/8/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import "ClustersBrowserSettings.h"


@implementation ClustersBrowserSettings

- (NSString *)title
{
	return NSLocalizedString(@"Cluster", @"Cluster Browser preferences");
}

- (NSString *)identifier
{
	return @"CustersBrowserPreferencesPane";
}

- (NSImage *)image
{
	return [NSImage imageNamed:@"NSPreferencesGeneral"];
}

@end
