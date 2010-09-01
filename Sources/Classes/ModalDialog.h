//
//  ModalDialog.h
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 27/8/2010.
//  Copyright 2010 Stanislav Yudin. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ModalDialog : NSViewController {
}
- (void) showModalForWindow:(NSWindow *)window;
- (void) hideModalForWindow:(NSWindow *)window;

@end
