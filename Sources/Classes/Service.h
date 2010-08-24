//
//  Service.h
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 23/8/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface Service : NSManagedObject {
	
}

+ (NSEntityDescription *) serviceDescription;
- (id) runsOnServer;

+ (NSManagedObject *) masterService:(NSManagedObjectContext *)inContent 
						   onServer:(NSManagedObject *)server;

+ (NSManagedObject *) rangerService:(NSManagedObjectContext *)inContent
						   onServer:(NSManagedObject *)server;

+ (NSManagedObject *) dfsBrokerService:(NSManagedObjectContext *)inContent
							  onServer:(NSManagedObject *)server
							   withDfs:(NSString *)dfs;

+ (NSManagedObject *) hyperspaceService:(NSManagedObjectContext *)inContent
							   onServer:(NSManagedObject *)server;

+ (NSManagedObject *) thriftService:(NSManagedObjectContext *)inContent
						   onServer:(NSManagedObject *)server;

@end
