//
//  HyperTableBrowserApp.h
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 12/8/09.
//  Copyright AwesomeStanly Lab. 2009 . All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <ThriftConnection.h>
#import <ConnectionSheetController.h>
#import <HqlController.h>
#import <ToolBarController.h>
#import <NewTableController.h>
#import <ServersDelegate.h>
#import <ServersManager.h>

@interface HyperTableBrowserApp : NSObject 
{
    NSWindow * window;
	NSOperationQueue * operations;
	
	NSPanel * hqlInterpreterPnl;
	NSPanel * newTablePnl;
	
	NSMenuItem * connectMenuItem;
	NSMenuItem * showBrowserMenuItem;
	
	NSOutlineView * serversView;
	
	NSTextField *statusMessageField;
	NSProgressIndicator *statusIndicator;
    
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;
	
	ConnectionSheetController * connectionSheetController;
	
	ServersDelegate * serversDelegate;
	ServersManager * serversManager;
	
	ToolBarController * toolBarController;
	HqlController * hqlController;
	NewTableController * newTableController;
	//GeneralPreferencesController * generalPrefsController;
}
//@property (nonatomic, retain) IBOutlet GeneralPreferencesController * generalPrefsController;
@property (nonatomic, assign) IBOutlet HqlController * hqlController;
@property (nonatomic, assign) IBOutlet NewTableController * newTableController;
@property (nonatomic, assign) IBOutlet ToolBarController * toolBarController;
@property (nonatomic, retain) IBOutlet NSWindow *window;
@property (nonatomic, retain) IBOutlet NSPanel * hqlInterpreterPnl;
@property (nonatomic, retain) IBOutlet NSPanel * newTablePnl;

@property (assign) IBOutlet NSOutlineView * serversView;

@property (assign) IBOutlet ConnectionSheetController * connectionSheetController;
@property (assign) IBOutlet ServersDelegate * serversDelegate;

@property (assign) IBOutlet NSTextField *statusMessageField;
@property (assign) IBOutlet NSProgressIndicator *statusIndicator;

@property (assign) IBOutlet NSMenuItem * connectMenuItem;
@property (assign) IBOutlet NSMenuItem * showBrowserMenuItem;

@property (nonatomic, retain, readonly) NSOperationQueue * operations;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;

@property (assign) IBOutlet ServersManager * serversManager;

//show status message on the bottom
- (void)setMessage:(NSString*)message;

//start operation indicator
- (void) indicateBusy;

//stop operation indicator
- (void) indicateDone;

//shows or hides Objects browser
- (IBAction)showHideObjectsBrowser:(id)sender;

//called when objects browser windows is about to close
- (void)windowWillClose:(NSNotification *)notification;

//save store action
- (IBAction) saveAction:(id)sender;

- (id)getSettingsByName:(NSString *)name;

@end
