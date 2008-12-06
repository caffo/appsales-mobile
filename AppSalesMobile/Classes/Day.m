//
//  Day.m
//  AppSalesMobile
//
//  Created by Ole Zorn on 30.10.08.
//  Copyright 2008 omz:software. All rights reserved.
//

#import "Day.h"
#import "Country.h"
#import "Entry.h"
#import "CurrencyManager.h"

@implementation Day

@synthesize date;
@synthesize countries;
@synthesize cachedWeekEndDateString;
@synthesize cachedWeekDayColor;
@synthesize cachedDayString;
@synthesize isWeek;
@synthesize wasLoadedFromDisk;
@synthesize name;

- (id)initWithCSV:(NSString *)csv
{
	[super init];
	
	self.wasLoadedFromDisk = NO;
	
	self.countries = [NSMutableDictionary dictionary];
	
	NSMutableArray *lines = [[[csv componentsSeparatedByString:@"\n"] mutableCopy] autorelease];
	if ([lines count] > 0)
		[lines removeObjectAtIndex:0];
	if ([lines count] < 1)
		return nil; //sanity check
	
	for (NSString *line in lines) {
		NSArray *columns = [line componentsSeparatedByString:@"\t"];
		if ([columns count] > 15) {
			NSString *productName = [columns objectAtIndex:6];
			NSString *transactionType = [columns objectAtIndex:8];
			NSString *units = [columns objectAtIndex:9];
			NSString *royalties = [columns objectAtIndex:10];
			NSString *dateColumn = [columns objectAtIndex:11];
			if (!self.date) {
				if ((([dateColumn rangeOfString:@"/"].location != NSNotFound) && ([dateColumn length] == 10))
					|| (([dateColumn rangeOfString:@"/"].location == NSNotFound) && ([dateColumn length] == 8))) {
					[self setDateString:dateColumn];
				}
				else {
					NSLog(@"Date is invalid: %@", dateColumn);
					[self release];
					return nil;
				}
			}
			NSString *countryString = [columns objectAtIndex:14];
			if ([countryString length] != 2) {
				NSLog(@"Country code is invalid");
				[self release];
				return nil; //sanity check, country code has to have two characters
			}
			NSString *royaltyCurrency = [columns objectAtIndex:15];
			
			Country *country = [self countryNamed:countryString]; //will be created on-the-fly if needed.
			[[[Entry alloc] initWithProductName:productName 
											  transactionType:[transactionType intValue] 
														units:[units intValue] 
													royalties:[royalties floatValue] 
													 currency:royaltyCurrency
													  country:country] autorelease]; //gets added to the countries entry list automatically
		}
	}
	
	return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
	[super init];
	self.countries = [coder decodeObjectForKey:@"countries"];
	self.date = [coder decodeObjectForKey:@"date"];
	self.isWeek = [coder decodeBoolForKey:@"isWeek"];
	self.name = [coder decodeObjectForKey:@"name"];
	self.wasLoadedFromDisk = YES;
	
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
	[coder encodeObject:self.countries forKey:@"countries"];
	[coder encodeObject:self.date forKey:@"date"];
	[coder encodeBool:self.isWeek forKey:@"isWeek"];
	[coder encodeObject:self.name forKey:@"name"];
}


- (Country *)countryNamed:(NSString *)countryName
{
	Country *country = [self.countries objectForKey:countryName];
	if (!country) {
		country = [[[Country alloc] initWithName:countryName day:self] autorelease];
		[self.countries setObject:country forKey:countryName];
	}
	return country;
}

- (void)setDateString:(NSString *)dateString
{
	int year, month, day;
	if ([dateString rangeOfString:@"/"].location == NSNotFound) {
		year = [[dateString substringWithRange:NSMakeRange(0,4)] intValue];
		month = [[dateString substringWithRange:NSMakeRange(4,2)] intValue];
		day = [[dateString substringWithRange:NSMakeRange(6,2)] intValue];
	}
	else {
		year = [[dateString substringWithRange:NSMakeRange(6,4)] intValue];
		month = [[dateString substringWithRange:NSMakeRange(0,2)] intValue];
		day = [[dateString substringWithRange:NSMakeRange(3,2)] intValue];
	}
	
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDateComponents *components = [[NSDateComponents new] autorelease];
	[components setYear:year];
	[components setMonth:month];
	[components setDay:day];
	self.date = [calendar dateFromComponents:components];
}

