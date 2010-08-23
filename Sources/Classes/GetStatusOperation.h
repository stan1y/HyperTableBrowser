//
//  GetStatusOperation.h
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 17/8/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Server.h>
#import <SSHClient.h>

@interface GetStatusOperation : NSOperation {
	Server * server;
	
	int errorCode;
	NSString * errorMessage;
}
@property (nonatomic, retain) NSString * errorMessage;
@property (nonatomic, retain) NSManagedObject * server;
@property (assign) int errorCode;

+ getStatusOfServer:(Server *)server;

- (void)main;

@end
