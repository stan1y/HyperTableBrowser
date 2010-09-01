//
//  NewTableController.m
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 25/7/2010.
//  Copyright 2010 Stanislav Yudin. All rights reserved.
//

#import "NewTableController.h"

@implementation NewTableController

@synthesize schemaContents;
@synthesize createButton;
@synthesize schemasView;
@synthesize tableNameField;
@synthesize connection;

- (void) dealloc
{
	[schemasView release];
	[schemaContents release];
	[createButton release];
	[tableNameField release];
	[connection release];
	[super dealloc];
}

- (IBAction)createTable:(id)sender
{
	
	//FIXME: create table
}

- (void) createTableWithName:(NSString *)tableName
				   andSchema:(NSString*)schemaContent
					onServer:(HyperTable *)server
{
	NSLog(@"Creating new table \"%s\" on %s\n", [tableName UTF8String],
		  [[server ipAddress] UTF8String]);
	
	int rc = new_table([connection thriftClient], 
						  [tableName UTF8String], 
						  [schemaContent UTF8String]);
	if (rc != T_OK) {
		return;
	}
	
}

@end
