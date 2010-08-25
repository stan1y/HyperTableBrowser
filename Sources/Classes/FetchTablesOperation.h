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
	HyperTable * hypertable;
	int errorCode;
}

@property (retain) HyperTable * hypertable;
@property (assign) int errorCode;

+ fetchTablesFrom:(HyperTable *)hypertable;
- (void)main;

@end
