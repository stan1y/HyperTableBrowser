//
//  ConnectOperation.h
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 26/7/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <HyperTable.h>
#include <HyperThriftWrapper.h>
#include <HyperThriftHql.h>

@interface ConnectOperation : NSOperation {
	NSString * ipAddress;
	int port;
	HyperTable * hypertable;
	int errorCode;
}

@property (nonatomic, retain) NSString * ipAddress;
@property (assign) int port;

@property (nonatomic, retain) HyperTable * hypertable;
@property (assign) int errorCode;

+ connect:(HyperTable*)hypertable toBroker:(NSString *)address onPort:(int)port;
- (void) main;

@end
