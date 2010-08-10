//
//  GeneralPreferencesController.m
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 30/3/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import "GeneralPreferencesController.h"

@implementation GeneralPreferencesController

@synthesize autoReconnectServer;
@synthesize skipMetadata;
@synthesize showTablesCount;

- (NSString *)title
{
	return NSLocalizedString(@"General", @"General preferences of browser");
}

- (NSString *)identifier
{
	return @"GeneralPreferencesPane";
}

- (NSImage *)image
{
	return [NSImage imageNamed:@"NSPreferencesGeneral"];
}

- (void)awakeFromNib
{
	NSLog(@"Loading General Preferences pane.\n");
	id settings = [[[NSApp delegate] settingsManager] getSettingsByName:@"GeneralPrefs"];
	[autoReconnectServer setState:[[settings valueForKey:@"autoReconnectServer"] intValue]];
	[showTablesCount setState:[[settings valueForKey:@"showTablesCount"] intValue]];
	[skipMetadata setState:[[settings valueForKey:@"skipMetadata"] intValue]];
	[settings release];
}

- (IBAction)switchCheckBox:(id)sender
{
	NSLog(@"Switching option for \"%s\"\n", [[sender title] UTF8String]);
	id settings = [[[NSApp delegate] settingsManager] getSettingsByName:@"GeneralPrefs"];
	if (settings) {
		if (sender == autoReconnectServer) {
			NSNumber * state = [NSNumber numberWithInt:[autoReconnectServer state]];
			NSLog(@"autoReconnectServer: %d\n", [state intValue]);
			[settings setValue:state forKey:@"autoReconnectServer"];
		}
		if (sender == skipMetadata) {
			NSNumber * state = [NSNumber numberWithInt:[skipMetadata state]];
			NSLog(@"skipMetadata: %d\n", [state intValue]);
			[settings setValue:state forKey:@"skipMetadata"];
		}
		if (sender == showTablesCount) {
			NSNumber * state = [NSNumber numberWithInt:[showTablesCount state]];
			NSLog(@"showTablesCount: %d\n", [state intValue]);
			[settings setValue:state forKey:@"showTablesCount"];
		}
		[settings release];
		NSLog(@"Saving settings to store...\n");
		[[NSApp delegate] saveAction:sender];
	}
}
@end
