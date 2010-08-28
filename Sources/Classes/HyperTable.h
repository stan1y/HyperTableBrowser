//
//  HyperTable.h
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 9/8/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Server.h"
#import <HyperThriftWrapper.h>
#import <HyperThriftHql.h>

@interface HyperTable : Server<ClusterMember, CellStorage> {
	NSString * hypertableConfContent;
	
	HTHRIFT thriftClient;
	HTHRIFT_HQL hqlClient;
	
	NSLock * connectionLock;
	
	int lastFetchedIndex;
	int lastFetchedTotalIndexes;
}

@property (nonatomic, retain) NSLock * connectionLock;

@property (assign) HTHRIFT thriftClient;
@property (assign) HTHRIFT_HQL hqlClient;

//	Class methods

// HyperTable objects with Thrift Broker serice
+ (NSArray *) hyperTableBrokersInCluster:(id)cluster;
+ (NSArray *) hyperTableBrokersInCurrentCluster;

// All HyperTable objects
+ (NSArray *) hypertablesInCluster:(id)cluster;
+ (NSArray *) hypertablesInCurrentCluster;

//error code to error message
+ (NSString *)errorFromCode:(int)code;

//initialization
+ (NSEntityDescription *) hypertableDescription;

//	Instances Methods

// ClusterMemberProtocol implementation
- (void) updateStatusWithCompletionBlock:(void (^)(BOOL))codeBlock;
- (NSArray *) services;
- (Service *) serviceWithName:(NSString *)name;

// CellStorage implementation

- (void) updateTablesWithCompletionBlock:(void (^)(void))codeBlock;
- (NSArray *) tables;

- (void)fetchPageFrom:(id)tableID number:(int)number ofSize:(int)size 
  withCompletionBlock:(void (^)(DATA_PAGE))codeBlock;

@property (assign) int lastFetchedIndex;
@property (assign) int lastFetchedTotalIndexes;

@end
