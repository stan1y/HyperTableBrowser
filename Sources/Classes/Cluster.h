//
//  Cluster.h
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 23/8/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Server.h>

@interface Cluster : NSManagedObject {

}

+ (NSEntityDescription *) clusterDescription;
+ (NSArray *) clusters;

- (NSSet *) servers;

@end
