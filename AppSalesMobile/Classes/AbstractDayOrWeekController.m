//
//  AbstractDayOrWeekController.m
//  AppSalesMobile
//
//  Created by Evan Schoenberg on 1/29/09.
//  Copyright 2009 Adium X / Saltatory Software. All rights reserved.
//

#import "AbstractDayOrWeekController.h"
#import "Day.h"
#import "DayCell.h"
#import "CountriesController.h"
#import "RootViewController.h"
#import "CurrencyManager.h"

@implementation AbstractDayOrWeekController

@synthesize daysByMonth;
@synthesize maxRevenue;
@synthesize sectionTitles;

- (id)initWithCoder:(NSCoder *)coder
{
	[super initWithCoder:coder];
	self.daysByMonth = [NSMutableArray array];
	self.maxRevenue = 0.1;
	self.sectionTitles = [NSMutableDictionary dictionary];
	return self;
}

- (void)viewDidLoad
{
	self.tableView.rowHeight = 45.0;
}

- (void)reload
{
	[sectionTitles removeAllObjects];
	[self.tableView reloadData];
}

- (void)didDetermineHeader
{
	[self.tableView reloadData];
}

- (void)determineHeaderForSection:(NSNumber *)sectionNumber
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSInteger section = [sectionNumber integerValue];

	NSString *sectionTitle;
	Day *firstDayInSection = [[daysByMonth objectAtIndex:section] objectAtIndex:0];
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	[dateFormatter setDateFormat:@"MMMM yyyy"];
	
	NSArray *selectedMonth = [[[self.daysByMonth objectAtIndex:section] copy] autorelease];
	float total = 0.0f;
	for(Day * selectedDay in selectedMonth) {
		NSArray *children = [selectedDay children];
		total += [[children valueForKeyPath:@"@sum.totalRevenueInBaseCurrency"] floatValue];
	}
	
	NSNumberFormatter *numberFormatter = [[NSNumberFormatter new] autorelease];
	[numberFormatter setMinimumFractionDigits:2];
	[numberFormatter setMaximumFractionDigits:2];
	[numberFormatter setMinimumIntegerDigits:1];
	NSString *totalRevenueString = [numberFormatter stringFromNumber:[NSNumber numberWithFloat:total]];
	
	sectionTitle = [NSString stringWithFormat:@"%@ - %@ %@",[dateFormatter stringFromDate:firstDayInSection.date],totalRevenueString,[[CurrencyManager sharedManager] baseCurrencyDescription]];
	[self.sectionTitles setObject:sectionTitle forKey:sectionNumber];
	
	[self performSelectorOnMainThread:@selector(didDetermineHeader)
						   withObject:nil
						waitUntilDone:NO];
	[pool release];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if ([self.daysByMonth count] == 0)
		return @"";
	
	NSString *sectionTitle = [sectionTitles objectForKey:[NSNumber numberWithInt:section]];
	if (!sectionTitle) {
		Day *firstDayInSection = [[daysByMonth objectAtIndex:section] objectAtIndex:0];
		NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
		[dateFormatter setDateFormat:@"MMMM yyyy"];
		
		sectionTitle = [dateFormatter stringFromDate:firstDayInSection.date];
		[self.sectionTitles setObject:sectionTitle forKey:[NSNumber numberWithInt:section]];

		[self performSelectorInBackground:@selector(determineHeaderForSection:)
							   withObject:[NSNumber numberWithInt:section]];
	}
	
	return sectionTitle;
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


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath 
{ 
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		//NSLog(@"%@", rootViewController);
		int section = [indexPath section];
		int row = [indexPath row];
		NSArray *selectedMonth = [self.daysByMonth objectAtIndex:section];
		Day *selectedDay = [selectedMonth objectAtIndex:row];
		
		[rootViewController deleteDay:selectedDay];
	}
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath 
{
	return YES;
}

- (void)dealloc 
{
	self.sectionTitles = nil;
	self.daysByMonth = nil;
    [super dealloc];
}

@end
