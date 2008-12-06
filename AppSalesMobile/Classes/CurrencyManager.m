//
//  CurrencyManager.m
//  AppSales
//
//  Created by Ole Zorn on 11.09.08.
//  Copyright 2008 omz:software. All rights reserved.
//

#import "CurrencyManager.h"


@implementation CurrencyManager

@synthesize baseCurrency;
@synthesize lastRefresh;
@synthesize exchangeRates;
@synthesize availableCurrencies;

- (id)init
{
	[super init];
	
	self.availableCurrencies = [NSArray arrayWithObjects:
								  @"USD", @"AUD", @"BHD", @"THB", @"BND", 
								  @"CLP", @"DKK", @"EUR", @"HUF", @"HKD", @"ISK", @"CAD", 
								  @"QAR", @"KWD", @"MYR", @"MTL", @"MUR", @"MXN", 
								  @"NPR", @"TWD", @"NZD", @"NOK", @"PKR", @"GBP", 
								  @"ZAR", @"BRL", @"CNY", @"OMR", @"IDR", @"RUB", 
								  @"SAR", @"ILS", @"SEK", @"CHF", @"SGD", @"SKK", 
								  @"LKR", @"KRW", @"KZT", @"CZK", @"AED", @"JPY", 
								  @"CYP", @"INR", nil];
	
	isRefreshing = NO;
	self.baseCurrency = [[NSUserDefaults standardUserDefaults] objectForKey:@"CurrencyManagerBaseCurrency"];
	if (!self.baseCurrency)
		self.baseCurrency = @"EUR";
	
	self.lastRefresh = [[NSUserDefaults standardUserDefaults] objectForKey:@"CurrencyManagerLastRefresh"];
	if (!self.lastRefresh)
		self.lastRefresh = [NSDate dateWithTimeIntervalSince1970:1225397963]; //Oct, 30, 2008
	
	exchangeRates = [[[NSUserDefaults standardUserDefaults] objectForKey:@"CurrencyManagerExchangeRates"] retain];
	if (!exchangeRates) {
		exchangeRates = [NSMutableDictionary new];
		[exchangeRates setObject:[NSNumber numberWithFloat:0.2178] forKey:@"\"AED to EUR\""];
		[exchangeRates setObject:[NSNumber numberWithFloat:0.5096] forKey:@"\"AUD to EUR\""];
		[exchangeRates setObject:[NSNumber numberWithFloat:2.1227] forKey:@"\"BHD to EUR\""];
		[exchangeRates setObject:[NSNumber numberWithFloat:0.5519] forKey:@"\"BND to EUR\""];
		[exchangeRates setObject:[NSNumber numberWithFloat:0.3351] forKey:@"\"BRL to EUR\""];
		[exchangeRates setObject:[NSNumber numberWithFloat:0.6378] forKey:@"\"CAD to EUR\""];
		[exchangeRates setObject:[NSNumber numberWithFloat:0.6605] forKey:@"\"CHF to EUR\""];
		[exchangeRates setObject:[NSNumber numberWithFloat:0.0012] forKey:@"\"CLP to EUR\""];
		[exchangeRates setObject:[NSNumber numberWithFloat:0.1171] forKey:@"\"CNY to EUR\""];
		[exchangeRates setObject:[NSNumber numberWithFloat:2.0112] forKey:@"\"CYP to EUR\""];
		[exchangeRates setObject:[NSNumber numberWithFloat:0.0389] forKey:@"\"CZK to EUR\""];
		[exchangeRates setObject:[NSNumber numberWithFloat:0.1343] forKey:@"\"DKK to EUR\""];
		[exchangeRates setObject:[NSNumber numberWithFloat:1.0000] forKey:@"\"EUR to EUR\""];
		[exchangeRates setObject:[NSNumber numberWithFloat:1.1968] forKey:@"\"GBP to EUR\""];
		[exchangeRates setObject:[NSNumber numberWithFloat:0.1033] forKey:@"\"HKD to EUR\""];
		[exchangeRates setObject:[NSNumber numberWithFloat:0.0037] forKey:@"\"HUF to EUR\""];
		[exchangeRates setObject:[NSNumber numberWithFloat:0.0001] forKey:@"\"IDR to EUR\""];
		[exchangeRates setObject:[NSNumber numberWithFloat:0.2003] forKey:@"\"ILS to EUR\""];
		[exchangeRates setObject:[NSNumber numberWithFloat:0.0159] forKey:@"\"INR to EUR\""];
		[exchangeRates setObject:[NSNumber numberWithFloat:0.0036] forKey:@"\"ISK to EUR\""];
		[exchangeRates setObject:[NSNumber numberWithFloat:0.0084] forKey:@"\"JPY to EUR\""];
		[exchangeRates setObject:[NSNumber numberWithFloat:0.0006] forKey:@"\"KRW to EUR\""];
		[exchangeRates setObject:[NSNumber numberWithFloat:2.9416] forKey:@"\"KWD to EUR\""];
		[exchangeRates setObject:[NSNumber numberWithFloat:0.0067] forKey:@"\"KZT to EUR\""];
		[exchangeRates setObject:[NSNumber numberWithFloat:0.0073] forKey:@"\"LKR to EUR\""];
		[exchangeRates setObject:[NSNumber numberWithFloat:2.7266] forKey:@"\"MTL to EUR\""];
		[exchangeRates setObject:[NSNumber numberWithFloat:0.0246] forKey:@"\"MUR to EUR\""];
		[exchangeRates setObject:[NSNumber numberWithFloat:0.0592] forKey:@"\"MXN to EUR\""];
		[exchangeRates setObject:[NSNumber numberWithFloat:0.221] forKey:@"\"MYR to EUR\""];
		[exchangeRates setObject:[NSNumber numberWithFloat:0.11335] forKey:@"\"NOK to EUR\""];
		[exchangeRates setObject:[NSNumber numberWithFloat:0.0101] forKey:@"\"NPR to EUR\""];
		[exchangeRates setObject:[NSNumber numberWithFloat:0.4338] forKey:@"\"NZD to EUR\""];
		[exchangeRates setObject:[NSNumber numberWithFloat:2.0786] forKey:@"\"OMR to EUR\""];
		[exchangeRates setObject:[NSNumber numberWithFloat:0.0101] forKey:@"\"PKR to EUR\""];
		[exchangeRates setObject:[NSNumber numberWithFloat:0.2198] forKey:@"\"QAR to EUR\""];
		[exchangeRates setObject:[NSNumber numberWithFloat:0.029] forKey:@"\"RUB to EUR\""];
		[exchangeRates setObject:[NSNumber numberWithFloat:0.2134] forKey:@"\"SAR to EUR\""];
		[exchangeRates setObject:[NSNumber numberWithFloat:0.0978] forKey:@"\"SEK to EUR\""];
		[exchangeRates setObject:[NSNumber numberWithFloat:0.5226] forKey:@"\"SGD to EUR\""];
		[exchangeRates setObject:[NSNumber numberWithFloat:0.0329] forKey:@"\"SKK to EUR\""];
		[exchangeRates setObject:[NSNumber numberWithFloat:0.0228] forKey:@"\"THB to EUR\""];
		[exchangeRates setObject:[NSNumber numberWithFloat:0.024] forKey:@"\"TWD to EUR\""];
		[exchangeRates setObject:[NSNumber numberWithFloat:0.8003] forKey:@"\"USD to EUR\""];
		[exchangeRates setObject:[NSNumber numberWithFloat:0.0764] forKey:@"\"ZAR to EUR\""];
		[self refreshIfNeeded];
	}
		
	return self;
}

