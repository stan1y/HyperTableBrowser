//
//  PageSource.h
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 12/16/09.
//  Copyright 2009 Stanislav Yudin. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <SetRowOperation.h>
#import <HyperTable.h>

@interface PageSource : NSObject {
	DataPage * page;
	NSString * pageTitle;
};

@property (assign) DataPage * page;
@property (nonatomic, retain) NSString * pageTitle;

- (void)reloadDataForView:(NSTableView*)tableView;
- (void)setPage:(DataPage*)page withTitle:(NSString*)title;
@end
