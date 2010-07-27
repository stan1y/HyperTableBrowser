//
//  SetRowOperation.h
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 27/7/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <ThriftConnection.h>

@interface SetRowOperation : NSOperation {
	ThriftConnection * connection;
	DataRow * row;
	DataPage * page;
	NSString * tableName;
	
	NSString * cellValue;
	NSString * columnName;
	int rowIndex;
	
	int errorCode;
}

@property (assign) NSString * tableName;
@property (assign) NSString * cellValue;
@property (assign) NSString * columnName;
@property (assign) int rowIndex;
@property (assign) ThriftConnection * connection;
@property (assign) int errorCode;
@property (assign) DataRow * row;
@property (assign) DataPage * page;

+ setCellValue:(NSString *)newValue
	  fromPage:(DataPage *)page
	   inTable:(NSString *)tableName 
		 atRow:(NSInteger)rowIndex
	 andColumn:(NSString *)columnName
withConnection:(ThriftConnection *)con;

+ setRow:(DataRow *)row inTable:(NSString*)tableName withConnection:(ThriftConnection *)con;

- (void)main;

@end
