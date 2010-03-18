//
//  HyperTableServer.h
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 16/2/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <ThriftConnection.h>
#import <ThriftConnectionInfo.h>
#import <Foundation/Foundation.h>

@interface HyperTableServer : NSManagedObject {
	ThriftConnection * connection;
}

@property (assign) ThriftConnection * connection;

+ (HyperTableServer *)serverWithDefaultContext;
+ (NSEntityDescription *) entityDescription;

@end
