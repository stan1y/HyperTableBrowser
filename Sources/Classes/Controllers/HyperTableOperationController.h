//
//  HyperTableOperationController.h
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 4/8/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <HyperTable.h>

@interface HyperTableOperationController : NSWindowController {
	NSProgressIndicator * indicator;
	NSTextField * statusField;
	NSPopUpButton * serverSelector;
}

@property (nonatomic, retain) IBOutlet NSPopUpButton * serverSelector;
@property (nonatomic, retain) IBOutlet NSProgressIndicator * indicator;
@property (nonatomic, retain) IBOutlet NSTextField * statusField;

//set available connections
- (IBAction)updateConnections:(id)sender;
//get connection selected by user in drop down 
- (id)getSelectedConnection;
//display message on panel
- (void)setMessage:(NSString *)message;
//start indicator animation
- (void)indicateBusy;
//stop indicator animation
- (void)indicateDone;
@end
