//
//  HyperTableBrowserApp.h
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 12/8/09.
//  Copyright AwesomeStanly Lab. 2009 . All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <ConnectionSheetController.h>
#import <HqlController.h>
#import <ClustersBrowser.h>
#import <TablesBrowser.h>
#import <ServersManager.h>

@interface HyperTableBrowserApp : NSObject 
{
	ServersManager * serversManager;
	
	NSWindow * clustersBrowserWindow;
	ClustersBrowser * clustersBrowser;
	
	NSWindow * tablesBrowserWindow;
	TablesBrowser * tablesBrowser;
	
	NSWindow * hqlWindow;
	HqlController * hqlController;
	
	NSOperationQueue * operations;
	
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;
}

@property (nonatomic, readonly) ServersManager * serversManager;

@property (nonatomic, retain) IBOutlet  NSWindow * clustersBrowserWindow;
@property (nonatomic, retain) IBOutlet ClustersBrowser * clustersBrowser;

@property (nonatomic, retain) IBOutlet NSWindow * tablesBrowserWindow;
@property (nonatomic, retain) IBOutlet TablesBrowser * tablesBrowser;

@property (nonatomic, retain) IBOutlet NSWindow * hqlWindow;
@property (nonatomic, retain) IBOutlet HqlController * hqlController;

@property (nonatomic, readonly) NSOperationQueue * operations;

- (id) getSettingsByName:(NSString *)name;

- (void) showErrorDialog:(int)errorCode
			 message:(NSString *)description 
		  withReason:(NSString *)reason;
@end