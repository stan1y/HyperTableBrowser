//
//  Inspector.m
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 21/8/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import "Inspector.h"
#import "Server.h"
#import "HyperTable.h"

@implementation Inspector

@synthesize objectTitle;
@synthesize hostname;
@synthesize healthPercentage;
@synthesize healthBar;
@synthesize comments;
@synthesize remoteShell;
@synthesize servicesTable;
@synthesize dfsProvider;

#pragma mark Initialization

- (void) dealloc
{
	[objectTitle release];
	[hostname release];
	[healthPercentage release];
	[healthBar release];
	[comments release];
	[remoteShell release];
	[servicesTable release];
	[dfsProvider release];
	
	[serviceRunningValues release];
	[serviceStoppedValues release];
	[pendingServicesLock release];
	
	[super dealloc];
}

- (id) init
{
	if (self = [super init]) {
		serviceRunningValues = [[NSArray alloc] initWithObjects:@"Service running.", @"Stop the service.", nil];
		serviceStoppedValues = [[NSArray alloc] initWithObjects:@"Service stopped.", @"Start the service.", nil];
		pendingServiceIndexes = [[NSMutableArray alloc] init];
		pendingServicesLock = [[NSLock alloc] init];
	}
	
	return self;
}

#pragma mark Pending services list

- (void) addServiceToPending:(int)serviceIndex
{
	[pendingServicesLock lock];
	[pendingServiceIndexes addObject:[NSNumber numberWithInt:serviceIndex]];
	[pendingServicesLock unlock];
}

- (void) removeServiceFromPending:(int)serviceIndex
{
	[pendingServicesLock lock];
	[pendingServiceIndexes removeObject:[NSNumber numberWithInt:serviceIndex]];
	[pendingServicesLock unlock];
}

- (BOOL) isCurrentServicePending
{
	[pendingServicesLock lock];
	BOOL b = NO;
	if ([pendingServiceIndexes indexOfObject:[NSNumber numberWithInt:selectedServiceIndex]] != NSNotFound) b = YES;
	[pendingServicesLock unlock];
	return b;
}

#pragma mark Operations

- (IBAction) operateService:(id)sender
{
	Server * selectedServer = [[[NSApp delegate] clustersBrowser] selectedServer];
	if (selectedServer) {
		NSArray * services = [selectedServer services];
		
		if (!services) {
			NSLog(@"Inspector: No services on %@, nothing to operate.", [selectedServer valueForKey:@"name"]);
			return;
		}
		
		int selectedIndex = selectedServiceIndex;
		Service * selectedService = [services objectAtIndex:selectedIndex];

		//set as pending
		[self addServiceToPending:selectedIndex];
		//if running -> stop it, otherwise start it
		if ([[selectedService valueForKey:@"processID"] intValue] > 0) {
			
			[[[NSApp delegate] clustersBrowser] setMessage:@"Stopping service..."];
			[[[NSApp delegate] clustersBrowser] indicateBusy];
			
			NSLog(@"Inspector: stopping service %@", [selectedService valueForKey:@"serviceName"]);
			[selectedService stop: ^{
				
				[[[NSApp delegate] clustersBrowser] indicateDone];
				if (![selectedService isRunning]) {
					[[[NSApp delegate] clustersBrowser] setMessage:@"Service stopped sucessfuly."];
				}
				else {
					[[[NSApp delegate] clustersBrowser] setMessage:@"Failed to stop service."];
				}
				
				//finish pending
				[self removeServiceFromPending:selectedIndex];
				[servicesTable reloadData];
			}];
		}
		else {
			[[[NSApp delegate] clustersBrowser] setMessage:@"Starting service..."];
			[[[NSApp delegate] clustersBrowser] indicateBusy];
			
			NSLog(@"Inspector: starting service %@", [selectedService valueForKey:@"serviceName"]);
			[selectedService start: ^{
				
				[[[NSApp delegate] clustersBrowser] indicateDone];
				if ([selectedService isRunning]) {
					[[[NSApp delegate] clustersBrowser] setMessage:@"Service started sucessfuly."];
				}
				else {
					[[[NSApp delegate] clustersBrowser] setMessage:@"Failed to start service."];
				}
				
				//finish pending
				[self removeServiceFromPending:selectedIndex];
				[servicesTable reloadData];
			}];
			
		}
		
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
		[hostname setStringValue:[selectedServer valueForKey:@"hostname"]];
		if ([[selectedServer class] isEqual:[HyperTable class]]) {
			[dfsProvider setHidden:NO];
			[dfsProvider setStringValue:[selectedServer valueForKey:@"currentDfs"]];
		}
		else {
			NSLog(@"Inspector: Non-HyperTable Server selected");
			[dfsProvider setHidden:YES];
		}

		NSString * remoteShellValue = [NSString stringWithFormat:@"%@@%@:%d",
									   [selectedServer valueForKey:@"sshUserName"],
									   [selectedServer valueForKey:@"ipAddress"],
									   [[selectedServer valueForKey:@"sshPort"] intValue]];
		[remoteShell setStringValue:remoteShellValue];
		int health = [[selectedServer valueForKey:@"healthPercent"] intValue];
		[healthBar setIntValue:health];
		[healthPercentage setStringValue:[NSString stringWithFormat:@"%d %%", health]];
		[comments setStringValue:[selectedServer valueForKey:@"comment"]];
	}
	else {
		NSLog(@"Inspector: Nothing selected.");
		
		[objectTitle setStringValue:@"Nothing selected"];
		[hostname setStringValue:@"--"];
		[dfsProvider setStringValue:@"--"];
		[healthBar setIntValue:0];
		[healthPercentage setStringValue:@"-- %%"];
		[comments setStringValue:@""];
	}
	[servicesTable reloadData];
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
		Service * selectedService = [services objectAtIndex:rowIndex];
		if ([[aTableColumn identifier] isEqual:@"name"]) {
			return [selectedService valueForKey:@"serviceName"];
		}
		if ([[aTableColumn identifier] isEqual:@"image"]) {
			int pid = [[selectedService valueForKey:@"processID"] intValue];
			if (pid > 0) {
				return [[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] 
																pathForResource:@"ServiceStatusRunning" ofType:@"png"]];
			}
			else {
				return [[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] 
																pathForResource:@"ServiceStatusStopped" ofType:@"png"]];
			}
		}
	}
	
	return nil;
}

- (void)tableViewSelectionIsChanging:(NSNotification *)aNotification
{
	int selection = [[aNotification object] selectedRow];
	if (selection >= 0) {
		selectedServiceIndex = selection;
		NSLog(@"Inspector: selected service at index %d", selectedServiceIndex);
	}
	
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

#pragma mark Service Control ComboBox Delegate

-(id)comboBoxCell:(NSComboBoxCell*)cell objectValueForItemAtIndex:(int)index
{
	if ([self isCurrentServicePending]) {
		NSLog(@"Service at index %d is in pending state...", selectedServiceIndex);
		return @"Pending...";
	}
	
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
	if ([self isCurrentServicePending])
		return 1;
	else
		return 2; // two positions in combo
}

@end
