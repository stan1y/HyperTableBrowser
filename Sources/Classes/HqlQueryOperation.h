//
//  HqlQueryOperation.h
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 26/7/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <HyperTable.h>

@interface HqlQueryOperation : NSOperation {
	HyperTable * connection;
	NSString * query;
	DataPage * page;
	int errorCode;
}

@property (nonatomic, retain) HyperTable * connection;
@property (assign) int errorCode;
@property (nonatomic, retain) NSString * query;

@property (assign, readonly) DataPage * page;

+ queryHql:(NSString *)query withConnection:(HyperTable *)con;
- (void)main;

@end
