//
//  Inspector.m
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 21/8/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import "Inspector.h"


@implementation Inspector

@synthesize objectTitle;
@synthesize hostname;
@synthesize healthPercentage;
@synthesize healthBar;
@synthesize comments;

@synthesize dfsControl;
@synthesize hmasterControl;
@synthesize hrangeControl;
@synthesize spaceControl;
@synthesize thriftControl;

- (void) dealloc
{
	[dfsControl release];
	[hmasterControl release];
	[hrangeControl release];
	[spaceControl release];
	[thriftControl release];
	
	[objectTitle release];
	[hostname release];
	[healthPercentage release];
	[healthBar release];
	[comments release];
	
	[super dealloc];
}

- (IBAction) operateService:(id)sender
{
	NSLog(@"Operating tag: %d.", [[sender tag] intValue]);
	switch ([[sender tag] intValue]) {
		case 0:
			NSLog(@"DFS Broker Service");
			break;
		case 1:
			NSLog(@"Hyperspace Service");
			break;
		case 2:
			NSLog(@"RangeServer Service");
			break;
		case 3:
			NSLog(@"Master Service");
			break;
		case 4:
			NSLog(@"Thrift API Broker Service.");
			break;
		default:
			NSLog(@"Unknown service tag.");
			break;
	}
}

- (IBAction) closeInspector:(id)sender
{
	[[self window] orderOut:sender];
}


- (IBAction) refresh:(id)sender;
{
	[dfsControl setEnabled:NO];
	[spaceControl setEnabled:NO];
	[hmasterControl setEnabled:NO];
	[hrangeControl setEnabled:NO];
	[thriftControl setEnabled:NO];
	
	id selectedMember = [[[NSApp delegate] clusterManager] selectedMember];
	if (selectedMember) {
		[selectedMember retain];
		NSLog(@"Inspector: Member %@ is selected.", [selectedMember valueForKey:@"name"]);
		
		[objectTitle setStringValue:[selectedMember valueForKey:@"name"]];
		[hostname setStringValue:[selectedMember valueForKey:@"ipAddress"]];
		int health = [[selectedMember valueForKey:@"healthPercent"] intValue];
		[healthPercentage setStringValue:[NSString stringWithFormat:@"%d %%", health]];
		[comments setStringValue:[selectedMember valueForKey:@"comment"]];
		
		if ([[selectedMember valueForKey:@"hasDfsBroker"] intValue]) {
			[dfsControl setEnabled:YES];
		}
		if ([[selectedMember valueForKey:@"hasHyperspace"] intValue]) {
			[spaceControl setEnabled:YES];
		}
		if ([[selectedMember valueForKey:@"hasRangeServer"] intValue]) {
			[hrangeControl setEnabled:YES];
		}
		if ([[selectedMember valueForKey:@"hasMaster"] intValue]) {
			[hmasterControl setEnabled:YES];
		}
		if ([[selectedMember valueForKey:@"hasThriftBroker"] intValue]) {
			[thriftControl setEnabled:YES];
		}
		[selectedMember release];
	}
	else {
		NSLog(@"Inspector: No object selected.");
	}

}

- (void)observeValueForKeyPath:(NSString *)keyPath 
					  ofObject:(id)object 
						change:(NSDictionary *)change 
					   context:(void *)context
{
	
	
	NSLog(@"Inspector observed selection.");
	[self refresh:object];
}

@end
