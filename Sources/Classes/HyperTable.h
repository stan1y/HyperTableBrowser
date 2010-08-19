//
//  HyperTable.h
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 9/8/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <HyperThriftWrapper.h>
#import <HyperThriftHql.h>

@interface HyperTable : NSObject {
	NSString * ipAddress;
	int port;
	
	HTHRIFT thriftClient;
	HTHRIFT_HQL hqlClient;
	
	NSMutableArray * tables;
	
	NSLock * connectionLock;
}

@property (nonatomic, retain) NSString * ipAddress;
@property (assign) int port;

@property (nonatomic, retain) NSLock * connectionLock;
@property (nonatomic, retain) NSArray * tables;

@property (assign) HTHRIFT thriftClient;
@property (assign) HTHRIFT_HQL hqlClient;

+ (HyperTable *) hypertableAt:(NSString *)addr onPort:(int)aPort;

//sync operation
- (void) disconnect;
- (BOOL) isConnected;

//async operations
- (void) reconnect:(void (^)(void)) codeBlock;
- (void) refresh:(void (^)(void)) codeBlock;

+ (NSString *)errorFromCode:(int)code;
@end
