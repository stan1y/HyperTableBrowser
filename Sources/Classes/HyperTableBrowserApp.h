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
	
	NSWindow * clustersBrowserWindow;
	ClustersBrowser * clustersBrowser;
	
	NSWindow * tablesBrowserWindow;
	TablesBrowser * tablesBrowser;
	
	NSWindow * hqlWindow;
	HqlController * hqlController;
	
	NSPanel * inspectorPanel;
	Inspector * inspector;
	
	NSOperationQueue * operations;
	
	NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;
}

@property (nonatomic, retain, readonly) IBOutlet NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain, readonly) IBOutlet NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) IBOutlet NSManagedObjectContext *managedObjectContext;

@property (nonatomic, retain) IBOutlet NSPanel * inspectorPanel;
@property (nonatomic, retain) IBOutlet Inspector * inspector;

@property (nonatomic, retain) IBOutlet  NSWindow * clustersBrowserWindow;
@property (nonatomic, retain) IBOutlet ClustersBrowser * clustersBrowser;

@property (nonatomic, retain) IBOutlet NSWindow * tablesBrowserWindow;
@property (nonatomic, retain) IBOutlet TablesBrowser * tablesBrowser;

@property (nonatomic, retain) IBOutlet NSWindow * hqlWindow;
@property (nonatomic, retain) IBOutlet HqlController * hqlController;

@property (nonatomic, readonly) NSOperationQueue * operations;

- (void) showErrorDialog:(int)errorCode
			 message:(NSString *)description 
		  withReason:(NSString *)reason;
- (NSString *)applicationSupportDirectory;
- (id) getSettingsByName:(NSString *)name;

@end