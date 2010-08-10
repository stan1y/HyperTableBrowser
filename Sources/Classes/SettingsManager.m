//
//  SettingsManager.m
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 9/8/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import "SettingsManager.h"


@implementation SettingsManager
/*
+ (SettingsManager *) settingsFromFile:(NSString *)filename
{
	NSLog(@"Settings file: %s", [filename UTF8String]);
	SettingsManager * sm = [[SettingsManager alloc] init];
	[sm setDataFileName:filename];
	return sm;
}*/

- (SettingsManager *) init
{
	[self setDataFileName:@"Settings.xml"];
	return self;
}

- (id) getSettingsByName:(NSString *)name
{
	NSFetchRequest * request = [[NSFetchRequest alloc] init];
	
	NSEntityDescription * entity = [NSEntityDescription entityForName:name
											   inManagedObjectContext:[self managedObjectContext] ];
	
	[request setEntity:entity];
	[request setIncludesPendingChanges:YES];
	NSError * err = nil;
	NSArray * result = [[self managedObjectContext] executeFetchRequest:request error:&err];
	if (err) {
		NSString * msg = @"Failed to get servers from datastore";
		[[NSApplication sharedApplication] presentError:err];
		[err release];
		return nil;
	}
	[request release];
	
	if ( [result count] <= 0 ) {
		//create new default settings
		id defaults = [NSEntityDescription insertNewObjectForEntityForName:name
													inManagedObjectContext:[self managedObjectContext] ];
		return defaults;
	}
	else if ([result count] > 1) {
		return [result objectAtIndex:0];
	}
	[result retain];
	id settings = [result objectAtIndex:0];
	return settings;
}


@end
