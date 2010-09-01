//
//  ServiceOperation.h
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 24/8/2010.
//  Copyright 2010 Stanislav Yudin. All rights reserved.
//

#import <Cocoa/Cocoa.h>

enum ServiceOperationFlag {
	SERVICE_START,
	SERVICE_STOP
};

@interface ServiceOperation : NSOperation {
	id service;
	int flag;
	
	NSString * cmd;
	NSString * cmdOutput;
	int errorCode;
}

+ (ServiceOperation *) startService:(id)service;
+ (ServiceOperation *) stopService:(id)service;

- (void) main;

@property (nonatomic, retain) id service;
@property (nonatomic, retain) NSString * cmdOutput;
@property (nonatomic, retain, readonly) NSString * cmd;
@property (assign) int flag;
@property (readonly) int errorCode;

@end
