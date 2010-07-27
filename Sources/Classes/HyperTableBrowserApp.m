//
//  HyperTableBrowser_AppDelegate.m
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 12/8/09.
//  Copyright AwesomeStanly Lab. 2009 . All rights reserved.
//

#import "HyperTableBrowserApp.h"

@implementation HyperTableBrowserApp

@synthesize window;
@synthesize operations;

@synthesize statusMessageField;
@synthesize statusIndicator;

@synthesize serversView;
@synthesize connectionSheetController;

@synthesize connectMenuItem;
@synthesize showBrowserMenuItem;

@synthesize serversDelegate;
@synthesize serversManager;

@synthesize hqlInterpreterPnl;
@synthesize newTablePnl;

@synthesize toolBarController;
@synthesize newTableController;
@synthesize hqlController;
//@synthesize generalPrefsController;

- (id)init
{
    [super init];
    operations = [[NSOperationQueue alloc] init];
    return self;
}

- (id) getSettingsByName:(NSString *)name
{
	NSLog(@"Getting settings with name %s", [name UTF8String]);
	NSFetchRequest * request = [[NSFetchRequest alloc] init];
	
	NSEntityDescription * entity = [NSEntityDescription entityForName:name
											   inManagedObjectContext:[self managedObjectContext] ];
	
	[request setEntity:entity];
	[request setIncludesPendingChanges:YES];
	NSError * err = nil;
	NSArray * result = [[self managedObjectContext] executeFetchRequest:request 
																					error:&err];
	if (err) {
		NSString * msg = @"getServers: Failed to get servers from datastore";
		[self setMessage:[NSString stringWithFormat:@"Error: %s", [msg UTF8String]]];
		[[NSApplication sharedApplication] presentError:err];
		[err release];
		return nil;
	}
	[entity release];
	[request release];
	
	if ( [result count] <= 0 ) {
		//create new default settings
		id defaults = [NSEntityDescription insertNewObjectForEntityForName:name
									  inManagedObjectContext:[self managedObjectContext] ];
		[self setMessage:[NSString stringWithFormat:@"Loading defaults for %s", 
						  [name UTF8String]]];
		return defaults;
	}
	else if ([result count] > 1) {
		NSString * msg = [NSString stringWithFormat:@"%d results were found for name \"%s\".", 
						  [result count],
						  [name UTF8String]];
		[self setMessage:msg];
		[result release];
		return nil;
	}
	return [result objectAtIndex:0];
}


- (BOOL)windowShouldClose:(id)sender
{
	NSLog(@"Checking running threads...\n");
	
    NSInteger numOperationsRunning = [[operations operations] count];
    if (numOperationsRunning > 0)
    {
		id msg = [NSString stringWithFormat:@"There are %d background operations in progress.", numOperationsRunning];
        NSAlert *alert = [NSAlert alertWithMessageText: msg 
										 defaultButton: @"OK"
									   alternateButton: nil
										   otherButton: nil
							 informativeTextWithFormat: @"Please click the \"Stop\" button before closing."];
        [alert beginSheetModalForWindow: [self window] modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:nil];
    }
    return (numOperationsRunning == 0);
}

- (void)windowWillClose:(NSNotification *)notification
{
	NSLog(@"Saving persisten store...\n");
	[self saveAction:self];
}

-(IBAction)showHideObjectsBrowser:(id)sender
{
	if ([[self window] isVisible]) {
		[showBrowserMenuItem setTitle:@"Show Browser window"];
		[[self window] orderOut:nil];
	}
	else {
		[showBrowserMenuItem setTitle:@"Hide Browser window"];
		[[self window] makeKeyAndOrderFront:self];
	}
}

- (void)applicationDidFinishLaunching:(NSApplication *)application 
{	
	//set initial status
	[self setMessage:@"Application started."];
	[window setTitle:@"HyperTable Browser is not connected" ];
	[statusMessageField setHidden:NO];
	//[[self serversView] setAllowsEmptySelection:YES];
	//NSLog(@"allowsEmptySelection: %d\n", [[self serversView] allowsEmptySelection]);
}

- (void)setMessage:(NSString*)message 
{
	NSLog(@"Browser: %s\n", [message UTF8String]);
	[statusMessageField setTitleWithMnemonic:message];
}

- (void)indicateBusy 
{
	[statusIndicator setHidden:NO];
	[statusIndicator startAnimation:self];
}

- (void)indicateDone 
{
	[statusIndicator stopAnimation:self];
	[statusIndicator setHidden:YES];
}

/**
    Returns the support directory for the application, used to store the Core Data
    store file.  This code uses a directory named "HyperTableBrowser" for
    the content, either in the NSApplicationSupportDirectory location or (if the
    former cannot be found), the system's temporary directory.
 */

- (NSString *)applicationSupportDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
    return [basePath stringByAppendingPathComponent:@"HyperTableBrowser"];
}


/**
    Creates, retains, and returns the managed object model for the application 
    by merging all of the models found in the application bundle.
 */
 
