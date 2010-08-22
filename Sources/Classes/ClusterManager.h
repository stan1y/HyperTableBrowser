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
	
	NSArrayController * clustersController;
	NSArrayController * membersController;
}

@property (nonatomic, retain) IBOutlet NSArrayController * clustersController;
@property (nonatomic, retain) IBOutlet NSArrayController * membersController;

- (ClusterManager *) init;

- (NSArray *)clusters;
- (id)serversInCluster:(NSManagedObject *)cluster;

- (HyperTable *)hypertableOnServer:(NSManagedObject *)server;
- (SSHClient *)remoteShellOnServer:(NSManagedObject *)server;

- (NSManagedObject *) selectedCluster;
- (NSManagedObject *) selectedMember;

- (NSArray *)allHypertableBrokers;
- (NSArray *)allHadoopBrokers;

- (NSManagedObject *)serviceOnServer:(NSManagedObject *)server withName:(NSString *)name;

@end
