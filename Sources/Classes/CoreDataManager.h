//
//  CoreDataManager.h
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 9/8/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface CoreDataManager : NSObject {
	NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;
	NSString * dataFileName;
}

@property (nonatomic, retain) NSString * dataFileName;
@property (nonatomic, retain, readonly) IBOutlet NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain, readonly) IBOutlet NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) IBOutlet NSManagedObjectContext *managedObjectContext;

@end