- (NSManagedObjectModel *)managedObjectModel {

    if (managedObjectModel) return managedObjectModel;
	
    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
    return managedObjectModel;
}


/**
    Returns the persistent store coordinator for the application.  This 
    implementation will create and return a coordinator, having added the 
    store for the application to it.  (The directory for the store is created, 
    if necessary.)
 */

- (NSPersistentStoreCoordinator *) persistentStoreCoordinator {

    if (persistentStoreCoordinator) return persistentStoreCoordinator;

    NSManagedObjectModel *mom = [self managedObjectModel];
    if (!mom) {
        NSAssert(NO, @"Managed object model is nil");
        NSLog(@"%@:%s No model to generate a store from", [self class], _cmd);
        return nil;
    }

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *applicationSupportDirectory = [self applicationSupportDirectory];
    NSError *error = nil;
    
    if ( ![fileManager fileExistsAtPath:applicationSupportDirectory isDirectory:NULL] ) {
		if (![fileManager createDirectoryAtPath:applicationSupportDirectory withIntermediateDirectories:NO attributes:nil error:&error]) {
            NSAssert(NO, ([NSString stringWithFormat:@"Failed to create App Support directory %@ : %@", applicationSupportDirectory,error]));
            NSLog(@"Error creating application support directory at %@ : %@",applicationSupportDirectory,error);
            return nil;
		}
    }
    
    NSURL *url = [NSURL fileURLWithPath: [applicationSupportDirectory stringByAppendingPathComponent: @"HyperTableBrowser.xml"]];
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: mom];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSXMLStoreType 
                                                configuration:nil 
                                                URL:url 
                                                options:nil 
                                                error:&error]){
        [[NSApplication sharedApplication] presentError:error];
        [persistentStoreCoordinator release], persistentStoreCoordinator = nil;
        return nil;
    }    

    return persistentStoreCoordinator;
}

/**
    Returns the managed object context for the application (which is already
    bound to the persistent store coordinator for the application.) 
 */
 
- (NSManagedObjectContext *) managedObjectContext {

    if (managedObjectContext) return managedObjectContext;

    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"Failed to initialize the store" forKey:NSLocalizedDescriptionKey];
        [dict setValue:@"There was an error building up the data file." forKey:NSLocalizedFailureReasonErrorKey];
        NSError *error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    managedObjectContext = [[NSManagedObjectContext alloc] init];
    [managedObjectContext setPersistentStoreCoordinator: coordinator];

    return managedObjectContext;
}

/**
    Returns the NSUndoManager for the application.  In this case, the manager
    returned is that of the managed object context for the application.
 */
 
- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window {
    return [[self managedObjectContext] undoManager];
}


/**
    Performs the save action for the application, which is to send the save:
    message to the application's managed object context.  Any encountered errors
    are presented to the user.
 */
 
- (IBAction) saveAction:(id)sender {

    NSError *error = nil;
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%s unable to commit editing before saving", [self class], _cmd);
    }

    if (![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}


/**
    Implementation of the applicationShouldTerminate: method, used here to
    handle the saving of changes in the application managed object context
    before the application terminates.
 */
 
- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {

    if (!managedObjectContext) return NSTerminateNow;

    if (![managedObjectContext commitEditing]) {
        NSLog(@"%@:%s unable to commit editing to terminate", [self class], _cmd);
        return NSTerminateCancel;
    }

    if (![managedObjectContext hasChanges]) return NSTerminateNow;

    NSError *error = nil;
    if (![managedObjectContext save:&error]) {
    
        // This error handling simply presents error information in a panel with an 
        // "Ok" button, which does not include any attempt at error recovery (meaning, 
        // attempting to fix the error.)  As a result, this implementation will 
        // present the information to the user and then follow up with a panel asking 
        // if the user wishes to "Quit Anyway", without saving the changes.

        // Typically, this process should be altered to include application-specific 
        // recovery steps.  
                
        BOOL result = [sender presentError:error];
        if (result) return NSTerminateCancel;

        NSString *question = NSLocalizedString(@"Could not save changes while quitting.  Quit anyway?", @"Quit without saves error question message");
        NSString *info = NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save", @"Quit without saves error question info");
        NSString *quitButton = NSLocalizedString(@"Quit anyway", @"Quit anyway button title");
        NSString *cancelButton = NSLocalizedString(@"Cancel", @"Cancel button title");
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:question];
        [alert setInformativeText:info];
        [alert addButtonWithTitle:quitButton];
        [alert addButtonWithTitle:cancelButton];

        NSInteger answer = [alert runModal];
        [alert release];
        alert = nil;
        
        if (answer == NSAlertAlternateReturn) return NSTerminateCancel;

    }

    return NSTerminateNow;
}


/**
    Implementation of dealloc, to release the retained variables.
 */
 
- (void)dealloc {

    [window release];
    [managedObjectContext release];
    [persistentStoreCoordinator release];
    [managedObjectModel release];
	[operations release];
	
    [super dealloc];
}


@end
