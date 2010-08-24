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

@synthesize membersTable;
@synthesize clustersSelector;

@synthesize selectedClusterIndex;
@synthesize selectedServerIndex;

#pragma mark Initialization

- (void)awakeFromNib
{
	NSLog(@"Initializing Clusters Browser.");	
	selectedServerIndex = 0;
	selectedClusterIndex = 0;
	[[NSApp delegate] saveAction:self];
}

- (void) dealloc
{
	[statusMessageField release];
	[statusIndicator release];
	[newClusterMenuItem release];
	[newClusterPanel release];
	
	[membersTable release];
	
	[super dealloc];
}

#pragma mark Selections

- (Cluster *) selectedCluster
{
	return [[Cluster clusters] objectAtIndex:selectedClusterIndex];
}

- (Server *) selectedServer
{
	Cluster * cl = [self selectedCluster];
	if (cl) {
		if ([[cl servers] count] > selectedServerIndex) {
			return [[[cl servers] allObjects] objectAtIndex:selectedServerIndex];
		}
	}
	return nil;
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
	selectedServerIndex = [[aNotification object] selectedRow];
	if ([[[self selectedCluster] servers] count] > selectedServerIndex) {
		selectedServer = [[[[self selectedCluster] servers] allObjects] objectAtIndex:selectedServerIndex];
		NSLog(@"Selected server: %@", selectedServer);
		[[[NSApp delegate] inspector] refresh:nil];
	}
}

#pragma mark Clusters Window Callbacks

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

#pragma mark UI Activity API

- (void)setMessage:(NSString*)message 
{
	NSLog(@"Clusters Browser: %s\n", [message UTF8String]);
	[statusMessageField setTitleWithMnemonic:message];
}

- (void)indicateBusy 
{
	[statusIndicator startAnimation:self];
}

- (void)indicateDone 
{
	[statusIndicator stopAnimation:self];
}

#pragma mark Toolbar callbacks

- (IBAction)showNewClusterDialog:(id)sender;
{
	[NSApp beginSheet:[self newClusterPanel] 
	   modalForWindow:[self window]
        modalDelegate:self didEndSelector:nil contextInfo:nil];
}

- (IBAction) refresh:(id)sender
{
	id cl = [self selectedCluster];
	if ( cl ){
		[self indicateBusy];
		[self setMessage:@"Updating cluster members..."];
		
		//update cluster members
		for (Server * server in [cl servers]) {
			GetStatusOperation * op = [GetStatusOperation getStatusOfServer:server];
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
				[self setMessage:@"Updated successfuly."];
			}];
			
			[[[NSApp delegate] operations] addOperation:op];
			[op release];
		}
	}
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

- (IBAction)showInspector:(id)sender
{
	[[[NSApp delegate] inspector] refresh:sender];
	[[[NSApp delegate] inspectorPanel] orderFront:sender];
}

@end
