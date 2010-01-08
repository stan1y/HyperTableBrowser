//
//  KnownServer.m
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 12/23/09.
//  Copyright 2009 AwesomeStanly Lab. All rights reserved.
//

#import "KnownServer.h"


@implementation KnownServer


+ (KnownServer *)knownServerWithDefaultContext
{
	return [NSEntityDescription insertNewObjectForEntityForName:@"KnownServer" inManagedObjectContext:[[NSApp delegate] managedObjectContext] ];
}
			

@end
