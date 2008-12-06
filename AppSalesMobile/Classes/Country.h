//
//  Country.h
//  AppSalesMobile
//
//  Created by Ole Zorn on 30.10.08.
//  Copyright 2008 omz:software. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Day;

@interface Country : NSObject {
	Day *day;
	NSMutableArray *entries;
	NSString *name;
}

@property (retain) NSString *name;
@property (retain) Day *day;
@property (retain) NSMutableArray *entries;

- (id)initWithName:(NSString *)countryName day:(Day *)aDay;
- (float)totalRevenueInBaseCurrency;
- (NSString *)totalRevenueString;
- (NSArray *)children;


@end
