//
//  ClustersBrowser.m
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 9/8/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import "ClustersBrowser.h"

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
	NSLog(@"Initializing preferences controller\n");
	//prepare preferences window
	GeneralPreferencesController * general = [[GeneralPreferencesController alloc] initWithNibName:@"PreferencesGeneral" bundle:nil];
	[[MBPreferencesController sharedController] setModules:[NSArray arrayWithObjects:general, nil]];
	[general release];
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

@end
