//
//  Server.h
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 23/8/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SSHClient.h"
#import "Service.h"
#import "ClusterMemberProtocol.h"

@interface Server : NSManagedObject <ClusterMemberProtocol>  {
	SSHClient * sshClient;
}

+ (NSEntityDescription *) serverDescription;

- (SSHClient *) remoteShell;
- (NSArray *) services;
- (Service *) serviceWithName:(NSString *)name;

@end
