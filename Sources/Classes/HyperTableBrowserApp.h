//
//  HyperTableBrowserApp.h
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 12/8/09.
//  Copyright AwesomeStanly Lab. 2009 . All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Activities.h"

@interface HyperTableBrowserApp : NSObject {
	Activities * activitiesView;
	
	NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;
}

@property (nonatomic, retain) IBOutlet Activities * activitiesView;

@property (nonatomic, retain, readonly) IBOutlet NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain, readonly) IBOutlet NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) IBOutlet NSManagedObjectContext *managedObjectContext;

- (NSString *)applicationSupportDirectory;
- (BOOL) recreateDataFiles;

@end