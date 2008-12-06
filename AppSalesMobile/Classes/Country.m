//
//  Country.m
//  AppSalesMobile
//
//  Created by Ole Zorn on 30.10.08.
//  Copyright 2008 omz:software. All rights reserved.
//

#import "Country.h"
#import "CurrencyManager.h"
#import "Entry.h"

@implementation Country

@synthesize name;
@synthesize day;
@synthesize entries;

- (id)initWithName:(NSString *)countryName day:(Day *)aDay
{
	[super init];
	self.day = aDay;
	self.name = countryName;
	self.entries = [NSMutableArray array];
	return self;
}

- (NSString *)description
{
	NSMutableDictionary *salesByProduct = [NSMutableDictionary dictionary];
	for (Entry *e in self.entries) {
		if ([e transactionType] == 1) {
			NSNumber *unitsOfProduct = [salesByProduct objectForKey:[e productName]];
			int u = (unitsOfProduct != nil) ? ([unitsOfProduct intValue]) : 0;
			u += [e units];
			[salesByProduct setObject:[NSNumber numberWithInt:u] forKey:[e productName]];
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

- (id)initWithCoder:(NSCoder *)coder
{
	[super init];
	self.day = [coder decodeObjectForKey:@"day"];
	self.name = [coder decodeObjectForKey:@"name"];
	self.entries = [coder decodeObjectForKey:@"entries"];
	
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
	[coder encodeObject:self.day forKey:@"day"];
	[coder encodeObject:self.name forKey:@"name"];
	[coder encodeObject:self.entries forKey:@"entries"];
}

- (float)totalRevenueInBaseCurrency
{
	float sum = 0.0;
	for (Entry *e in self.entries) {
		sum += [e totalRevenueInBaseCurrency];
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

- (NSArray *)children
{
	NSSortDescriptor *sorter = [[[NSSortDescriptor alloc] initWithKey:@"totalRevenueInBaseCurrency" ascending:NO] autorelease];
	NSArray *sortedChildren = [self.entries sortedArrayUsingDescriptors:[NSArray arrayWithObject:sorter]];
	return sortedChildren;
}

- (void)dealloc
{
	self.day = nil;
	self.entries = nil;
	self.name = nil;
	
	[super dealloc];
}

@end
