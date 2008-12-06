//
//  DaysController.m
//  AppSalesMobile
//
//  Created by Ole Zorn on 30.10.08.
//  Copyright 2008 omz:software. All rights reserved.
//

#import "DaysController.h"
#import "Day.h"
#import "DayCell.h"
#import "CountriesController.h"
#import "RootViewController.h"


@implementation DaysController

@synthesize daysByMonth;
@synthesize maxRevenue;

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
    }
    return self;
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

- (id)initWithCoder:(NSCoder *)coder
{
	[super initWithCoder:coder];
	self.daysByMonth = [NSMutableArray array];
	self.maxRevenue = 0.1;
	return self;
}

- (void)viewDidLoad
{
	self.tableView.rowHeight = 45.0;
}

- (void)reload
{
	[self.tableView reloadData];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if ([self.daysByMonth count] == 0)
		return @"";
	
	Day *firstDayInSection = [[daysByMonth objectAtIndex:section] objectAtIndex:0];
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	[dateFormatter setDateFormat:@"MMMM yyyy"];
	return [dateFormatter stringFromDate:firstDayInSection.date];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
	if ([self.daysByMonth count] > 1)
		return [self.daysByMonth count];
	else
		return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	if ([self.daysByMonth count] > 0) {
		return [[self.daysByMonth objectAtIndex:section] count];
	}
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    static NSString *CellIdentifier = @"Cell";
    
    DayCell *cell = (DayCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[DayCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
    }
	cell.maxRevenue = self.maxRevenue;
    cell.day = [[self.daysByMonth objectAtIndex:[indexPath section]] objectAtIndex:[indexPath row]];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	//cell.text = [[[self.daysByMonth objectAtIndex:[indexPath section]] objectAtIndex:[indexPath row]] description];
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	int section = [indexPath section];
	int row = [indexPath row];
	NSArray *selectedMonth = [self.daysByMonth objectAtIndex:section];
	Day *selectedDay = [selectedMonth objectAtIndex:row];
	NSArray *children = [selectedDay children];
	
	float total = [[children valueForKeyPath:@"@sum.totalRevenueInBaseCurrency"] floatValue];
		
	CountriesController *countriesController = [[[CountriesController alloc] initWithStyle:UITableViewStylePlain] autorelease];
	countriesController.totalRevenue = total;
	
	NSDateFormatter *dateFormatter = [[NSDateFormatter new] autorelease];
	[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
	[dateFormatter setTimeStyle:NSDateFormatterNoStyle];
	NSString *formattedDate = [dateFormatter stringFromDate:selectedDay.date];
	countriesController.title = formattedDate;
	
	countriesController.countries = children;
	
	//[countriesController.tableView reloadData];
	
	[[self navigationController] pushViewController:countriesController animated:YES];
	
	//[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}



- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath 
{    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		//NSLog(@"%@", rootViewController);
		int section = [indexPath section];
		int row = [indexPath row];
		NSArray *selectedMonth = [self.daysByMonth objectAtIndex:section];
		Day *selectedDay = [selectedMonth objectAtIndex:row];
	
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
		
		[rootViewController deleteDay:selectedDay];
	}
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath 
{
    return YES;
}


/*
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/


/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
}
*/
/*
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
*/

- (void)dealloc 
{
	self.daysByMonth = nil;
    [super dealloc];
}


@end

