//
//  FetchTablesOperation.h
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 26/7/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <ThriftConnection.h>

@interface FetchTablesOperation : NSOperation {
	ThriftConnection * connection;
	int errorCode;
}

@property (retain) ThriftConnection * connection;
@property (assign) int errorCode;

+ fetchTablesFromConnection:(ThriftConnection *)conn;
- (void)main;

@end
