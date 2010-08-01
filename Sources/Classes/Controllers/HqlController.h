//
//  HqlController.h
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 12/16/09.
//  Copyright 2009 AwesomeStanly Lab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#
#import <PageSource.h>
#import <ThriftConnection.h>
#import <HqlQueryOperation.h>

@interface HqlController : NSWindowController {
	NSTextView * hqlQuery;
	NSButton * goButton;
	NSProgressIndicator * indicator;
	NSTextField * statusField;
	
	NSPopUpButton * serverSelector;
	
	//source for hql page
	PageSource * pageSource;
	
	//view used to display source
	NSTableView * pageView;
}

@property (nonatomic, retain) IBOutlet NSTextView * hqlQuery;
@property (nonatomic, retain) IBOutlet NSButton * goButton;
@property (nonatomic, retain) IBOutlet NSPopUpButton * serverSelector;
@property (nonatomic, retain) IBOutlet PageSource * pageSource;
@property (nonatomic, retain) IBOutlet NSTableView * pageView;
@property (nonatomic, retain) IBOutlet NSProgressIndicator * indicator;
@property (nonatomic, retain) IBOutlet NSTextField * statusField;

- (IBAction)go:(id)sender;
- (IBAction)done:(id)sender;

//set available connections
- (IBAction)updateConnections:(id)sender;
//get connection selected by user in drop down 
- (id)getSelectedConnection;
//show status message on the bottom
- (void)setMessage:(NSString*)message;
//start operation indicator
- (void)indicateBusy;
//stop operation indicator
- (void)indicateDone;
//called when hql windows is about to close
- (void)windowWillClose:(NSNotification *)notification;
@end
