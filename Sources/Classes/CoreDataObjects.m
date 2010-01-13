//
//  CoreDataObjects.m
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 12/23/09.
//  Copyright 2009 AwesomeStanly Lab. All rights reserved.
//

#import "CoreDataObjects.h"


@implementation Server

+ (Server *)serverWithDefaultContext
{
	return [NSEntityDescription insertNewObjectForEntityForName:@"Server" inManagedObjectContext:[[NSApp delegate] managedObjectContext] ];
}

+ (NSEntityDescription *) entityDescription
{
	return [NSEntityDescription entityForName:@"Server" inManagedObjectContext:[[NSApp delegate] managedObjectContext] ];
}

@end

@implementation Table

+ (Table *)tableWithDefaultContext
{
	return [NSEntityDescription insertNewObjectForEntityForName:@"Table" inManagedObjectContext:[[NSApp delegate] managedObjectContext] ];
}

+ (NSEntityDescription *) entityDescription
{
	return [NSEntityDescription entityForName:@"Table" inManagedObjectContext:[[NSApp delegate] managedObjectContext] ];
}


@end
