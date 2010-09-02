//
//  NewServerController.h
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 10/8/2010.
//  Copyright 2010 Stanislav Yudin. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ModalDialog.h"

@interface NewServerController : ModalDialog {
	//UI properties
	NSTextField * dialogTitle;
	NSTextField * errorMessage;
	
	//Server properties
	NSPopUpButton * typeSelector;
	NSTextField * name;
	NSTextField * ipAddress;
	NSTextField * sshPort;
	NSTextField * userName;
	NSTextField * privateKeyPath;
	
	BOOL createNewCluster;
}
@property (nonatomic, retain) IBOutlet NSPopUpButton * typeSelector;
@property (nonatomic, retain) IBOutlet NSTextField * errorMessage;
@property (nonatomic, retain) IBOutlet NSTextField * dialogTitle;

@property (nonatomic, retain) IBOutlet NSTextField * name;
@property (nonatomic, retain) IBOutlet NSTextField * ipAddress;
@property (nonatomic, retain) IBOutlet NSTextField * sshPort;
@property (nonatomic, retain) IBOutlet NSTextField * userName;
@property (nonatomic, retain) IBOutlet NSTextField * privateKeyPath;

- (IBAction) saveServer:(id)sender;
- (IBAction) cancel:(id)sender;
- (void) setCreateNewCluster:(BOOL)flag;
- (NSString *) generateUniqueID;

@end
