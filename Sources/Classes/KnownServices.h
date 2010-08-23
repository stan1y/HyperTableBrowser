//
//  KnownServices.h
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 22/8/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface KnownServices : NSObject {

}

+ (NSManagedObject *) newMasterService:(NSManagedObjectContext *)inContent 
							  onServer:(NSManagedObject *)server;
+ (NSManagedObject *) newRangerService:(NSManagedObjectContext *)inContent
							  onServer:(NSManagedObject *)server;
+ (NSManagedObject *) newDfsBrokerService:(NSManagedObjectContext *)inContent
								 onServer:(NSManagedObject *)server
								  withDfs:(NSString *)dfs;
+ (NSManagedObject *) newHyperspaceService:(NSManagedObjectContext *)inContent
								  onServer:(NSManagedObject *)server;
+ (NSManagedObject *) newThriftService:(NSManagedObjectContext *)inContent
							  onServer:(NSManagedObject *)server;
//+ (NSManagedObject *) newHdfsbrkService:(NSManagedObjectContext *)inContent;

@end
