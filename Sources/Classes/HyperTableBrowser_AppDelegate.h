//
//  HyperTableBrowser_AppDelegate.h
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 12/8/09.
//  Copyright AwesomeStanly Lab. 2009 . All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <ThriftConnection.h>
#import <ConnectionSheetController.h>
#import <HqlInterpreter.h>
#import <ServersDelegate.h>


@interface HyperTableBrowser_AppDelegate : NSObject 
{
    NSWindow *window;
	
	NSMenuItem * connectMenuItem;
	NSMenuItem * showHqlInterperterMenuItem;
	NSMenuItem * showBrowserMenuItem;
	
	NSTextField *statusMessageField;
	NSProgressIndicator *statusIndicator;
    
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;
	
	ConnectionSheetController * connectionSheetController;
	
	ServersDelegate * serversDelegate;
	NSMutableDictionary * connectionsDict;
	
	//interpreter inst
	HqlInterpreter * hqlInst;
}

@property (nonatomic, retain) IBOutlet NSWindow *window;

@property (assign) IBOutlet ConnectionSheetController * connectionSheetController;
@property (assign) NSMutableDictionary * connectionsDict;
@property (assign) IBOutlet ServersDelegate * serversDelegate;

@property (assign) IBOutlet NSTextField *statusMessageField;
@property (assign) IBOutlet NSProgressIndicator *statusIndicator;
@property (assign) IBOutlet NSMenuItem * connectMenuItem;

@property (assign) IBOutlet NSMenuItem * showHqlInterperterMenuItem;
@property (assign) IBOutlet NSMenuItem * showBrowserMenuItem;

@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;

//show status message on the bottom
- (void)setMessage:(NSString*)message;

//start operation indicator
- (void)indicateBusy;

//stop operation indicator
- (void)indicateDone;

//Returns YES is app is connected
- (BOOL)isConnected;

//returns currently selected connected server in Servers outline
- (ThriftConnection *)getCurrentConnection ;

//returns connection to specified server
- (ThriftConnection *)getConnectionForServer:(NSManagedObject*)server;

//shows or hides HQL Iterpreter
- (IBAction)showHideHqlInterperter:(id)sender;

//shows or hides Objects browser
- (IBAction)showHideObjectsBrowser:(id)sender;

//create and display HQL iterpreter window
- (void)openHqlInterpreter;
@end
