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

@synthesize inspector;
@synthesize inspectorPanel;

@synthesize operations;

#pragma mark Initialization

+ (void) initialize
{
	//register value transformers
	NSValueTransformer * statusTransformer = [[StatusValueTransformer alloc] init];
	[NSValueTransformer setValueTransformer:statusTransformer forName:@"StatusValueTransformer"];
	[statusTransformer release];
	NSValueTransformer * summaryTransformer = [[ServerSummaryTransformer alloc] init];
	[NSValueTransformer setValueTransformer:summaryTransformer forName:@"ServerSummaryTransformer"];
	[summaryTransformer release];
}

- (void)applicationDidFinishLaunching:(NSApplication *)application 
{
	//show clusters browser
	[[self clustersBrowserWindow] orderFront:self];
	[[self clustersBrowser] setMessage:@"Application started."];
	[[[self clustersBrowser] statusMessageField] setHidden:NO];
	
	//define cluster if none
	if ( ![[Cluster clusters] count] ) {
		[self defineNewCluster:self];
	}
}


- (id)init
{
	if (self = [super init]) {
		operations = [[NSOperationQueue alloc] init];
	}
	
    return self;
}

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
	
	[managedObjectContext release];
    [persistentStoreCoordinator release];
    [managedObjectModel release];
	
    [super dealloc];
}

#pragma mark Application Utilities

- (NSString *)applicationSupportDirectory 
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
    return [basePath stringByAppendingPathComponent:@"HyperTableBrowser"];
}

- (void) showErrorDialog:(int)errorCode
			 message:(NSString *)description 
{
	NSMutableDictionary * dict = [NSMutableDictionary dictionary];
	[dict setValue:description forKey:NSLocalizedDescriptionKey];
	NSError * error = [NSError errorWithDomain:@"HyperTableBrowser" code:errorCode userInfo:dict];
	[[NSApplication sharedApplication] presentError:error];
}

- (id) getSettingsByName:(NSString *)name
{
	NSFetchRequest * request = [[NSFetchRequest alloc] init];
	
	NSEntityDescription * entity = [NSEntityDescription entityForName:name
											   inManagedObjectContext:[self managedObjectContext] ];
	
	[request setEntity:entity];
	[request setIncludesPendingChanges:YES];
	NSError * err = nil;
	NSArray * result = [[self managedObjectContext] executeFetchRequest:request error:&err];
	if (err) {
		[[NSApplication sharedApplication] presentError:err];
		[err release];
		return nil;
	}
	[request release];
	
	if ( [result count] <= 0 ) {
		NSLog(@"Creating default preferences for %s", [name UTF8String]);
		
		id defaults = [NSEntityDescription insertNewObjectForEntityForName:name
													inManagedObjectContext:[self managedObjectContext] ];
		return defaults;
	}
	else if ([result count] > 1) {
		return [result objectAtIndex:0];
	}
	[result retain];
	id settings = [result objectAtIndex:0];
	return settings;
}

#pragma mark Application Callbacks

- (IBAction) defineNewCluster:(id)sender
{
	//show dialog
	[NSApp beginSheet:[[self clustersBrowser] newClusterPanel] 
	   modalForWindow:[self clustersBrowserWindow]
        modalDelegate:self didEndSelector:nil contextInfo:nil];
}
- (IBAction)showTablesBrowser:(id)sender
{
	[[self tablesBrowser] updateBrokers:sender withCompletionBlock:^{
		[[self tablesBrowser] refreshTables:nil];
	}];
	[[[NSApp delegate] tablesBrowserWindow] orderFront:sender];
}

- (IBAction)showHqlInterpreter:(id)sender
{
	[[self hqlController] updateBrokers:sender];
	[[self hqlWindow] orderFront:sender];
}

- (IBAction) showClustersBrowser:(id)sender
{
	[[self clustersBrowser] refresh:sender];
	[[self clustersBrowserWindow] orderFront:sender];
}
 
