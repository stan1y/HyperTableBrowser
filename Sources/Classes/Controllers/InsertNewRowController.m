//
//  InsertNewRowController.m
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 4/8/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import "InsertNewRowController.h"


@implementation InsertNewRowController

@synthesize tableSelector;

- (void)dealloc
{
	[tableSelector release];
	[super dealloc];
}

- (IBAction)updateConnections:(id)sender
{
	[super updateConnections:sender];
	[self serverSelectionChanged:sender];
}

- (IBAction)serverSelectionChanged:(id)sender
{
	NSLog(@"Server selection changed, updating tables...\n");
	id connection = [self getSelectedConnection];
	if (connection && [connection isConnected] && [[connection tables] count] > 0) {
		[tableSelector setEnabled:YES];
		[tableSelector removeAllItems];
		[self setMessage:[NSString stringWithFormat:@"%d tables available", [[connection tables] count]]];
		for (NSString * table in [connection tables])
			[tableSelector addItemWithTitle:table];
	}
	else {
		[self setMessage:@"Selected server cannot be used, no tables known there"];
		[tableSelector removeAllItems];
		[tableSelector setEnabled:NO];
	}

}

@end
