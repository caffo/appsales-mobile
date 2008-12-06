//
//  EntriesController.m
//  AppSalesMobile
//
//  Created by Ole Zorn on 01.11.08.
//  Copyright 2008 omz:software. All rights reserved.
//

#import "EntriesController.h"
#import "Entry.h"
#import "EntryCell.h"

@implementation EntriesController

@synthesize entries;

- (void)viewDidLoad 
{
    [super viewDidLoad];
	self.tableView.rowHeight = 45.0;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	if (self.entries)
		return [self.entries count];
	
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    EntryCell *cell = (EntryCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[EntryCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
	Entry *entry = [self.entries objectAtIndex:[indexPath row]];
	cell.entry = entry;
	
    return cell;
}

- (void)dealloc 
{
	self.entries = nil;
    [super dealloc];
}


@end

