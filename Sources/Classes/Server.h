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

enum ServerStatus {
	STATUS_OPERATIONAL = 0,
	STATUS_ERROR = 1,
	STATUS_PENDING = 2
};

@interface Server : NSManagedObject  {
	SSHClient * sshClient;
}

+ (NSEntityDescription *) serverDescription;
+ (NSString *)stringForStatus:(int)status;

- (SSHClient *) remoteShell;
- (int) statusInt;
- (NSString *) statusString;

@end
