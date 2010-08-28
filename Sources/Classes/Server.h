//
//  Server.h
//  Class providing access to remove server over ssh
//
//  Created by Stanislav Yudin on 23/8/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SSHClient.h"
#import "Service.h"
#import "Protocols.h"

@interface Server : NSManagedObject  {
	SSHClient * sshClient;
}

+ (NSEntityDescription *) serverDescription;
- (SSHClient *) remoteShell;

@end
