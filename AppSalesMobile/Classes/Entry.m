//
//  Entry.m
//  AppSalesMobile
//
//  Created by Ole Zorn on 30.10.08.
//  Copyright 2008 omz:software. All rights reserved.
//

#import "Entry.h"
#import "Country.h"
#import "CurrencyManager.h"

@implementation Entry

@synthesize country;
@synthesize productName;
@synthesize currency;
@synthesize transactionType;
@synthesize royalties;
@synthesize units;


- (id)initWithProductName:(NSString *)name transactionType:(int)type units:(int)u royalties:(float)r currency:(NSString *)currencyCode country:(Country *)aCountry
{
	[super init];
	self.country = aCountry;
	self.productName = name;
	self.currency = currencyCode;
	self.transactionType = type;
	self.units = u;
	self.royalties = r;
	[country.entries addObject:self];
	return self;
}


- (id)initWithCoder:(NSCoder *)coder
{
	[super init];
	self.country = [coder decodeObjectForKey:@"country"];
	[country.entries addObject:self];
	self.productName = [coder decodeObjectForKey:@"productName"];
	self.currency = [coder decodeObjectForKey:@"currency"];
	self.transactionType = [coder decodeIntForKey:@"transactionType"];
	self.units = [coder decodeIntForKey:@"units"];
	self.royalties = [coder decodeFloatForKey:@"royalties"];
	
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
	[coder encodeObject:self.country forKey:@"country"];
	[coder encodeObject:self.productName forKey:@"productName"];
	[coder encodeObject:self.currency forKey:@"currency"];
	[coder encodeInt:self.transactionType forKey:@"transactionType"];
	[coder encodeInt:self.units forKey:@"units"];
	[coder encodeFloat:self.royalties forKey:@"royalties"];
}


- (float)totalRevenueInBaseCurrency
{
	if (transactionType == 1) {
		float revenueInLocalCurrency = self.royalties * self.units;
		float revenueInBaseCurrency = [[CurrencyManager sharedManager] convertValue:revenueInLocalCurrency fromCurrency:self.currency];
		return revenueInBaseCurrency;
	}
	else {
		return 0.0;
	}
}

- (NSString *)description
{
	if (self.transactionType == 1) {
		NSNumberFormatter *numberFormatter = [[NSNumberFormatter new] autorelease];
		[numberFormatter setMinimumFractionDigits:2];
		[numberFormatter setMaximumFractionDigits:2];
		[numberFormatter setMinimumIntegerDigits:1];
		NSString *royaltiesString = [numberFormatter stringFromNumber:[NSNumber numberWithFloat:self.royalties]];
		NSString *totalRevenueString = [numberFormatter stringFromNumber:[NSNumber numberWithFloat:[self totalRevenueInBaseCurrency]]];
		NSString *royaltiesSumString = [numberFormatter stringFromNumber:[NSNumber numberWithFloat:self.royalties * self.units]];
		
		return [NSString stringWithFormat:@"%@ : %i × %@ %@ = %@ %@ ≈ %@ %@", self.productName, self.units, royaltiesString, self.currency, royaltiesSumString, self.currency, totalRevenueString, [[CurrencyManager sharedManager] baseCurrencyDescription]];
	}
	else {
		return [NSString stringWithFormat:NSLocalizedString(@"%@ : %i free downloads",nil), self.productName, self.units];
	}
}

- (void)dealloc
{
	self.country = nil;
	self.productName = nil;
	self.currency = nil;
	
	[super dealloc];
}



@end
