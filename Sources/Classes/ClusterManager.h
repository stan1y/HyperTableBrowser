//
//  ClusterManager.h
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 9/8/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CoreDataManager.h>
#import <ThriftConnection.h>
#import <HyperTable.h>

@interface ClusterManager : CoreDataManager {
	NSMutableDictionary * hypertableCache;
	NSMutableDictionary * hadoopCache;
}

//+ (ClusterManager *) clusterManagerFromFile:(NSString *)filename;
- (ClusterManager *) init;

- (NSArray *)clusters;
- (id)serversInCluster:(NSManagedObject *)cluster;

- (HyperTable *)hypertableOnServer:(NSManagedObject *)server;
- (ThriftConnection *)hadoopOnServer:(NSManagedObject *)server;

- (NSArray *)allHypertableBrokers;
- (NSArray *)allHadoopBrokers;

@end
