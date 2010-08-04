//
//  HyperTableOperationController.m
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 4/8/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import "HyperTableOperationController.h"


@implementation HyperTableOperationController

@synthesize serverSelector;
@synthesize statusField;
@synthesize indicator;

- (void)dealloc
{
	[serverSelector release];
	[statusField release];
	[indicator release];
	[super dealloc];
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
	}
	else {
		[serverSelector setEnabled:YES];
		[self setMessage:[NSString stringWithFormat:@"%d server(s) available", [serversArray count]] ];
	}
	[self indicateDone];
	[serversArray release];
}

- (id)getSelectedConnection {
	if (![[serverSelector itemArray] count] < 0) {
		[self setMessage:@"There are no connected servers. You need to establish connection before executing HQL."];
		return nil;
	}
	
	return [ [[NSApp delegate] serversManager] getConnection:[[serverSelector selectedItem] title] ];
}

- (void)setMessage:(NSString*)message {
	NSLog(@"%s\n", [message UTF8String]);
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

@end
