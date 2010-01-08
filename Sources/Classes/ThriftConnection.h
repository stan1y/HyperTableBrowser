//
//  ThriftConnection.h
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 12/8/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <ThriftConnectionInfo.h>
#include <HyperThriftWrapper.h>
#include <HyperThriftHql.h>

@interface ThriftConnection : NSObject {
	ThriftConnectionInfo * connInfo;
	HTHRIFT thriftClient;
	HTHRIFT_HQL hqlClient;
}

@property (assign)ThriftConnectionInfo * connInfo;
@property (assign)HTHRIFT thriftClient;
@property (assign)HTHRIFT_HQL hqlClient;

- (NSString *)connectTo:(ThriftConnectionInfo*)info;

+ (NSString *)errorFromCode:(int)code;
@end
