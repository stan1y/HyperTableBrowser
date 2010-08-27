//
//  ModalDialog.m
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 27/8/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import "ModalDialog.h"


@implementation ModalDialog

@synthesize modalFor;

- (void) showModalForWindow:(NSWindow *)window
{
	[self setModalFor:window];
	
	[NSApp beginSheet:[[self view] window]
	   modalForWindow:window
		modalDelegate:self didEndSelector:nil contextInfo:nil];
	
}

- (void) hideModalForWindow:(NSWindow *)window
{
	//close dialog
	[NSApp endSheet:window];
	[[[self view] window] orderOut:nil];
}

- (IBAction) hideModalForUsedWindow:(id)sender
{
	if ([self modalFor]) {
		[self hideModalForWindow:[self modalFor]];
	}
	else {
		NSLog(@"Can't hide modal dialog. No window assosiated.");
	}
}

@end
