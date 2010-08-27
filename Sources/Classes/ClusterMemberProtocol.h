//
//  ClusterMemberProtocol.h
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 27/8/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@protocol ClusterMemberProtocol

- (void) updateWithCompletionBlock:(void (^)(void)) codeBlock;
- (void) reconnectWithCompletionBlock:(void (^)(void)) codeBlock;
- (void) disconnect;
- (BOOL) isConnected;

@end