- (NSString *)description
{
	NSMutableDictionary *salesByProduct = [NSMutableDictionary dictionary];
	for (Country *c in [self.countries allValues]) {
		for (Entry *e in [c entries]) {
			if ([e transactionType] == 1) {
				NSNumber *unitsOfProduct = [salesByProduct objectForKey:[e productName]];
				int u = (unitsOfProduct != nil) ? ([unitsOfProduct intValue]) : 0;
				u += [e units];
				[salesByProduct setObject:[NSNumber numberWithInt:u] forKey:[e productName]];
			}
		}
	}
	NSMutableString *productSummary = [NSMutableString stringWithString:@"("];
	NSEnumerator *reverseEnum = [[salesByProduct keysSortedByValueUsingSelector:@selector(compare:)] reverseObjectEnumerator];
	NSString *productName;
	while (productName = [reverseEnum nextObject]) {
		NSNumber *productSales = [salesByProduct objectForKey:productName];
		[productSummary appendFormat:@"%@ × %@, ", productSales, productName];
	}
	if ([productSummary length] >= 2)
		[productSummary deleteCharactersInRange:NSMakeRange([productSummary length] - 2, 2)];
	[productSummary appendString:@")"];
	
	if ([productSummary isEqual:@"()"])
		return NSLocalizedString(@"No sales",nil);
	
	return productSummary;
}

- (float)totalRevenueInBaseCurrency
{
	float sum = 0.0;
	for (Country *c in [self.countries allValues]) {
		sum += [c totalRevenueInBaseCurrency];
	}
	return sum;
}

- (NSString *)totalRevenueString
{
	NSNumberFormatter *numberFormatter = [[NSNumberFormatter new] autorelease];
	[numberFormatter setMinimumFractionDigits:2];
	[numberFormatter setMaximumFractionDigits:2];
	[numberFormatter setMinimumIntegerDigits:1];
	NSString *totalRevenueString = [numberFormatter stringFromNumber:[NSNumber numberWithFloat:[self totalRevenueInBaseCurrency]]];
	return [NSString stringWithFormat:@"%@ %@", totalRevenueString, [[CurrencyManager sharedManager] baseCurrencyDescription]];
}

- (NSString *)dayString
{
	if (!self.cachedDayString) {
		NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit fromDate:self.date];
		self.cachedDayString = [NSString stringWithFormat:@"%i", [components day]];
	}
	return self.cachedDayString;
}

- (NSString *)weekdayString
{
	NSDateComponents *components = [[NSCalendar currentCalendar] components:NSWeekdayCalendarUnit fromDate:self.date];
	int weekday = [components weekday];
	if (weekday == 1)
		return NSLocalizedString(@"SUN",nil);
	if (weekday == 2)
		return NSLocalizedString(@"MON",nil);
	if (weekday == 3)
		return NSLocalizedString(@"TUE",nil);
	if (weekday == 4)
		return NSLocalizedString(@"WED",nil);
	if (weekday == 5)
		return NSLocalizedString(@"THU",nil);
	if (weekday == 6)
		return NSLocalizedString(@"FRI",nil);
	if (weekday == 7)
		return NSLocalizedString(@"SAT",nil);
	return @"---";
}

- (UIColor *)weekdayColor
{
	if (!self.cachedWeekDayColor) {
		NSDateComponents *components = [[NSCalendar currentCalendar] components:NSWeekdayCalendarUnit fromDate:self.date];
		int weekday = [components weekday];
		if (weekday == 1)
			self.cachedWeekDayColor = [UIColor colorWithRed:0.8 green:0.0 blue:0.0 alpha:1.0];
		else
			self.cachedWeekDayColor = [UIColor blackColor];
	}
	return self.cachedWeekDayColor;
}

- (NSString *)weekEndDateString
{
	if (!self.cachedWeekEndDateString) {
		NSDateComponents *comp = [[[NSDateComponents alloc] init] autorelease];
		[comp setHour:167];
		NSDate *dateWeekLater = [[NSCalendar currentCalendar] dateByAddingComponents:comp toDate:self.date options:0];
		NSDateFormatter *dateFormatter = [[NSDateFormatter new] autorelease];
		[dateFormatter setTimeStyle:NSDateFormatterNoStyle];
		[dateFormatter setDateStyle:NSDateFormatterShortStyle];
		self.cachedWeekEndDateString = [dateFormatter stringFromDate:dateWeekLater];
	}
	return self.cachedWeekEndDateString;
}


- (NSArray *)children
{
	NSSortDescriptor *sorter = [[[NSSortDescriptor alloc] initWithKey:@"totalRevenueInBaseCurrency" ascending:NO] autorelease];
	NSArray *sortedChildren = [[self.countries allValues] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sorter]];
	return sortedChildren;	
}

- (NSString *)proposedFilename
{
	NSString *dateString = [self.name stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
	if (self.isWeek)
		return [NSString stringWithFormat:@"week_%@.dat", dateString];
	else
		return [NSString stringWithFormat:@"day_%@.dat", dateString];
}

- (void)dealloc
{
	self.cachedDayString = nil;
	self.cachedWeekDayColor = nil;
	self.cachedWeekEndDateString = nil;
	self.countries = nil;
	self.date = nil;
	self.name = nil;
	
	[super dealloc];
}

@end
