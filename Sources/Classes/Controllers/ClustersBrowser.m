//
//  ClustersBrowser.m
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 9/8/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import "ClustersBrowser.h"
#import "GetStatusOperation.h"
#import "SSHClient.h"

@implementation ClustersBrowser

@synthesize statusMessageField;
@synthesize statusIndicator;

@synthesize newClusterMenuItem;
@synthesize newClusterPanel;

- (void) dealloc
{
	[statusMessageField release];
	[statusIndicator release];
	[newClusterMenuItem release];
	[newClusterPanel release];
	[super dealloc];
}

- (void)awakeFromNib
{
	NSLog(@"Initializing preferences.");
	// try to fetch each settings resulting in defaults creation if none
	id dummy = [[[NSApp delegate] settingsManager] getSettingsByName:@"TablesBrowserPrefs"];
	[dummy release];
	dummy = [[[NSApp delegate] settingsManager] getSettingsByName:@"ClustersBrowserPrefs"];
	[dummy release];
	dummy = [[[NSApp delegate] settingsManager] getSettingsByName:@"UpdatesPrefs"];
	[dummy release];
	[[NSApp delegate] saveAction:self];
}

- (IBAction) refresh:(id)sender
{
	id selectedCluster = [[[NSApp delegate] clusterManager] selectedCluster];
	if ( selectedCluster ){
		[self indicateBusy];
		[self setMessage:@"Updating cluster members..."];
		
		//update cluster members
		id members = [[[NSApp delegate] clusterManager] serversInCluster:selectedCluster];
		for (NSManagedObject * server in members) {
			SSHClient * client = [[[NSApp delegate] clusterManager] remoteShellOnServer:server];
			GetStatusOperation * op = [GetStatusOperation getStatusFrom:client
															  forServer:server];
			[op setCompletionBlock: ^ {
				[self indicateDone];
				if ([op errorCode]) {
					[self setMessage:@"Operation failed."];
					NSMutableDictionary *dict = [NSMutableDictionary dictionary];
					[dict setValue:[op errorMessage] forKey:NSLocalizedDescriptionKey];
					[dict setValue:[op errorMessage] forKey:NSLocalizedFailureReasonErrorKey];
					NSError *error = [NSError errorWithDomain:@"" code:[op errorCode] userInfo:dict];
					[NSApp presentError:error];			
				}
			}];
			[[[NSApp delegate] operations] addOperation:op];
			[op release];
			[client release];
		}
		[selectedCluster release];
	}
}

- (void)showNewClusterDialog:(id)sender
{
	[NSApp beginSheet:[self newClusterPanel] 
	   modalForWindow:[self window]
        modalDelegate:self didEndSelector:nil contextInfo:nil];
}

- (void)setMessage:(NSString*)message 
{
	NSLog(@"Clusters Browser: %s\n", [message UTF8String]);
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

- (BOOL)windowShouldClose:(id)sender
{
	NSLog(@"Checking running threads...\n");
	
    NSInteger numOperationsRunning = [[[[NSApp delegate] operations] operations] count];
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
	
    return numOperationsRunning == 0;
}

- (void)windowWillClose:(NSNotification *)notification
{
	NSLog(@"Clusters browser closed\n");
	[[NSApp delegate] saveAction:self];
}

- (IBAction)showPreferences:(id)sender
{	
	NSLog(@"Initializing preferences controllers.");
	//prepare preferences windows
	TablesBrowserSettings * tables = [[TablesBrowserSettings alloc] initWithNibName:@"TablesBrowserPreferences" 
																			 bundle:nil];
	ClustersBrowserSettings * clusters = [[ClustersBrowserSettings alloc] initWithNibName:@"ClustersBrowserPreferences" 
																				   bundle:nil];
	UpdateSettings * updates = [[UpdateSettings alloc] initWithNibName:@"UpdatesPreferences" 
																bundle:nil];
	
	
	[[MBPreferencesController sharedController] setModules:[NSArray arrayWithObjects:tables,
															clusters,
															updates,
															nil]];
	[tables release];
	[clusters release];
	[updates release];
	
	[[MBPreferencesController sharedController] showWindow:sender];
}

- (IBAction)showTablesBrowser:(id)sender
{
	[[[NSApp delegate] tablesBrowser] updateConnections:sender];
	[[[NSApp delegate] tablesBrowser] refreshTables:sender];
	[[[NSApp delegate] tablesBrowserWindow] orderFront:sender];
}

- (IBAction)showHqlInterpreter:(id)sender
{
	[[[NSApp delegate] hqlController] updateConnections:sender];
	[[[NSApp delegate] hqlWindow] orderFront:sender];
}

@end
