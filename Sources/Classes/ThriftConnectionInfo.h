//
//  ThriftConnectionInfo.h
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 12/9/09.
//  Copyright 2009 AwesomeStanly Lab. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ThriftConnectionInfo : NSObject {
	NSString * address;
	int port;
}

@property(nonatomic, retain) NSString * address;
@property(assign) int port;

+ (id)infoWithAddress:(NSString*)address andPort:(int)port;

@end
