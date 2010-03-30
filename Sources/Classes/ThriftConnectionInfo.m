//
//  ThriftConnectionInfo.m
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 12/9/09.
//  Copyright 2009 AwesomeStanly Lab. All rights reserved.
//

#import "ThriftConnectionInfo.h"


@implementation ThriftConnectionInfo

@synthesize address;
@synthesize port;

+ (id)infoWithAddress:(NSString*)address 
			  andPort:(int)port
{
	ThriftConnectionInfo * ci = [[ThriftConnectionInfo alloc] init];
	[ci setAddress:address];
	[ci setPort:port];
	return ci;
}
@end
