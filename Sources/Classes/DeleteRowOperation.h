//
//  DeleteRowOperation.h
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 9/8/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <HyperTable.h>

@interface DeleteRowOperation : NSObject {
	//HyperTable * connection;
	DataRow * row;
	NSString * tableName;
	int errorCode;
}

@property (nonatomic, retain) NSString * tableName;
//@property (nonatomic, retain) HyperTable * connection;
@property (assign) int errorCode;
@property (assign) DataRow * row;

//+ deleteRow:(DataRow *)row inTable:(NSString*)tableName withConnection:(HyperTable *)con;

- (void)main;

@end
