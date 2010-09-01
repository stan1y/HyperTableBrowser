//
//  Cluster.h
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 23/8/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Server.h>

// Cluster itself implements the same protocol
// as used by members of it.
// update:WithCompletitionBlock simply being called
// for each memeber of the cluster.
@interface Cluster : NSManagedObject {

}

+ (NSEntityDescription *) clusterDescription;

+ (Cluster *) clusterWithName:(NSString *)name;
+ (NSArray *) clusters;
- (NSArray *) members;

@end
