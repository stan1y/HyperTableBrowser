//
//  Inspector.h
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 21/8/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface Inspector : NSWindowController {
	NSTextField * objectTitle;
	NSTextField * healthPercentage;
	NSTextField * hostname;
	NSLevelIndicator * healthBar; 
	NSTextField * comments;
	
	NSPopUpButton * dfsControl;
	NSPopUpButton * spaceControl;
	NSPopUpButton * hmasterControl;
	NSPopUpButton * hrangeControl;
	NSPopUpButton * thriftControl;
}

@property (nonatomic, retain) IBOutlet NSTextField * objectTitle;
@property (nonatomic, retain) IBOutlet NSTextField * healthPercentage;
@property (nonatomic, retain) IBOutlet NSLevelIndicator * healthBar;
@property (nonatomic, retain) IBOutlet NSTextField * hostname;
@property (nonatomic, retain) IBOutlet NSTextField * comments;

@property (nonatomic, retain) IBOutlet NSPopUpButton * dfsControl;
@property (nonatomic, retain) IBOutlet NSPopUpButton * spaceControl;
@property (nonatomic, retain) IBOutlet NSPopUpButton * hmasterControl;
@property (nonatomic, retain) IBOutlet NSPopUpButton * hrangeControl;
@property (nonatomic, retain) IBOutlet NSPopUpButton * thriftControl;

- (IBAction) operateService:(id)sender;
- (IBAction) closeInspector:(id)sender;
- (IBAction) refresh:(id)sender;

- (void)observeValueForKeyPath:(NSString *)keyPath 
					  ofObject:(id)object 
						change:(NSDictionary *)change 
					   context:(void *)context;

@end
