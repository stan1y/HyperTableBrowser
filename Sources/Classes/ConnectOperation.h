//
//  ConnectOperation.h
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 26/7/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <ThriftConnection.h>
#import <ThriftConnectionInfo.h>

@interface ConnectOperation : NSOperation {
	ThriftConnectionInfo * connectionInfo;
	ThriftConnection * connection;
	int errorCode;
}

@property (nonatomic, retain) ThriftConnectionInfo * connectionInfo;
@property (nonatomic, retain, readonly) ThriftConnection * connection;
@property (assign) int errorCode;

+ connectWithInfo:(ThriftConnectionInfo *)info;
- (void)main;

@end
