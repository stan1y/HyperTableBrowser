//
//  Inspector.m
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 21/8/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import "Inspector.h"
#import <Server.h>

@implementation Inspector

@synthesize objectTitle;
@synthesize hostname;
@synthesize healthPercentage;
@synthesize healthBar;
@synthesize comments;

#pragma mark Initialization

- (void) dealloc
{
	[objectTitle release];
	[hostname release];
	[healthPercentage release];
	[healthBar release];
	[comments release];
	
	[serviceRunningValues release];
	[serviceStoppedValues release];
	
	[super dealloc];
}

- (id) init
{
	if (self = [super init]) {
		serviceRunningValues = [NSArray arrayWithObjects:@"Service running.", @"Stop the service.", nil];
		serviceStoppedValues = [NSArray arrayWithObjects:@"Service stopped.", @"Start the service.", nil];
	}
	
	return self;
}

#pragma mark Operations

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
		
		[objectTitle setStringValue:@"Nothing selected"];
		[hostname setStringValue:@"--"];
		[healthBar setIntValue:0];
		[healthPercentage setStringValue:@"-- %%"];
		[comments setStringValue:@""];
	}
}

#pragma mark Services Tables Delegate

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
	Server * selected = [[[NSApp delegate] clustersBrowser] selectedServer];
	if (selected) {
		return [[selected services] count];
	}
	
	return 0;
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn 
			row:(NSInteger)rowIndex
{
	
	Server * selectedServer = [[[NSApp delegate] clustersBrowser] selectedServer];
	if (selectedServer) {
		NSArray * services = [selectedServer services];
		
		if (!services) {
			return @"Not Available";
		}
		
		if ([[aTableColumn identifier] isEqual:@"name"]) {
			return [[services objectAtIndex:rowIndex] valueForKey:@"serviceName"];
		}
	}
	
	return nil;
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
	selectedServiceIndex = [[aNotification object] selectedRow];
	NSLog(@"Inspector: selected service at index %d", selectedServiceIndex);
}

- (void) tableView:(NSTableView*)tableView willDisplayCell:(id)cell 
  forTableColumn:(NSTableColumn*)tableColumn 
			 row:(int)index
{
	if([[tableColumn identifier] isEqual:@"control"] && [cell isKindOfClass:[NSComboBoxCell class]])
	{
		Server * selectedServer = [[[NSApp delegate] clustersBrowser] selectedServer];
		if (selectedServer) {
			NSArray * services = [selectedServer services];
			[cell setRepresentedObject:[services objectAtIndex:index]];
			[cell reloadData];
			[cell selectItemAtIndex:0];
		}
	}
}

- (void) tableView:(NSTableView*)tableView 
	setObjectValue:(id)value 
	forTableColumn:(NSTableColumn*)tableColumn 
			   row:(int)index
{
	if([[tableColumn identifier] isEqual:@"control"]) {
		Server * selectedServer = [[[NSApp delegate] clustersBrowser] selectedServer];
		if (selectedServer) {
			Service * selectedService = [[selectedServer services] objectAtIndex:index];
			NSLog(@"Inspector: Service \"%@\" received command: \"%@\"",
				  [selectedService valueForKey:@"serviceName"],
				  value);
		}
	}
}

#pragma mark Service Control ComboBox Delegate

-(id)comboBoxCell:(NSComboBoxCell*)cell objectValueForItemAtIndex:(int)index
{
	Service * srv = [cell representedObject];
	if(srv == nil)
		return @"Error";
	else {
		if ([[srv valueForKey:@"processID"] intValue] > 0) {
			return [serviceRunningValues objectAtIndex:index];
		}
		else {
			return [serviceStoppedValues objectAtIndex:index];
		}
	}
}

-(int)numberOfItemsInComboBoxCell:(NSComboBoxCell*)cell
{
	Service * srv = [cell representedObject];
	if(srv == nil)
		return 0;
	else
		return 2; // two positions in combo
}

@end
