//
//  Table.m
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 1/9/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import "Table.h"


@implementation Table

+ (NSEntityDescription *) tableDescription
{
	return [NSEntityDescription entityForName:@"Table" 
					   inManagedObjectContext:[[NSApp delegate] managedObjectContext]];
}

@end
