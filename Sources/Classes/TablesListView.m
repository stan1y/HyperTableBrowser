//
//  TablesListView.m
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 9/8/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import "TablesListView.h"


@implementation TableItem

@synthesize itemRect;
@synthesize tableName;

+ (TableItem *) itemWithName:(NSString *)name
{
	TableItem * item = [[TableItem alloc] init];
	[item setTableName:name];
}

@end

//
// --------------- Tables List Custom NSView ----------------
//

@implementation TablesListView

@synthesize selectedTable;
@synthesize selectedTableIndex;
@synthesize tables;

- (BOOL)acceptsFirstResponder
{
	return YES;
}

- (void)awakeFromNib
{
	tables = [[NSMutableArray alloc] init];
	[self setSelectedTable:nil];
}

- (void) dealloc
{
	[tables release];
	if (selectedTable) {
		[selectedTable release];
	}
}

- (void)drawRect:(NSRect)theRect
{
	NSLog(@"draw!");
	CGContextRef aCGContextRef = [[NSGraphicsContext currentContext] graphicsPort];
	
	// draw the background
	CGContextSetRGBFillColor(aCGContextRef, 0.8, 0.8, 0.8, 1.0);
	CGRect aCGBackgroundRect = *((CGRect*)&theRect);
	CGContextFillRect(aCGContextRef, aCGBackgroundRect);
	
	//build tables rects
	[self buildTablesIn:theRect];
	[self drawTables:aCGContextRef];
}

- (void)drawTables:(CGContextRef)context
{
	CGContextSetRGBFillColor(context, 0.6, 0.6, 0.6, 1.0);
	for(id table in [self tables]) {
		CGContextFillRect(context, [table itemRect]);
	}
}

- (void)buildTablesIn:(NSRect)theRect
{
	id connection = [[[NSApp delegate] tablesBrowser] getSelectedConnection];
	if (connection) {
		[[self tables] removeAllObjects];
		int tablesCount = [[connection tables] count];
		for (int i=0; i<tablesCount; i++) {
			NSRect tableRect = NSMakeRect(5, 5 + (5 * i), 
										  theRect.size.width - 10, 20);
			TableItem * table = [TableItem itemWithName:[[connection tables] objectAtIndex:i]];
			[table setItemRect:tableRect];
			[tables addObject:table];
		}
		[connection release];
	}
}

- (void)drawTable:(NSString *)name 
		toContext:(CGContextRef)context
		 withRect:(NSRect)tableRect
{
	
}

- (void)mouseDown:(NSEvent*)theEvent
{
	NSPoint clickedTo = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	//check which table was clicked
	id connection = [[[NSApp delegate] tablesBrowser] getSelectedConnection];
	if (connection) {
		int tablesCount = [[connection tables] count];
		for (int i=0; i < tablesCount; i++) {
			TableItem * table = [[self tables] objectAtIndex:i];
			if (NSPointInRect(clickedTo, [table itemRect])) {
				NSLog(@"Clicked on table %s", [[[connection tables] objectAtIndex:i] UTF8String]);
			}
			[table release];
		}
		[connection release];
	}
}

@end
