//
//  Entry.h
//  AppSalesMobile
//
//  Created by Ole Zorn on 30.10.08.
//  Copyright 2008 omz:software. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Country;

@interface Entry : NSObject {
	Country *country;
	NSString *productName;
	int transactionType;
	int units;
	float royalties;
	NSString *currency;
}

@property (retain) Country *country;
@property (retain) NSString *productName;
@property (retain) NSString *currency;
@property (assign) int transactionType;
@property (assign) float royalties;
@property (assign) int units;

- (id)initWithProductName:(NSString *)name transactionType:(int)type units:(int)u royalties:(float)r currency:(NSString *)currencyCode country:(Country *)aCountry;
- (float)totalRevenueInBaseCurrency;

@end
