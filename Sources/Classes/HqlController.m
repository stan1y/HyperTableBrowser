//
//  HqlController.m
//  Ore Foundry
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

- (void)dealloc
{
	[hqlQuery release];
	[goButton release];
	[pageSource release];
	[pageView release];
	[super dealloc];
}

- (void)windowWillClose:(NSNotification *)notification
{
	NSLog(@"HQL Interpreter closed\n");
	[[NSApp delegate] saveAction:self];
}

- (IBAction)done:(id)sender {
	if([[self window] isVisible] )
        [[self window] orderOut:sender];
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

- (void)runQuery:(NSString *)query withConnection:(id)connection 
{
	HqlQueryOperation * hqlOp = [HqlQueryOperation queryHql:query withConnection:connection];
	[hqlOp setCompletionBlock:^ {
		[self indicateDone];
		if (hqlOp.errorCode != T_OK) {
			[self setMessage:[NSString stringWithFormat:
							  @"Query failed: %s",
							  [[HyperTable errorFromCode:hqlOp.errorCode] UTF8String]]];
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
