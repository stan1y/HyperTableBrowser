//
//  HqlController.h
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 12/16/09.
//  Copyright 2009 AwesomeStanly Lab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Utility.h"
#import "PageSource.h"

@interface HqlController : HyperTableBrokersCntrl {
	NSTextView * hqlQuery;
	NSButton * goButton;
	
	//activity indication
	NSProgressIndicator * indicator;
	NSTextField * queryStatus;
	
	//HQL page display
	PageSource * pageSource;
	NSTableView * pageView;
	
	//Scripts selector
	NSPopUpButton * scriptSelector;
	NSString * loadedScriptFilePath;
	BOOL scriptModified;
}

@property (nonatomic, retain) IBOutlet NSPopUpButton * scriptSelector;
@property (nonatomic, retain) IBOutlet NSProgressIndicator * indicator;
@property (nonatomic, retain) IBOutlet NSTextField * queryStatus;
@property (nonatomic, retain) IBOutlet NSTextView * hqlQuery;
@property (nonatomic, retain) IBOutlet NSButton * goButton;
@property (nonatomic, retain) IBOutlet PageSource * pageSource;
@property (nonatomic, retain) IBOutlet NSTableView * pageView;

//UI callbacks
- (IBAction) runQuery:(id)sender;
- (IBAction) updateScripts:(id)sender;

//script execution
- (void) runQuery:(NSString *)query onServer:(id)server;

//script storage
- (NSString *) currentScriptFileName;
- (BOOL) isScriptSaved;

@end
