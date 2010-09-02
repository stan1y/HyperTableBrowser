//
//  Inspector.m
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 21/8/2010.
//  Copyright 2010 Stanislav Yudin. All rights reserved.
//

#import "Inspector.h"
#import "Server.h"
#import "HyperTable.h"
#import "ClustersBrowser.h"

@implementation Inspector

@synthesize hostname;
@synthesize healthPercentage;
@synthesize healthBar;
@synthesize servicesTable;
@synthesize dfsProvider;
@synthesize status;

@synthesize objectTitle;
@synthesize comments;
@synthesize sshUserName;
@synthesize ipAddressAndSshPort;

@synthesize refreshCurrentServer;

- (void) dealloc
{
	[refreshCurrentServer release];
	[objectTitle release];
	[hostname release];
	[healthPercentage release];
	[healthBar release];
	[comments release];
	[ipAddressAndSshPort release];
	[servicesTable release];
	[dfsProvider release];
	[status release];
	
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

- (IBAction) operateService:(id)sender
{
	Server<ClusterMember> * selectedServer = [[ClustersBrowser sharedInstance] selectedServer];
	if (selectedServer) {
		NSArray * services = [selectedServer services];
		
		if (!services) {
			NSLog(@"Inspector: No services on %@, nothing to operate.", [selectedServer valueForKey:@"serverName"]);
			return;
		}
		
		int selectedIndex = selectedServiceIndex;
		Service * selectedService = [services objectAtIndex:selectedIndex];

		//set as pending
		[self addServiceToPending:selectedIndex];
		//if running -> stop it, otherwise start it
		if ([[selectedService valueForKey:@"processID"] intValue] > 0) {
			
			NSLog(@"Inspector: stopping service %@", [selectedService valueForKey:@"serviceName"]);
			[selectedService stop: ^{
				
				if ([selectedService isRunning]) {
					NSRunAlertPanel(@"Operation failed", [NSString stringWithFormat:@"Failed to stop service %@", [selectedService valueForKey:@"serviceName"]], @"Continue", nil, nil);				
				}
				
				//finish pending
				[self removeServiceFromPending:selectedIndex];
				[servicesTable reloadData];
			}];
		}
		else {
			NSLog(@"Inspector: starting service %@", [selectedService valueForKey:@"serviceName"]);
			[selectedService start: ^{
				
				if (![selectedService isRunning]) {
					NSRunAlertPanel(@"Operation failed", [NSString stringWithFormat:@"Failed to start service %@", [selectedService valueForKey:@"serviceName"]], @"Continue", nil, nil);
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
	id selectedServer = [[ClustersBrowser sharedInstance] selectedServer];
	if (selectedServer) {
		NSLog(@"Inspector: %@ [%@] is selected.", [selectedServer valueForKey:@"uniqueID"], [selectedServer class]);
		
		[refreshCurrentServer setEnabled:YES];
		[objectTitle setStringValue:[selectedServer valueForKey:@"serverName"]];
		[hostname setStringValue:[selectedServer valueForKey:@"hostname"]];
		[status setStringValue:[selectedServer statusString]];
		
		if ([[selectedServer class] isEqual:[HyperTable class]]) {
			[dfsProvider setHidden:NO];
			[dfsProvider setStringValue:[selectedServer valueForKey:@"currentDfs"]];
		}
		else {
			NSLog(@"Inspector: Non-HyperTable Server selected");
			[dfsProvider setHidden:YES];
		}

		[ipAddressAndSshPort setStringValue:[NSString stringWithFormat:@"%@:%d", [selectedServer valueForKey:@"ipAddress"], [[selectedServer valueForKey:@"sshPort"] intValue]] ];
		[sshUserName setStringValue:[selectedServer valueForKey:@"sshUserName"]];
		
		int health = [[selectedServer valueForKey:@"healthPercent"] intValue];
		[healthBar setIntValue:health];
		[healthPercentage setStringValue:[NSString stringWithFormat:@"%d %%", health]];
		[comments setStringValue:[selectedServer valueForKey:@"comment"]];
	}
	else {
		NSLog(@"Inspector: Nothing selected.");
		
		[refreshCurrentServer setEnabled:NO];
		[objectTitle setStringValue:@"- No Selection -"];
		[hostname setStringValue:@"--"];
		[dfsProvider setStringValue:@"--"];
		[healthBar setIntValue:0];
		[healthPercentage setStringValue:@"-- %%"];
		[comments setStringValue:@""];
		[sshUserName setStringValue:@""];
		[status setStringValue:@"-"];
		[ipAddressAndSshPort setStringValue:@""];
	}
	[servicesTable reloadData];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
	Server<ClusterMember> * selected = [[ClustersBrowser sharedInstance] selectedServer];
	if (selected) {
		return [[selected services] count];
	}
	
	return 0;
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn 
			row:(NSInteger)rowIndex
{
	
	Server<ClusterMember> * selectedServer = [[ClustersBrowser sharedInstance] selectedServer];
	if (selectedServer) {
		NSArray * services = [selectedServer services];
		
		if (!services) {
			return @"Not Available";
		}
		Service * selectedService = [services objectAtIndex:rowIndex];
		
		if ([[aTableColumn identifier] isEqual:@"control"]) {
			return nil;
		}
		else if ([[aTableColumn identifier] isEqual:@"image"]) {
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
		else {
			return [selectedService valueForKey:[aTableColumn identifier]];
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
		Server<ClusterMember> * selectedServer = [[ClustersBrowser sharedInstance] selectedServer];
		if (selectedServer) {
			NSArray * services = [selectedServer services];
			[cell setRepresentedObject:[services objectAtIndex:index]];
			[cell reloadData];
			[cell selectItemAtIndex:0];
		}
	}
}


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
		return 1; // only one position for pending
	else
		return 2; // two positions in combo
}


- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor
{
	if (![[fieldEditor string] length]) {
		NSLog(@"Inspector: Can't set empty string");
		return NO;
	}
	
	Server * selectedServer = [[ClustersBrowser sharedInstance] selectedServer] ;
	if ([control isEqual:objectTitle]) {
		NSLog(@"Inspector: Modifying server %@(%@).serverName = %@", 
			  [selectedServer class],
			  [selectedServer valueForKey:@"uniqueID" ],
			  [fieldEditor string]);
		
		[selectedServer setValue:[fieldEditor string] forKey:@"serverName"];
	}
	else if ([control isEqual:ipAddressAndSshPort]) {
		
		//all string is ip by default
		NSString * ipAddress = [fieldEditor string];
		
		//look for ":" to cut port if any
		NSRange portRange = [[fieldEditor string] rangeOfString:@":"];
		if (portRange.location != NSNotFound) {
			//ip address is only the rest of it
			ipAddress = [[fieldEditor string] substringWithRange:NSMakeRange(0, portRange.location)];
			
			//substring till the end
			portRange.length = [[fieldEditor string] length] - portRange.location - 1;
			portRange.location += 1;
			NSString * portAsString = [[fieldEditor string] substringWithRange:portRange];
			
			if ([portAsString length]) {
				int portAsInt = [portAsString intValue];
				if (portAsInt > 0 && portAsInt < 1024) {
					NSLog(@"Inspector: Modifying server %@(%@).sshPort = %d", 
						  [selectedServer class],
						  [selectedServer valueForKey:@"uniqueID" ],
						  portAsInt);
					
					[selectedServer setValue:[NSNumber numberWithInt:portAsInt] forKey:@"sshPort"];
				}
			}
		}
		else {
			//set port to default 22
			NSLog(@"Inspector: Modifying server %@(%@).sshPort = 22", 
				  [selectedServer class],
				  [selectedServer valueForKey:@"uniqueID"]);
			[selectedServer setValue:[NSNumber numberWithInt:22] forKey:@"sshPort"];
		}

		//set ip address
		//all string is an ip then
		NSLog(@"Inspector: Modifying server %@(%@).ipAddress = %@", 
			  [selectedServer class],
			  [selectedServer valueForKey:@"uniqueID" ],
			  ipAddress);
		
		[selectedServer setValue:ipAddress forKey:@"ipAddress"];
	}
	else if ([control isEqual:sshUserName]) {
		NSLog(@"Inspector: Modifying server %@(%@).sshUserName = %@", 
			  [selectedServer class],
			  [selectedServer valueForKey:@"uniqueID" ],
			  [fieldEditor string]);
		
		[selectedServer setValue:[fieldEditor string] forKey:@"sshUserName"];
	}
	else if ([control isEqual:comments]) {
		NSLog(@"Inspector: Modifying server %@(%@).comment = %@", 
			  [selectedServer class],
			  [selectedServer valueForKey:@"uniqueID"],
			  [fieldEditor string]);
		
		[selectedServer setValue:[fieldEditor string] forKey:@"comment"];
	}
	
	NSError * err = nil;
	[[[NSApp delegate] managedObjectContext] save:&err];
	if (err) {
		[[NSApp delegate] presentError:err];
		return NO;
	}
	else
		return YES;
}

@end
