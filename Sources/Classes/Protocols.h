//
//  Protocols.h
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 27/8/2010.
//  Copyright 2010 Stanislav Yudin. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SSHClient.h"

#define DATA_PAGE void*

@protocol ClusterMember

- (void) updateStatusWithCompletionBlock:(void (^)(BOOL))codeBlock;
- (NSArray *) services;
- (Service *) serviceWithName:(NSString *)name;

@end

@protocol CellStorage

- (BOOL) isConnected;
- (void) updateTablesWithCompletionBlock:(void (^)(BOOL))codeBlock;
- (NSArray *) tablesArray;

- (void)fetchPageFrom:(id)tableID number:(int)number ofSize:(int)size 
  withCompletionBlock:(void (^)(DATA_PAGE))codeBlock;

- (int) lastFetchedIndex;
- (int) lastFetchedTotalIndexes;

@end
