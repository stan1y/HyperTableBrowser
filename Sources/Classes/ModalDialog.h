//
//  ModalDialog.h
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 27/8/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ModalDialog : NSViewController {
	NSWindow * modalFor;
}

@property (nonatomic, retain) NSWindow * modalFor;

- (void) showModalForWindow:(NSWindow *)window;
- (void) hideModalForWindow:(NSWindow *)window;

- (IBAction) hideModalForUsedWindow:(id)sender;

@end
