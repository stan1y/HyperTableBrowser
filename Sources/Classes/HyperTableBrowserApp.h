//
//  HyperTableBrowserApp.h
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 12/8/09.
//  Copyright AwesomeStanly Lab. 2009 . All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <HqlController.h>
#import <ClustersBrowser.h>
#import <TablesBrowser.h>
#import <Inspector.h>

@interface HyperTableBrowserApp : NSObject {
	NSOperationQueue * operations;
	
	NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;
}

@property (nonatomic, retain, readonly) IBOutlet NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain, readonly) IBOutlet NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) IBOutlet NSManagedObjectContext *managedObjectContext;

@property (nonatomic, readonly) NSOperationQueue * operations;

- (NSString *)applicationSupportDirectory;
- (BOOL) recreateDataFiles;

@end