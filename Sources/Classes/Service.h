//
//  Service.h
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 23/8/2010.
//  Copyright 2010 Stanislav Yudin. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface Service : NSManagedObject {
	
}

+ (NSEntityDescription *) serviceDescription;
- (void) start:(void (^)(void)) codeBlock;
- (void) stop:(void (^)(void)) codeBlock;
- (BOOL) isRunning;

/* Defined services */

+ (Service *) masterService:(NSManagedObjectContext *)inContent 
						   onServer:(NSManagedObject *)server;

+ (Service *) rangerService:(NSManagedObjectContext *)inContent
						   onServer:(NSManagedObject *)server;

+ (Service *) dfsBrokerService:(NSManagedObjectContext *)inContent
							  onServer:(NSManagedObject *)server
							   withDfs:(NSString *)dfs;

+ (Service *) hyperspaceService:(NSManagedObjectContext *)inContent
							   onServer:(NSManagedObject *)server;

+ (Service *) thriftService:(NSManagedObjectContext *)inContent
						   onServer:(NSManagedObject *)server;

@end
