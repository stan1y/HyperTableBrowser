//
//  HyperTableBrowser_AppDelegate.m
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 12/8/09.
//  Copyright AwesomeStanly Lab. 2009 . All rights reserved.
//

#import "HyperTableBrowserApp.h"
#import <Utility.h>

@implementation HyperTableBrowserApp

@synthesize hqlWindow;
@synthesize hqlController;

@synthesize tablesBrowserWindow;
@synthesize tablesBrowser;

@synthesize clustersBrowserWindow;
@synthesize clustersBrowser;

@synthesize clusterManager;
@synthesize settingsManager;

@synthesize inspector;
@synthesize inspectorPanel;

@synthesize operations;

+ (void) initialize
{
	//register value transformers
	NSValueTransformer * statusTransformer = [[StatusValueTransformer alloc] init];
	[NSValueTransformer setValueTransformer:statusTransformer forName:@"StatusValueTransformer"];
	NSValueTransformer * summaryTransformer = [[ServerSummaryTransformer alloc] init];
	[NSValueTransformer setValueTransformer:summaryTransformer forName:@"ServerSummaryTransformer"];
}

- (id)init
{
	if (self = [super init]) {
		operations = [[NSOperationQueue alloc] init];
	}
	
    return self;
}

- (void) showErrorDialog:(int)errorCode
			 message:(NSString *)description 
		  withReason:(NSString *)reason
{
	NSMutableDictionary * dict = [NSMutableDictionary dictionary];
	[dict setValue:description forKey:NSLocalizedDescriptionKey];
	[dict setValue:reason forKey:NSLocalizedFailureReasonErrorKey];
	NSError * error = [NSError errorWithDomain:@"HyperTableBrowser" code:errorCode userInfo:dict];
	[[NSApplication sharedApplication] presentError:error];
}

- (void)applicationDidFinishLaunching:(NSApplication *)application 
{
	//show clusters browser
	[[self clustersBrowserWindow] orderFront:self];
	[[self clustersBrowser] setMessage:@"Application started."];
	[[[self clustersBrowser] statusMessageField] setHidden:NO];
	
	//define cluster if none
	id clusters = [[self clusterManager] clusters];
	if ( ![clusters count] ) {
		[[self clustersBrowser] showNewClusterDialog:application];
	}
	//register inspector's observer
	[[[self clusterManager] membersController] addObserver:inspector
			  forKeyPath:@"selection"
                 options:(NSKeyValueObservingOptionNew |
						  NSKeyValueObservingOptionOld)
				 context:NULL];
}
/**
    Returns the support directory for the application, used to store the Core Data
    store file.  This code uses a directory named "HyperTableBrowser" for
    the content, either in the NSApplicationSupportDirectory location or (if the
    former cannot be found), the system's temporary directory.
 */

- (NSString *)applicationSupportDirectory 
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
    return [basePath stringByAppendingPathComponent:@"HyperTableBrowser"];
}

/**
    Returns the NSUndoManager for the application.  In this case, the manager
    returned is that of the managed object context for the application.
 */
 
- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window {
    return [[[self clusterManager] managedObjectContext] undoManager];
}


/**
    Performs the save action for the application, which is to send the save:
    message to the application's managed object context.  Any encountered errors
    are presented to the user.
 */
 
- (IBAction) saveAction:(id)sender {

    NSError *error = nil;
    
    if (![[[self clusterManager] managedObjectContext] commitEditing]) {
        NSLog(@"%@:%s unable to commit editing before saving", [self class], _cmd);
    }

    if (![[[self clusterManager] managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
	
	if (![[[self settingsManager] managedObjectContext] commitEditing]) {
        NSLog(@"%@:%s unable to commit editing before saving", [self class], _cmd);
    }
	
    if (![[[self settingsManager] managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}


/**
    Implementation of the applicationShouldTerminate: method, used here to
    handle the saving of changes in the application managed object context
    before the application terminates.
 */
 
- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {

    if (![[self clusterManager] managedObjectContext]) return NSTerminateNow;

    if (![[[self clusterManager] managedObjectContext] commitEditing]) {
        NSLog(@"%@:%s unable to commit editing to terminate", [self class], _cmd);
        return NSTerminateCancel;
    }

    if (![[[self clusterManager] managedObjectContext] hasChanges]) return NSTerminateNow;

    NSError *error = nil;
    if (![[[self clusterManager] managedObjectContext] save:&error]) {
    
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
 
- (void)dealloc 
{
	[hqlWindow release];
	[hqlController release];
	
	[tablesBrowserWindow release];
	[tablesBrowser release];
	
	[clustersBrowserWindow release];
	[clustersBrowser release];
	
	[inspectorPanel release];
	[inspector release];
	
	[operations release];
	
	[clusterManager release];
	[settingsManager release];
	
    [super dealloc];
}


@end
