//
//  HyperTableServer.m
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 16/2/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import "HyperTableServer.h"

@implementation HyperTableServer

@synthesize connection;

+ (HyperTableServer *)serverWithDefaultContext
{
	return [NSEntityDescription insertNewObjectForEntityForName:@"HyperTableServer" inManagedObjectContext:[[NSApp delegate] managedObjectContext] ];
}

+ (NSEntityDescription *) entityDescription
{
	return [NSEntityDescription entityForName:@"HyperTableServer" inManagedObjectContext:[[NSApp delegate] managedObjectContext] ];
}

@end
