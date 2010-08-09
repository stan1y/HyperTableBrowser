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
@synthesize connection;

- (void)dealloc
{
	[tableSelector release];
	[connection release];
	[super dealloc];
}

- (IBAction)updateTables:(id)sender
{
	if ([connection isConnected] && [[connection tables] count] > 0) {
		[tableSelector setEnabled:YES];
		[tableSelector removeAllItems];
		for (NSString * table in [connection tables])
			[tableSelector addItemWithTitle:table];
	}
	else {
		[tableSelector removeAllItems];
		[tableSelector setEnabled:NO];
	}

}

@end
