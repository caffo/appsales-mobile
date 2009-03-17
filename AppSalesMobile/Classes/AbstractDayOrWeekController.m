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
	self.maxRevenue = 0;
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

	/* Immediately determine all section titles; if we don't, Cocoa will be asking us for them, anyways,
	 * and will do so in arbitrary order. We're better off doing it on our own terms.
	 */
	[self performSelectorInBackground:@selector(determineSectionTitles)
						   withObject:nil];
}

- (void)didDetermineHeader
{
	[self.tableView reloadData];
}

/*!
 * @brief Determine the header for a given section
 *
 * Called on a thread. Notifies the main thread to update the display after this section is complete.
 */
- (void)determineHeaderForSection:(int)section
{
	if (section > (daysByMonth.count-1)) return;

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
	[self.sectionTitles setObject:sectionTitle forKey:[NSNumber numberWithInt:section]];

	[self performSelectorOnMainThread:@selector(didDetermineHeader)
						   withObject:nil
						waitUntilDone:NO];
}

/*!
 * @brief Determine all section titles, starting with the first
 *
 * This should be called on a new thread
 */
- (void)determineSectionTitles
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	for (int i = 0; i < [self.tableView numberOfSections]; i++) {
		[self determineHeaderForSection:i];
	}
	[pool release];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if (self.daysByMonth.count == 0)
		return @"";
	
	NSString *sectionTitle = [sectionTitles objectForKey:[NSNumber numberWithInt:section]];
	if (!sectionTitle) {
		/* Just show the date for now. The threaded determineSectionTitles hasn't gotten to this section
		 * yet, but when it does, the sectionTitles dictionary will be updated and reload called.
		 */
		Day *firstDayInSection = [[daysByMonth objectAtIndex:section] objectAtIndex:0];
		NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
		[dateFormatter setDateFormat:@"MMMM yyyy"];
		
		sectionTitle = [dateFormatter stringFromDate:firstDayInSection.date];
		[self.sectionTitles setObject:sectionTitle forKey:[NSNumber numberWithInt:section]];
	}
	
	return sectionTitle;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
	NSInteger count = self.daysByMonth.count;
	return (count > 1 ? count : 1);
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	if (self.daysByMonth.count > 0) {
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
