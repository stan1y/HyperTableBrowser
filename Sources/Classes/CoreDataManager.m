//
//  CoreDataManager.m
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 9/8/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import "CoreDataManager.h"


@implementation CoreDataManager

@synthesize dataFileName;

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
										  stringByAppendingPathComponent:[self dataFileName]]];
	
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
	BOOL rc = [fm removeItemAtPath:[[self applicationSupportDirectory] stringByAppendingPathComponent:@"Clusters.xml"]
							 error:&err];
	if (!rc) {
		NSLog(@"Failed to remove Clusters.xml");
		[NSApp presentError:err];
		[err release];
	}
	
	rc = [fm removeItemAtPath:[[self applicationSupportDirectory] stringByAppendingPathComponent:@"Settings.xml"]
						error:&err];
	if (!rc) {
		NSLog(@"Failed to remove Settings.xml");
		[NSApp presentError:err];
		[err release];
	}
	
	NSLog(@"Data files were cleaup up.");	
	
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

- (void) dealloc
{
	[dataFileName release];
    [managedObjectContext release];
    [persistentStoreCoordinator release];
    [managedObjectModel release];
	[super dealloc];
}


@end
