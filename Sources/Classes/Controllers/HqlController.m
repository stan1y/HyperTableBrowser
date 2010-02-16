//
//  HqlController.m
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 12/16/09.
//  Copyright 2009 AwesomeStanly Lab. All rights reserved.
//

#import "HqlController.h"


@implementation HqlController
@synthesize window, goButton, hqlQueryField, pageSource, \
	pageView, serverSelector, indicator, statusField;

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
	NSLog(@"HQL: %s", [message UTF8String]);
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
	
	id con = [self getSelectedConnection];
	[self runQuery:[hqlQueryField stringValue] withConnection:con];
}

- (IBAction)updateConnections:(id)sender
{
	[self setMessage:@"Updating connections for HQL"];
	//populate selector
	id serversArray = [[[NSApp delegate] serversManager] getServers];
	[serverSelector removeAllItems];
	for (id server in serversArray)
		[serverSelector addItemWithTitle:[server valueForKey:@"hostname"]];
	
	if ([serversArray count] <= 0) {
		[self setMessage:@"No servers available. Please connect somewhere."];
		[serverSelector setEnabled:NO];
		[goButton setEnabled:NO];
	}
	else {
		[serverSelector setEnabled:YES];
		[goButton setEnabled:YES];
	}
}

- (id)getSelectedConnection {
	NSLog(@"Get selected connection");
	if (![[serverSelector itemArray] count] < 0) {
		[self setMessage:@"There are no connected server. You need to establish connection before executing HQL."];
		return nil;
	}
	
	return [ [[NSApp delegate] serversManager] getConnection:[[serverSelector selectedItem] title] ];
}

- (void)runQuery:(NSString *) query withConnection:(id)connection {
	NSLog(@"Executing HQL: %s\n", [query UTF8String]);
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
