//
//  ClusterManager.h
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 9/8/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CoreDataManager.h>
#import <HyperTable.h>
#import <SSHClient.h>

@interface ClusterManager : CoreDataManager {
	NSMutableDictionary * hypertableCache;
	NSMutableDictionary * hadoopCache;
	NSMutableDictionary * sshCache;
}

- (ClusterManager *) init;

- (NSArray *)clusters;
- (NSSet *)serversInCluster:(NSManagedObject *)cluster;

//- (HyperTable *)hypertableOnServer:(NSManagedObject *)server;
//- (SSHClient *)remoteShellOnServer:(NSManagedObject *)server;

- (NSArray *)allHypertableBrokers;
- (NSArray *)allHadoopBrokers;

- (NSArray *)servicesOnServer:(NSManagedObject *)server;
- (NSManagedObject *)serviceOnServer:(NSManagedObject *)server withName:(NSString *)name;

@end
