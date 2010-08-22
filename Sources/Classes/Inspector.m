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

- (void) dealloc
{
	[objectTitle release];
	[hostname release];
	[healthPercentage release];
	[healthBar release];
	[comments release];
	
	[super dealloc];
}

- (id) init
{
	if (self = [super init]) {
		runningImage = [[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ServiceStatusRunning" ofType:@"png"]];
		stoppedImage = [[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ServiceStatusStopped" ofType:@"png"]];
	}
	
	return self;
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
	id selectedServer = [[[NSApp delegate] clustersBrowser] selectedServer];
	if (selectedServer) {
		NSLog(@"Inspector: \"%@\" is selected.", [selectedServer valueForKey:@"name"]);
		
		[objectTitle setStringValue:[selectedServer valueForKey:@"name"]];
		[hostname setStringValue:[selectedServer valueForKey:@"ipAddress"]];
		int health = [[selectedServer valueForKey:@"healthPercent"] intValue];
		[healthBar setIntValue:health];
		[healthPercentage setStringValue:[NSString stringWithFormat:@"%d %%", health]];
		[comments setStringValue:[selectedServer valueForKey:@"comment"]];
	}
	else {
		NSLog(@"Inspector: Nothing selected.");
	}

}

- (void)observeValueForKeyPath:(NSString *)keyPath 
					  ofObject:(id)object 
						change:(NSDictionary *)change 
					   context:(void *)context
{
	
	
	NSLog(@"Inspector: Observed selection.");
	[self refresh:object];
}

// --- Service listing

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
	NSManagedObject * selected = [[[NSApp delegate] clustersBrowser] selectedServer];
	if (selected) {
		int servicesCount = [[[[NSApp delegate] clusterManager] servicesOnServer:selected] count];
		return servicesCount;
	}
	
	return 0;
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn 
			row:(NSInteger)rowIndex
{
	
	NSManagedObject * selectedServer = [[[NSApp delegate] clustersBrowser] selectedServer];
	if (selectedServer) {
		NSArray * services = [[[NSApp delegate] clusterManager] servicesOnServer:selectedServer];
		
		if (!services) {
			return [NSArray arrayWithObjects:@"Not Available", nil];
		}
		
		id cellValue = nil;
		if ([[aTableColumn identifier] isEqual:@"name"]) {
			NSString * serviceName = [[services objectAtIndex:rowIndex] valueForKey:@"serviceName"];
			cellValue = serviceName;
		}
		else if ( [[aTableColumn identifier] isEqual:@"control"] ) {
			int processID = [[[services objectAtIndex:rowIndex] valueForKey:@"processID"] intValue];
			if (processID) {
				cellValue = [NSArray arrayWithObjects:@"Running", @"Initiate Stop...", nil];
			}
			else {
				cellValue = [NSArray arrayWithObjects:@"Stopped", @"Initiate Start...", nil];
			}
		}

		return cellValue;
	}
	
	return nil;
}

// Sevices selection
- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
	selectedServiceIndex = [[aNotification object] selectedRow];
	NSLog(@"Inspector: selected service at index %d", selectedServiceIndex);
}

@end
