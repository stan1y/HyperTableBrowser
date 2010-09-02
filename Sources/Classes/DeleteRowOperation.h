//
//  DeleteRowOperation.h
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 9/8/2010.
//  Copyright 2010 Stanislav Yudin. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <HyperTable.h>

@interface DeleteRowOperation : NSOperation {
	HyperTable * hypertable;
	NSString * rowKey;
	NSString * tableName;
	int errorCode;
}

@property (nonatomic, retain) NSString * tableName;
@property (nonatomic, retain) HyperTable * hypertable;
@property (assign) int errorCode;
@property (nonatomic, retain) NSString * rowKey;

+ deleteRow:(NSString *)rowKey inTable:(NSString*)tableName onServer:(HyperTable *)hypertable;

- (void)main;

@end
