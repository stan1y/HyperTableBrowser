//
//  ConnectOperation.h
//  Ore Foundry
//
//  Created by Stanislav Yudin on 26/7/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include <HyperThriftWrapper.h>
#include <HyperThriftHql.h>

@interface ConnectOperation : NSOperation {
	NSString * ipAddress;
	int port;
	
	HTHRIFT thriftClient;
	HTHRIFT_HQL hqlClient;
	
	int errorCode;
}

@property (nonatomic, retain) NSString * ipAddress;
@property (assign) int port;

@property (assign) int errorCode;

@property (readonly) HTHRIFT thriftClient;
@property (readonly) HTHRIFT_HQL hqlClient;

+ connectTo:(NSString *)address onPort:(int)port;

- (void)main;

@end
