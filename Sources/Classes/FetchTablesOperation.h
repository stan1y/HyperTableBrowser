//
//  FetchTablesOperation.h
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 26/7/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <HyperTable.h>

@interface FetchTablesOperation : NSOperation {
	HyperTable * connection;
	int errorCode;
}

@property (retain) HyperTable * connection;
@property (assign) int errorCode;

+ fetchTablesFromConnection:(HyperTable *)conn;
- (void)main;

@end
