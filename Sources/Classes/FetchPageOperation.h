//
//  FetchPageOperation.h
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 26/7/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <HyperTable.h>

@interface FetchPageOperation : NSOperation {
	HyperTable * hypertable;
	DataPage * page;
	int errorCode;
	
	NSString * tableName;
	int pageIndex;
	int pageSize;
	
	int totalRows;
	int startIndex;
	int stopIndex;
}

@property (nonatomic, retain) HyperTable * hypertable;
@property (assign) int totalRows;
@property (assign) int errorCode;
@property (assign) int pageIndex;
@property (assign) int pageSize;
@property (nonatomic, retain) NSString * tableName;
@property (assign) int startIndex;
@property (assign) int stopIndex;

@property (assign, readonly) DataPage * page;

+ fetchPageFrom:(HyperTable *)hypertable
	   withName:(NSString *)tableName 
		atIndex:(int)pageIndex 
		andSize:(int)pageSize;

- (void)main;

@end
