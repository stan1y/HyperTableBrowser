//
//  GetStatusOperation.h
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 17/8/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <SSHClient.h>

@interface GetStatusOperation : NSOperation {
	SSHClient * sshClient;
	NSManagedObject * server;
	
	int errorCode;
	NSString * errorMessage;
}
@property (nonatomic, retain) NSString * errorMessage;
@property (nonatomic, retain) SSHClient * sshClient;
@property (nonatomic, retain) NSManagedObject * server;
@property (assign) int errorCode;

+ getStatusFrom:(SSHClient *)client forServer:(NSManagedObject *)server;

- (void)main;

@end
