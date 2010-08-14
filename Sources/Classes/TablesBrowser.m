//
//  TablesBrowser.m
//  Ore Foundry
//
//  Created by Stanislav Yudin on 9/8/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import "TablesBrowser.h"


@implementation TablesBrowser

@synthesize pageSource;
@synthesize toolbarController;

@synthesize newTablePnl;
@synthesize insertNewRowPnl;

@synthesize newTableController;
@synthesize newRowController;

- (void) dealloc
{
	[toolbarController release];
	[pageSource release];
	[newTablePnl release];
	[newTableController release];
	[insertNewRowPnl release];
	[newRowController release];
	[super dealloc];
}

- (void)windowWillClose:(NSNotification *)notification
{
	NSLog(@"Tables Browser closed\n");
}

@end
