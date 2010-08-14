//
//  HqlQueryOperation.m
//  Ore Foundry
//
//  Created by Stanislav Yudin on 26/7/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import "HqlQueryOperation.h"

@implementation HqlQueryOperation

@synthesize connection;
@synthesize errorCode;
@synthesize page;
@synthesize query;

+ queryHql:(NSString *)query withConnection:(HyperTable *)con
{
	HqlQueryOperation * hqlOp = [[HqlQueryOperation alloc] init];
	[hqlOp setConnection:con];
	[hqlOp setQuery:query];
	return hqlOp;
}

- (void) dealloc
{
	[connection release];
	[query release];
	if (page) {
		page_clear(page);
		free(page);
		page = nil;
	}
	[super dealloc];
}

- (void)main
{
	[[[self connection] connectionLock] lock];
	
	NSLog(@"Executing HQL: %s\n", [query UTF8String]);
	
	if (page) {
		page_clear(page);
		free(page);
	}
	page = page_new();
	int rc = hql_query([connection hqlClient], page, [query UTF8String]);
	[self setErrorCode:rc];
	
	[[[self connection] connectionLock] unlock];
}

@end
