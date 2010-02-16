//
//  HyperTable.m
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 16/2/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import "HyperTable.h"


@implementation HyperTable

+ (HyperTable *)tableWithDefaultContext
{
	return [NSEntityDescription insertNewObjectForEntityForName:@"HyperTable" inManagedObjectContext:[[NSApp delegate] managedObjectContext] ];
}

+ (NSEntityDescription *) entityDescription
{
	return [NSEntityDescription entityForName:@"HyperTable" inManagedObjectContext:[[NSApp delegate] managedObjectContext] ];
}


@end

