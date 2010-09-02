//
//  ClustersBrowser.m
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 9/8/2010.
//  Copyright 2010 Stanislav Yudin. All rights reserved.
//

#import "ClustersBrowser.h"
#import "TablesBrowser.h"
#import "HyperTableOperation.h"
#import "SSHClient.h"

@implementation ClustersBrowser

@synthesize statusMessageField;
@synthesize statusIndicator;

@synthesize newServerOrClusterDialog;

@synthesize membersTable;
@synthesize clustersSelector;

@synthesize inspector;

// Singleton

static ClustersBrowser * sharedBrowser = nil;
+ (ClustersBrowser *) sharedInstance {
    return sharedBrowser;
}

- (id) _initWithWindow:(id)window
{
	if (!(self = [super initWithWindow:window]))
		return nil;
	
	NSLog(@"Initializing Clusters Browser [%@]", window);	
	selectedServerIndex = 0;
	return self;
}

- (id) initWithWindow:(id)window
{	
	if(sharedBrowser == nil) {
        sharedBrowser = [[ClustersBrowser alloc] _initWithWindow:window];
    }
	return [ClustersBrowser sharedInstance];
}

- (void) dealloc
{
	[statusMessageField release];
	[statusIndicator release];
	[newServerOrClusterDialog release];
	
	[inspector release];
	[membersTable release];
	
	[super dealloc];
}

- (void) refreshClustersList
{
	[clustersSelector removeAllItems];
	for (Cluster * c in [Cluster clusters]) {
		[clustersSelector addItemWithTitle:[c valueForKey:@"name"]];
	}
}

- (void) refreshMembersList
{
	[membersTable reloadData];	
	[[self inspector] refresh:nil];
}

- (void) awakeFromNib
{	
	[self refreshClustersList];
	[self refreshMembersList];
}

- (Cluster *) selectedCluster
{
	if ([clustersSelector selectedItem]) {
		return [Cluster clusterWithName:[[clustersSelector selectedItem] title]];
	}
	return nil;
}

- (Server<ClusterMember> *) selectedServer
{
	Cluster * cl = [self selectedCluster];
	if (cl) {
		return [cl memberWithIndex:selectedServerIndex];
	}
	return nil;
}

- (IBAction) clusterSelectionChanged:(id)sender
{
	[self refreshMembersList];
	
	if ([[[TablesBrowser sharedInstance] window] isVisible]) {
		//make sure tables browser uses current cluster's brokers
		[[TablesBrowser sharedInstance] updateBrokers:sender];
	}
}

- (void)tableViewSelectionIsChanging:(NSNotification *)aNotification
{
	int index = [[aNotification object] selectedRow];
	if (index < [[[self selectedCluster] members] count]) {
		selectedServerIndex = index;
		NSLog(@"Selection changed to index %d\n%@", index, [self selectedServer]);
		[[self inspector] refresh:nil];
	}
}

- (IBAction) updateCurrentServer:(id)sender
{
	Server<ClusterMember> * currentServer = [self selectedServer];
	if (currentServer) {		
		[currentServer updateStatusWithCompletionBlock:^(BOOL success) {
			[membersTable reloadData];
			[[self inspector] refresh:nil];
		}];
	}
}

- (IBAction) updateCluster:(id)sender
{
	id cluster = [self selectedCluster];
	for (Server<ClusterMember> * member in [cluster members]) {
		[member updateStatusWithCompletionBlock:^(BOOL success) {
			[membersTable reloadData];
			[[self inspector] refresh:nil];
		}];
	}
}

- (IBAction) addServer:(id)sender
{
	[[self newServerOrClusterDialog] setCreateNewCluster:NO];
	[[self newServerOrClusterDialog] showModalForWindow:[self window]];
}

- (IBAction) defineNewCluster:(id)sender
{
	[[self newServerOrClusterDialog] setCreateNewCluster:YES];
	[[self newServerOrClusterDialog] showModalForWindow:[self window]];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
	if ( [self selectedCluster] ) {
		return [[[self selectedCluster] members] count];
	}
	else {
		return 0;
	}
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn 
			row:(NSInteger)rowIndex
{
	if (rowIndex + 1 > [[[self selectedCluster] members] count]) {
		NSLog(@"Member index [%d] is bigger that list of members [%d]", rowIndex, [[[self selectedCluster] members] count]);
		return nil;
	}
	if ([[aTableColumn identifier] isEqual:@"summary"]) {
		int runningServices = 0;
		for (id service in [[[self selectedCluster] memberWithIndex:rowIndex] services]) {
			if ([[service valueForKey:@"processID"] intValue] > 0) {
				runningServices++;
			}
		}
		return [NSString stringWithFormat:@"%d of %d services running", 
				runningServices, [[[[self selectedCluster] memberWithIndex:rowIndex] services] count]];
	}
	else if ([[aTableColumn identifier] isEqual:@"status"]) {
		return [[[self selectedCluster] memberWithIndex:rowIndex] statusString];
	}
	else {
		NSLog(@"%d) %@ = %@", rowIndex, [aTableColumn identifier], [[[self selectedCluster] memberWithIndex:rowIndex] valueForKey:[aTableColumn identifier]]);
		return [[[self selectedCluster] memberWithIndex:rowIndex] valueForKey:[aTableColumn identifier]];
	}
}

@end
