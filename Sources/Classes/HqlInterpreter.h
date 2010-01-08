//
//  HqlInterpreter.h
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 12/16/09.
//  Copyright 2009 AwesomeStanly Lab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <HqlController.h>

@interface HqlInterpreter : NSObject {	
	HqlController * controller;
}

@property(assign) IBOutlet HqlController * controller;

@end
