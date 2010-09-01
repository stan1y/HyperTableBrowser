//
//  SetRowOperation.h
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 27/7/2010.
//  Copyright 2010 Stanislav Yudin. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "HyperTable.h"

@interface SetRowOperation : NSOperation {
	HyperTable * hypertable;
	DataRow * row;
	DataPage * page;
	NSString * tableName;
	
	NSString * cellValue;
	NSString * columnName;
	int rowIndex;
	
	int errorCode;
}

@property (nonatomic, retain) NSString * tableName;
@property (nonatomic, retain) NSString * cellValue;
@property (nonatomic, retain) NSString * columnName;
@property (nonatomic, retain) HyperTable * hypertable;
@property (assign) int rowIndex;
@property (assign) int errorCode;
@property (assign) DataRow * row;
@property (assign) DataPage * page;


+ setCellValue:(NSString *)newValue
	  fromPage:(DataPage *)page
	   inTable:(NSString *)tableName 
		 atRow:(NSInteger)rowIndex
	 andColumn:(NSString *)columnName
	  onServer:(HyperTable *)onHypertable;

+ setRow:(DataRow *)row fromPage:(DataPage *)page inTable:(NSString*)tableName onServer:(HyperTable *)onHypertable;

- (void)main;

@end
