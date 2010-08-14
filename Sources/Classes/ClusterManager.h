//
//  ClusterManager.h
//  Ore Foundry
//
//  Created by Stanislav Yudin on 9/8/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CoreDataManager.h>
#import <HyperTable.h>

@interface ClusterManager : CoreDataManager {
	NSMutableDictionary * hypertableCache;
	NSMutableDictionary * hadoopCache;
}

- (ClusterManager *) init;

- (NSArray *)clusters;
- (id)serversInCluster:(NSManagedObject *)cluster;

- (HyperTable *)hypertableOnServer:(NSManagedObject *)server;

- (NSArray *)allHypertableBrokers;
- (NSArray *)allHadoopBrokers;

@end