- (IBAction) saveAction:(id)sender {

    NSError *error = nil;
    NSLog(@"Saving state.");
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%s unable to commit editing before saving", [self class], _cmd);
    }

    if (![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
	NSLog(@"Updating memebers.");
	[[[self clustersBrowser] membersTable] reloadData];
}
 
- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {

    if (![self managedObjectContext]) return NSTerminateNow;

    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%s unable to commit editing to terminate", [self class], _cmd);
        return NSTerminateCancel;
    }

    if (![[self managedObjectContext] hasChanges]) return NSTerminateNow;

    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) {
    
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

#pragma mark CoreData Access API

- (NSManagedObjectModel *)managedObjectModel {
	
    if (managedObjectModel) return managedObjectModel;
	
    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
    return managedObjectModel;
}

- (NSPersistentStoreCoordinator *) persistentStoreCoordinator {
	
    if (persistentStoreCoordinator) return persistentStoreCoordinator;
	
    NSManagedObjectModel *mom = [self managedObjectModel];
    if (!mom) {
        NSAssert(NO, @"Managed object model is nil");
        NSLog(@"%@:%s No model to generate a store from", [self class], _cmd);
        return nil;
    }
	
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *applicationSupportDirectory = [[NSApp delegate] applicationSupportDirectory];
    NSError *error = nil;
    
    if ( ![fileManager fileExistsAtPath:applicationSupportDirectory isDirectory:NULL] ) {
		if (![fileManager createDirectoryAtPath:applicationSupportDirectory withIntermediateDirectories:NO attributes:nil error:&error]) {
            NSAssert(NO, ([NSString stringWithFormat:@"Failed to create App Support directory %@ : %@", applicationSupportDirectory,error]));
            NSLog(@"Error creating application support directory at %@ : %@", applicationSupportDirectory,error);
            return nil;
		}
    }
    
    NSURL *url = [NSURL fileURLWithPath: [ [[NSApp delegate] applicationSupportDirectory] 
										  stringByAppendingPathComponent:@"DataBase.xml"]];
	
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: mom];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSXMLStoreType 
												  configuration:nil 
															URL:url 
														options:nil 
														  error:&error]){
		[self recreateDataFiles];
		persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: mom];
		if (![persistentStoreCoordinator addPersistentStoreWithType:NSXMLStoreType 
													  configuration:nil 
																URL:url 
															options:nil 
															  error:&error])
		{
			[persistentStoreCoordinator release], persistentStoreCoordinator = nil;
			[NSApp presentError:error];
			[NSApp terminate:nil];
		}
    }    
	
    return persistentStoreCoordinator;
}

- (BOOL) recreateDataFiles
{
	NSString * message = [NSString stringWithFormat:@"Failed to initialized application data from files at \"%@\".",
						  [[NSApp delegate] applicationSupportDirectory]];
	NSString * info = NSLocalizedString(@"You need to recreate new data files. You can cancel recreation and try to upgrade files manually.",
										@"You need to recreate new data files.");
	NSString * recreateButton = NSLocalizedString(@"Recreate", @"Recreate button title");
	NSString * quitButton = NSLocalizedString(@"Quit", @"Cancel recreate button title");
	NSAlert * alert = [[NSAlert alloc] init];
	[alert setMessageText:message];
	[alert setInformativeText:info];
	[alert addButtonWithTitle:recreateButton];
	[alert addButtonWithTitle:quitButton];
	
	NSInteger answer = [alert runModal];
	[alert release];
	alert = nil;
	if (answer == NSAlertAlternateReturn) {
		NSLog(@"Recreation of data files canceled. Quiting...");
		[NSApp terminate:nil];
	}
	
	NSLog(@"Recreating data files.");
	NSFileManager * fm = [NSFileManager defaultManager];
	NSError * err;
	BOOL rc = [fm removeItemAtPath:[[self applicationSupportDirectory] stringByAppendingPathComponent:@"DataBase.xml"]
							 error:&err];
	if (!rc) {
		NSLog(@"Failed to remove DataBase.xml");
		[NSApp presentError:err];
		[err release];
	}
	else {
		NSLog(@"Data files were cleaup up.");	
	}
	
	return rc;
}

- (NSManagedObjectContext *) managedObjectContext {
	
    if (managedObjectContext) return managedObjectContext;
	
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
		return nil;
    }
    managedObjectContext = [[NSManagedObjectContext alloc] init];
    [managedObjectContext setPersistentStoreCoordinator: coordinator];
	
    return managedObjectContext;
}

@end
