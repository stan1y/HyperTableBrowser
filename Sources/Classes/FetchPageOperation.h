//
//  FetchPageOperation.h
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 26/7/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <ThriftConnection.h>

@interface FetchPageOperation : NSOperation {
	ThriftConnection * connection;
	DataPage * page;
	int errorCode;
	
	NSString * tableName;
	int pageIndex;
	int pageSize;
	
	int totalRows;
	int startIndex;
	int stopIndex;
}

@property (assign) ThriftConnection * connection;
@property (assign) int totalRows;
@property (assign) int errorCode;
@property (assign) int pageIndex;
@property (assign) int pageSize;
@property (assign) NSString * tableName;
@property (assign) int startIndex;
@property (assign) int stopIndex;

@property (readonly) DataPage * page;

+ fetchPageFromConnection:(ThriftConnection *)conn
				 withName:(NSString *)tableName 
				atIndex:(int)pageIndex 
				  andSize:(int)pageSize;

- (void)main;

@end
