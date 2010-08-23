//
//  Service.m
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 23/8/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import "Service.h"

@implementation Service

+ (NSEntityDescription *) serviceDescription
{
	return [NSEntityDescription entityForName:@"Service" 
					   inManagedObjectContext:[[NSApp delegate] managedObjectContext]];
}

- (id) runsOnServer
{
	return [self valueForKey:@"runsOnServer"];
}

@end