- (void)setBaseCurrency:(NSString *)newBaseCurrency
{
	[newBaseCurrency retain];
	[baseCurrency release];
	baseCurrency = newBaseCurrency;
	[[NSUserDefaults standardUserDefaults] setObject:baseCurrency forKey:@"CurrencyManagerBaseCurrency"];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"CurrencyManagerDidChangeBaseCurrency" object:self];
}

- (NSString *)baseCurrencyDescription
{
	if ([baseCurrency isEqual:@"EUR"])
		return @"€";
	if ([baseCurrency isEqual:@"USD"])
		return @"$";
	if ([baseCurrency isEqual:@"JPY"])
		return @"¥";
	if ([baseCurrency isEqual:@"GBP"])
		return @"£";
	
	return baseCurrency;
}

- (void)refreshIfNeeded
{
	if (!isRefreshing && ([[NSDate date] timeIntervalSinceDate:self.lastRefresh] > 21600)) { 
		isRefreshing = YES;
		[self performSelectorInBackground:@selector(refreshExchangeRates) withObject:nil];
	}
}

- (void)forceRefresh
{
	if (isRefreshing)
		return;
	[self performSelectorInBackground:@selector(refreshExchangeRates) withObject:nil];
}

- (void)refreshFailed
{
	isRefreshing = NO;
	[[NSNotificationCenter defaultCenter] postNotificationName:@"CurrencyManagerError" object:self];
}

