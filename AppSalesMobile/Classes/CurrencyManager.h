//
//  CurrencyManager.h
//  AppSales
//
//  Created by Ole Zorn on 11.09.08.
//  Copyright 2008 omz:software. All rights reserved.
//



@interface CurrencyManager : NSObject {
	
	NSString *baseCurrency;
	NSMutableDictionary *exchangeRates;
	NSDate *lastRefresh;
	BOOL isRefreshing;
	NSArray *availableCurrencies;
}

@property (retain) NSString *baseCurrency;
@property (retain) NSDate *lastRefresh;
@property (retain) NSMutableDictionary *exchangeRates;
@property (retain) NSArray *availableCurrencies;

+ (CurrencyManager *)sharedManager;
- (NSString *)baseCurrencyDescription;
- (void)forceRefresh;
- (void)refreshIfNeeded;
- (void)refreshExchangeRates;
- (void)refreshFailed;
- (void)finishRefreshWithExchangeRates:(NSMutableDictionary *)newExchangeRates;
- (float)convertValue:(float)sourceValue fromCurrency:(NSString *)sourceCurrency;

@end
