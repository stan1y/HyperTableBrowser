//
//  SSHClient.h
//  Ore Foundry
//
//  Created by Stanislav Yudin on 15/8/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface SSHClient : NSObject {	
	NSTask * ssh;
	NSMutableArray * arguments;
	NSPipe * stdoutPipe;
	NSPipe * stderrPipe;
	
}

- (id) initClientTo:(NSString *)address onPort:(int)port asUser:(NSString *)user;
- (id) initClientTo:(NSString *)address onPort:(int)port asUser:(NSString *)user withKey:(NSString *)privateKeyPath;

- (void) close;

- (int)runCommand:(NSString*)command;
- (NSString *) output;
- (NSString *) error;

@end
