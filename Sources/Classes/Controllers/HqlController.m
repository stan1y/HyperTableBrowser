//
//  HqlController.m
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 12/16/09.
//  Copyright 2009 AwesomeStanly Lab. All rights reserved.
//

#import "HqlController.h"


@implementation HqlController

@synthesize window, goButton, hqlQueryField, pageSource, pageView;

- (IBAction)done:(id)sender {
	//clear
	[pageSource setPage:nil];
	[pageSource reloadDataForView:pageView];
	[hqlQueryField setStringValue:@""];
	
	[[[NSApp delegate] showHqlInterperterMenuItem] setTitle:@"Show HQL Browser"];
	
	if([[self window] isVisible] )
        [[self window] orderOut:nil];
}

- (void)setMessage:(NSString*)message {
	[statusField setTitleWithMnemonic:message];
}

- (void)indicateBusy {
	[indicator setHidden:NO];
	[indicator startAnimation:self];
}

- (void)indicateDone {
	[indicator stopAnimation:self];
	[indicator setHidden:YES];
}

- (IBAction)go:(id)sender {	
	[self indicateBusy];
	[self setMessage:@"Executing HQL..."];
	
	if ([[hqlQueryField stringValue] length] <= 0) {
		[self indicateDone];
		[self setMessage:@"Empty query!"];
		return;
	}
	
	if ( ![[NSApp delegate] isConnected]) {
		[self indicateDone];
		[self setMessage:@"Application is offline."];
		return;
	}

	id con = [self getSelectedConnection];
	[self runQuery:[hqlQueryField stringValue] withConnection:con];
}

- (IBAction)updateConnections:(id)sender
{
	//populate selector
	[serverSelector removeAllItems];
	for (NSString * key in [[NSApp delegate] connectionsDict])
		[serverSelector addItemWithTitle:key];

	//set controlls
	if ([[[NSApp delegate] connectionsDict] count] <= 0) {
		[serverSelector setEnabled:NO];
		[goButton setEnabled:NO];
	}
	else {
		[serverSelector setEnabled:YES];
		[goButton setEnabled:YES];
	}

}

- (id)getSelectedConnection {
	if (![[NSApp delegate] connectionsDict] || [[[NSApp delegate] connectionsDict] count] < 0) {
		[self setMessage:@"There are no connected server. You need to establish connection before executing HQL."];
		return nil;
	}
	for (NSString * key in [[NSApp delegate] connectionsDict])
	{
		if (key == [[serverSelector selectedItem] title]) {
			id connection = [[[NSApp delegate] connectionsDict] objectForKey:key];
			if ( ![connection thriftClient] ) 
			{
				[self setMessage:@"Selected server is not connected. Refresh the list of servers."];
				return nil;
			}
			
			return connection;
		}
	}
	
	[self setMessage:@"Selected server not found. Refresh the list of servers."];
	return nil;
}

- (void)runQuery:(NSString *) query withConnection:(id)connection {
	NSLog(@"runQuery: %s\n", [query UTF8String]);
	//run query
	dispatch_async(dispatch_get_global_queue(0, 0), ^{
		DataPage * page = page_new();
		int rc = hql_query([connection hqlClient], page, [query UTF8String]);
		[self indicateDone];
		
		dispatch_async(dispatch_get_main_queue(), ^{
			[self indicateDone];
			if (rc != T_OK) {
				page_clear(page);
				free(page);
				[self setMessage:[NSString stringWithFormat:
													 @"Query failed: %s",
													 [[ThriftConnection errorFromCode:rc] UTF8String]]];
			}
			else {
				[pageSource setPage:page];
				[pageSource reloadDataForView:pageView];
				[self setMessage:[NSString stringWithFormat:
													 @"Query returned %d object(s).",
													 page->rowsCount]];
			}
		});
	});
}


@end
