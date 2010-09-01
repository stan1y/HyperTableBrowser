//
//  Hadoop.m
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 23/8/2010.
//  Copyright 2010 Stanislav Yudin. All rights reserved.
//

#import "Hadoop.h"

@implementation Hadoop

+ (NSEntityDescription *) hadoopDescription
{
	return [NSEntityDescription entityForName:@"Hadoop" 
					   inManagedObjectContext:[[NSApp delegate] managedObjectContext]];
}

@end
