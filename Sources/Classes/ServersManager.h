//
//  ServersManager.h
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 16/2/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <ThriftConnection.h>
#import <ThriftConnectionInfo.h>
#import <HyperTableServer.h>

@interface ServersManager : NSObject {
	NSMutableDictionary * connectionsCache;
}

- (NSArray *)getServers;

- (HyperTableServer *)getServer:(NSString *)hostname;
- (void)reconnectServer:(NSManagedObject *)server;

- (ThriftConnection *)getConnection:(NSString *)hostname;
- (ThriftConnection *)getConnectionForServer:(NSManagedObject *)server;

- (void)setConnection:(ThriftConnection *)connection 
			forServer:(NSManagedObject*)server;

@end
