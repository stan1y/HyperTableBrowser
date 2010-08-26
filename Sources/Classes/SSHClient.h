//
//  SSHClient.h
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 15/8/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SSHClient : NSObject {	
	NSTask * ssh;
	NSLock * sshLock;
	NSMutableArray * arguments;
	NSPipe * stdoutPipe;
	NSPipe * stderrPipe;
	NSString * targetIpAddress;
	
	NSString * sshOutput;
	NSString * sshError;
}

@property (nonatomic, readonly, retain) NSLock * sshLock;
@property (nonatomic, readonly, retain) NSString * targetIpAddress;

- (id) initClientTo:(NSString *)address onPort:(int)port asUser:(NSString *)user withKey:(NSString *)privateKeyPath;

- (int)runCommand:(NSString*)command;
- (NSString *) output;
- (NSString *) error;

@end