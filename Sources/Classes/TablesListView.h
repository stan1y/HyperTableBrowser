//
//  TablesListView.h
//  Ore Foundry
//
//  Created by Stanislav Yudin on 9/8/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TableItem : NSObject
{
	NSRect itemRect;
}

@property (assign) NSRect itemRect;
@property (nonatomic, retain) NSString * tableName;

+ (TableItem *) itemWithName:(NSString *)name;

@end


@interface TablesListView : NSView {
	NSString * selectedTable;
	NSMutableArray * tables;
	int selectedTableIndex;
}

@property (nonatomic, retain) NSMutableArray * tables;
@property (nonatomic, retain) NSString * selectedTable;
@property (assign) int selectedTableIndex;

- (BOOL)acceptsFirstResponder;

- (id)initWithFrame:(NSRect)frame;

- (void)drawRect:(NSRect)theRect;
- (void)drawTables:(CGContextRef)context;
- (void)buildTablesIn:(NSRect)theRect;

- (void)mouseDown:(NSEvent*)theEvent;
- (void)mouseDragged:(NSEvent*)theEvent;
- (void)mouseUp:(NSEvent*)theEvent;
- (void)mouseMoved:(NSEvent*)theEvent;
- (void)mouseEntered:(NSEvent*)theEvent;
- (void)mouseExited:(NSEvent*)theEvent;

- (void)keyDown:(NSEvent*)theEvent;
- (void)keyUp:(NSEvent*)theEvent;

@end
