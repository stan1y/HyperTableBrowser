//
//  Activities.m
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 28/8/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import "Activities.h"


@implementation Activities

@synthesize activitiesTable;
@synthesize operations;
@synthesize operationsQueue;

- (void) awakeFromNib
{
	operations = [[NSMutableArray alloc] init];
	operationsQueue = [[NSOperationQueue alloc] init];
	
	//register for main operations queue updates
	//when operation completed, this queue is updated
	[operationsQueue addObserver:self forKeyPath:@"operations" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:NULL];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
	//main operations queue was updated
	if (object == operationsQueue) {
		
		for (int i=0; i<[[self operations] count]; i++) {
			NSMutableDictionary * opDict = [[self operations] objectAtIndex:i];
			if ([[opDict valueForKey:@"running"] intValue]) {
				
				//make sure it is still running
				if ([[opDict valueForKey:@"operation"] isFinished]) {
					
					NSLog(@"Operation '%@' appeared finshed", [opDict valueForKey:@"title"]);
					//it was finished, so update status and remove from dict
					[opDict setObject:[NSNumber numberWithBool:NO] forKey:@"running"];
					[opDict removeObjectForKey:@"operation"];
					
					//if operation is at 5 indexes long and finished, remove it from list
					if (i >= 4) {
						[[self operations] removeObjectAtIndex:i];
						i--;
					}
				}
			}
		}
	}
	[activitiesTable reloadData];
}

- (void) dealloc
{
	[activitiesTable release];
	[operations release];
	[operationsQueue release];
	
	[super dealloc];
}

//	Activities list data source implementation

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
	return [[self operations] count];
	
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn 
			row:(NSInteger)rowIndex
{
	NSMutableDictionary * opDict = [[self operations] objectAtIndex:rowIndex];
	return [opDict valueForKey:[aTableColumn identifier]];
	
}

- (void) tableView:(NSTableView*)tableView willDisplayCell:(id)cell 
	forTableColumn:(NSTableColumn*)tableColumn 
			   row:(int)index
{
	if([[tableColumn identifier] isEqual:@"running"]) {
		NSMutableDictionary * opDict = [[self operations] objectAtIndex:index];
		if ([[opDict valueForKey:[tableColumn identifier]] intValue]) {
			[cell setTextColor:[NSColor greenColor]];
			[cell setStringValue:@"Running"];
		}
		else {
			[cell setTextColor:[NSColor whiteColor]];
			[cell setStringValue:@"Finished"];
		}
	}
}

//	Public API

- (IBAction) terminateSelected:(id)sender
{
	//FIXME: Not implemented
}

- (NSDictionary *) selectedActivity
{
	int index = [activitiesTable selectedRow];
	if (index >= 0 ) {
		return [[self operations] objectAtIndex:index];
	}
	return nil;
}

@end