- (void)finishRefreshWithExchangeRates:(NSMutableDictionary *)newExchangeRates
{
	self.exchangeRates = newExchangeRates;
	isRefreshing = NO;
	self.lastRefresh = [NSDate date];
	//NSLog(@"%@", self.exchangeRates);
	
	[[NSUserDefaults standardUserDefaults] setObject:self.exchangeRates forKey:@"CurrencyManagerExchangeRates"];
	[[NSUserDefaults standardUserDefaults] setObject:self.lastRefresh forKey:@"CurrencyManagerLastRefresh"];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"CurrencyManagerDidUpdate" object:self];
}

- (void)refreshExchangeRates
{
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	NSMutableDictionary *newExchangeRates = [NSMutableDictionary dictionary];
	
	[newExchangeRates setObject:[NSNumber numberWithFloat:1.0] forKey:@"\"EUR to EUR\""];
	
	NSMutableString *urlString = [NSMutableString stringWithString:@"http://quote.yahoo.com/d/quotes.csv?s="];
	//NSMutableArray *currencies = [NSMutableArray arrayWithObjects:@"USD", @"AUD", @"CAD", @"GBP", @"JPY", nil];
		
	int i = 0;
	for (NSString *currency in self.availableCurrencies) {
		if (i > 0)
			[urlString appendString:@"+"];
		if (![currency isEqual:@"EUR"])
			[urlString appendFormat:@"%@%@=X", currency, @"EUR"];
		i++;
	}
	[urlString appendString:@"&f=nl1"];
	
	NSString *csv = [NSString stringWithContentsOfURL:[NSURL URLWithString:urlString]];
	if (!csv) {
		//NSLog(@"URL could not be retrieved");
		[self performSelectorOnMainThread:@selector(refreshFailed) withObject:nil waitUntilDone:YES];
		[pool release];
		return;
	}
	NSArray *lines = [csv componentsSeparatedByString:@"\n"];
	for (NSString *line in lines) {
		NSArray *comps = [line componentsSeparatedByString:@","];
		if ([comps count] == 2) {
			NSString *currenciesString = [comps objectAtIndex:0]; //ex: "USD to EUR"
			float exchangeRate = [[comps objectAtIndex:1] floatValue];
			[newExchangeRates setObject:[NSNumber numberWithFloat:exchangeRate] forKey:currenciesString];
		}
	}
	[self performSelectorOnMainThread:@selector(finishRefreshWithExchangeRates:) withObject:newExchangeRates waitUntilDone:YES];
	[pool release];
}

- (float)convertValue:(float)sourceValue fromCurrency:(NSString *)sourceCurrency
{
	if (([sourceCurrency isEqual:@"EUR"]) && ([self.baseCurrency isEqual:@"EUR"]))
		return sourceValue;
	
	NSNumber *conversionRateEuroNumber = [exchangeRates objectForKey:[NSString stringWithFormat:@"\"%@ to EUR\"", sourceCurrency]];
	if (!conversionRateEuroNumber) {
		//NSLog(@"Error: Currency code not found or exchange rates not downloaded yet");
		return 0.0;
	}
	float conversionRateEuro = [conversionRateEuroNumber floatValue];
	float valueInEuro = sourceValue * conversionRateEuro;
	if ([self.baseCurrency isEqual:@"EUR"])
		return valueInEuro;
	
	NSNumber *conversionRateBaseCurrencyNumber = [exchangeRates objectForKey:[NSString stringWithFormat:@"\"%@ to EUR\"", self.baseCurrency]];
	float conversionRateBaseCurrency = [conversionRateBaseCurrencyNumber floatValue];
	float valueInBaseCurrency = valueInEuro / conversionRateBaseCurrency;
	
	return valueInBaseCurrency;
}

+ (CurrencyManager *)sharedManager
{
	static CurrencyManager *sharedManager = nil;
	if (sharedManager == nil)
		sharedManager = [CurrencyManager new];
	return sharedManager;
}

- (void)dealloc
{
	[exchangeRates release];
	[baseCurrency release];
	[super dealloc];
}

@end
