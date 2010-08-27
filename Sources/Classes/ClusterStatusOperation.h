//
//  ClusterStatusOperation.h
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 27/8/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Cluster.h"

@interface ClusterStatusOperation : NSOperation {
	Cluster * cluster;
	
	NSLock * operationsLock;
	int operationsCount;
}

@property (nonatomic, retain) Cluster * cluster;

+ (ClusterStatusOperation *) getStatusOfCluster:(Cluster *)aCluster;
- (void) main;

@end
