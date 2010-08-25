//
//  DeleteRowOperation.h
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 9/8/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <HyperTable.h>

@interface DeleteRowOperation : NSOperation {
	HyperTable * hypertable;
	DataRow * row;
	NSString * tableName;
	int errorCode;
}

@property (nonatomic, retain) NSString * tableName;
@property (nonatomic, retain) HyperTable * hypertable;
@property (assign) int errorCode;
@property (assign) DataRow * row;

+ deleteRow:(DataRow *)row inTable:(NSString*)tableName onServer:(HyperTable *)hypertable;

- (void)main;

@end
