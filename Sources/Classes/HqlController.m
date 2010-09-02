//
//  HqlController.m
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 12/16/09.
//  Copyright 2009 Stanislav Yudin. All rights reserved.
//

#import "HqlController.h"
#import "HyperTable.h"
#import "HqlQueryOperation.h"
#import "Activities.h"

@implementation HqlController

@synthesize goButton;
@synthesize hqlQuery;
@synthesize pageSource;
@synthesize	pageView;
@synthesize scriptSelector;
@synthesize indicator;
@synthesize queryStatus;

#pragma mark Initialization

- (void)dealloc
{
	[hqlQuery release];
	[goButton release];
	[pageSource release];
	[pageView release];
	[queryStatus release];
	[indicator release];
	if (loadedScriptFilePath) {
		[loadedScriptFilePath release];
	}
	
	[super dealloc];
}

- (void) awakeFromNib
{
	loadedScriptFilePath = nil;
	scriptModified = NO;
}

- (IBAction) showWindow:(id)sender
{
	[super showWindow:sender];
	[self updateBrokers:sender];
}

- (IBAction)runQuery:(id)sender 
{	
	NSString * hqlQueryText = [[hqlQuery textStorage] string];
	if ([hqlQueryText length] <= 0) {
		[queryStatus setStringValue:@"Empty query!"];
		return;
	}
	
	id broker = [self selectedBroker];
	if (!broker) {
		[queryStatus setStringValue:@"You are not connected to selected broker."];
		return;
	}
	
	[self runQuery:hqlQueryText onServer:broker];
}

- (void)runQuery:(NSString *)query onServer:(id)server 
{
	HqlQueryOperation * hqlOp = [HqlQueryOperation queryHql:query withConnection:server];
	[hqlOp setCompletionBlock:^ {
		
		[indicator stopAnimation:self];
		if (hqlOp.errorCode != T_OK) {
			[queryStatus setStringValue:[NSString stringWithFormat:
							  @"Query failed: %s",
							  [[HyperTable errorFromCode:hqlOp.errorCode] UTF8String]]];
		}
		else {
			DataPage * thePage = [hqlOp page];
			if ( !thePage || thePage->rowsCount == 0) {
				[queryStatus setStringValue:@"Executed successfully. Nothing returned."];
			}
			else {
				[pageSource setPage:thePage withTitle:@"HQL"];
				[pageSource reloadDataForView:pageView];
				[queryStatus setStringValue:[NSString stringWithFormat:
								  @"Executed successfully. %d row(s) returned.",
								  hqlOp.page->rowsCount]];
			}
		}
	}];
	
	//start operation
	[indicator startAnimation:self];
	[queryStatus setStringValue:@"Executing query..."];
	[[Activities sharedInstance] appendOperation: hqlOp withTitle:@"Executing HQL Query..." ];
	[hqlOp release];
}

- (IBAction) updateScripts:(id)sender
{
	NSFileManager * fm = [NSFileManager defaultManager];
	NSString * scriptsPath = [[[NSApp delegate] applicationSupportDirectory] stringByAppendingPathComponent:@"HQL Scripts"];
	NSError * err = nil;
	NSArray * scriptFilesArray = [fm contentsOfDirectoryAtPath:scriptsPath error:&err];
	if (err) {
		[NSApp presentError:err];
		return;
	}
	
	[scriptSelector removeAllItems];
	//if there is no file loaded, add "Untitled"
	if (loadedScriptFilePath == nil) {
		[scriptSelector addItemWithTitle:@"Untitled"];
	}
	//add all found scripts
	for (NSString * scriptFile in scriptFilesArray) {
		NSLog(@"Found script \"%@\"", scriptFile);
		[scriptSelector addItemWithTitle:scriptFile];
	}
}

- (NSString *) currentScriptFileName
{
	id item = [scriptSelector selectedItem];
	if (item && [[item title] length] && [item title] != @"Untitled") {
		return [item title];
	}
	else {
		return nil;
	}

}
- (BOOL) isScriptSaved
{
	id item = [scriptSelector selectedItem];
	if (item && [[item title] length] && [item title] != @"Untitled" && !scriptModified) 
		return YES;
	else 
		return NO;
}

@end
