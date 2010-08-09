//
//  DeleteRowOperation.h
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 9/8/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <ThriftConnection.h>

@interface DeleteRowOperation : NSObject {
	ThriftConnection * connection;
	DataRow * row;
	NSString * tableName;
	int errorCode;
}

@property (nonatomic, retain) NSString * tableName;
@property (nonatomic, retain) ThriftConnection * connection;
@property (assign) int errorCode;
@property (assign) DataRow * row;

+ deleteRow:(DataRow *)row inTable:(NSString*)tableName withConnection:(ThriftConnection *)con;

- (void)main;

@end
