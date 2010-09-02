//
//  SetRowOperation.h
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 27/7/2010.
//  Copyright 2010 Stanislav Yudin. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "HyperTable.h"

@interface SetCellOperation : NSOperation {
	Server<CellStorage> * storage;
	NSString * tableName;
	id cellValue;
	NSString * columnName;
	NSString * rowKey;
	int errorCode;
}

@property (nonatomic, retain) NSString * tableName;
@property (nonatomic, retain) id cellValue;
@property (nonatomic, retain) NSString * rowKey;
@property (nonatomic, retain) NSString * columnName;
@property (nonatomic, retain) HyperTable * hypertable;
@property (assign) int errorCode;

+ setCellValue:(id)newValue forRow:(NSString *)rowKey andColumn:(NSString *)columnName inTable:(NSString *)tableName onServer:(HyperTable *)onHypertable;

- (void)main;

@end
