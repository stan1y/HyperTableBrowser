//
//  HqlController.m
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 12/16/09.
//  Copyright 2009 AwesomeStanly Lab. All rights reserved.
//

#import "HqlController.h"


@implementation HqlController

@synthesize goButton;
@synthesize hqlQuery;
@synthesize pageSource;
@synthesize	pageView;
@synthesize serverSelector;
@synthesize indicator;
@synthesize statusField;

- (void)dealloc
{
	[hqlQuery release];
	[goButton release];
	[indicator release];
	[statusField release];
	[serverSelector release];
	[pageSource release];
	[pageView release];
}

- (void)windowWillClose:(NSNotification *)notification
{
	NSLog(@"HQL Interpreter was closed\n");
}

- (BOOL)shouldChangeTextInRange:(NSRange)affectedCharRange 
			  replacementString:(NSString *)replacementString
{
	NSLog(@"%s", [replacementString UTF8String]);
	return YES;
}

- (IBAction)done:(id)sender {
	if([[self window] isVisible] )
        [[self window] orderOut:sender];
}

- (void)setMessage:(NSString*)message {
	NSLog(@"HQL: %s\n", [message UTF8String]);
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
	NSString * hqlQueryText = [[hqlQuery textStorage] string];
	if ([hqlQueryText length] <= 0) {
		[self setMessage:@"Empty query!"];
		return;
	}
	
	id con = [self getSelectedConnection];
	if (!con) {
		[self setMessage:@"You are not connected to selected server."];
		return;
	}
	
	[self runQuery:hqlQueryText withConnection:con];
}

- (IBAction)updateConnections:(id)sender
{
	[self setMessage:@"Updating connections..."];
	[self indicateBusy];
	
	//populate selector
	id serversArray = [[[NSApp delegate] serversManager] getServers];
	[serverSelector removeAllItems];
	for (id server in serversArray)
		[serverSelector addItemWithTitle:[server valueForKey:@"ipAddress"]];
	
	if ([serversArray count] <= 0) {
		[self setMessage:@"No servers available. Please connect to at least one server."];
		[serverSelector setEnabled:NO];
		[goButton setEnabled:NO];
	}
	else {
		[serverSelector setEnabled:YES];
		[goButton setEnabled:YES];
		[self setMessage:[NSString stringWithFormat:@"%d server(s) available", [serversArray count]] ];
	}
	[self indicateDone];
	[serversArray release];
}

- (id)getSelectedConnection {
	NSLog(@"Get selected connection");
	if (![[serverSelector itemArray] count] < 0) {
		[self setMessage:@"There are no connected servers. You need to establish connection before executing HQL."];
		return nil;
	}
	
	return [ [[NSApp delegate] serversManager] getConnection:[[serverSelector selectedItem] title] ];
}

- (void)runQuery:(NSString *)query withConnection:(id)connection 
{
	HqlQueryOperation * hqlOp = [HqlQueryOperation queryHql:query withConnection:connection];
	[hqlOp setCompletionBlock:^ {
		[self indicateDone];
		if (hqlOp.errorCode != T_OK) {
			[self setMessage:[NSString stringWithFormat:
							  @"Query failed: %s",
							  [[ThriftConnection errorFromCode:hqlOp.errorCode] UTF8String]]];
		}
		else {
			DataPage * thePage = [hqlOp page];
			if ( !thePage || thePage->rowsCount == 0) {
				[self setMessage:@"Query successfull but no data was returned."];
			}
			else {
				[pageSource setPage:thePage withTitle:@"HQL"];
				[pageSource reloadDataForView:pageView];
				[self setMessage:[NSString stringWithFormat:
								  @"Query returned %d row(s).",
								  hqlOp.page->rowsCount]];
			}
		}
	}];
	
	[self indicateBusy];
	[self setMessage:@"Executing query..."];
	[[[NSApp delegate] operations] addOperation: hqlOp];
	[hqlOp release];
}


@end
