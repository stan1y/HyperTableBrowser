//
//  ModalDialog.m
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 27/8/2010.
//  Copyright 2010 Stanislav Yudin. All rights reserved.
//

#import "ModalDialog.h"


@implementation ModalDialog

- (void) showModalForWindow:(NSWindow *)window
{
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


@end
