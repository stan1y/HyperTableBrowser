//
//  HyperTable.h
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 9/8/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Hadoop.h>
#import <HyperThriftWrapper.h>
#import <HyperThriftHql.h>

@interface HyperTable : Hadoop {
	NSString * hypertableConfContent;
	
	HTHRIFT thriftClient;
	HTHRIFT_HQL hqlClient;
	
	NSMutableArray * tables;
	
	NSLock * connectionLock;
}

@property (nonatomic, retain) NSLock * connectionLock;
@property (nonatomic, retain) NSArray * tables;

@property (assign) HTHRIFT thriftClient;
@property (assign) HTHRIFT_HQL hqlClient;

//initialization
+ (NSEntityDescription *) hypertableDescription;
+ (NSEntityDescription *) tableSchemaDescription;

// ClusterMemberProtocol implementation
- (void) updateWithCompletionBlock:(void (^)(void)) codeBlock;
- (void) reconnectWithCompletionBlock:(void (^)(void)) codeBlock;
- (void) disconnect;
- (BOOL) isConnected;

- (void) updateTablesWithCompletionBlock:(void (^)(void))codeBlock;

// HyperTable objects with Thrift Broker serice
+ (NSArray *) hyperTableBrokersInCluster:(id)cluster;
+ (NSArray *) hyperTableBrokersInCurrentCluster;

// All HyperTable objects
+ (NSArray *) hypertablesInCluster:(id)cluster;
+ (NSArray *) hypertablesInCurrentCluster;

//table schemas
+ (NSArray *)listSchemes;
+ (NSManagedObject *)getSchemaByName:(NSString *)name;
- (NSArray *) describeColumns:(NSManagedObject *)schema;

//error code to error message
+ (NSString *)errorFromCode:(int)code;

@end
