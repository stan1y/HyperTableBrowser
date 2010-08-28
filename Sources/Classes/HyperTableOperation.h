//
//  HyperTableOperation.h
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 17/8/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <HyperTable.h>
#import <Hadoop.h>
#import <SSHClient.h>

@interface HyperTableStatusOperation : NSOperation {
	HyperTable * hypertable;
}
@property (nonatomic, retain) NSString * errorMessage;
@property (nonatomic, retain) HyperTable * hypertable;
@property (assign) int errorCode;

+ getStatusOfHyperTable:(HyperTable *)hypertable;

- (void)main;

@end

/*
@interface HadoopStatusOperation : NSOperation {
	Hadoop * hadoop;
	
	int errorCode;
	NSString * errorMessage;
}
@property (nonatomic, retain) NSString * errorMessage;
@property (nonatomic, retain) NSManagedObject * server;
@property (assign) int errorCode;

+ getStatusOfHadoop:(Hadoop *)hadoop;

- (void)main;

@end
*/