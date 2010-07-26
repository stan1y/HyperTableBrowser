//
//  HqlQueryOperation.h
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 26/7/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <ThriftConnection.h>
#import <HyperThriftHql.h>

@interface HqlQueryOperation : NSOperation {
	ThriftConnection * connection;
	NSString * query;
	DataPage * page;
	int errorCode;
}

@property (assign) ThriftConnection * connection;
@property (assign) int errorCode;
@property (assign) NSString * query;

@property (readonly) DataPage * page;

+ queryHql:(NSString *)query withConnection:(ThriftConnection *)con;
- (void)main;

@end
