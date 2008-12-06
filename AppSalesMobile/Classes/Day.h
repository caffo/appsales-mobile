//
//  Day.h
//  AppSalesMobile
//
//  Created by Ole Zorn on 30.10.08.
//  Copyright 2008 omz:software. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Country;

@interface Day : NSObject {
	NSMutableDictionary *countries;
	NSDate *date;
	NSString *cachedWeekEndDateString;
	UIColor *cachedWeekDayColor;
	NSString *cachedDayString;
	BOOL isWeek;
	BOOL wasLoadedFromDisk;
	NSString *name;
}

@property (retain) NSDate *date;
@property (retain) NSMutableDictionary *countries;
@property (retain) NSString *cachedWeekEndDateString;
@property (retain) UIColor *cachedWeekDayColor;
@property (retain) NSString *cachedDayString;
@property (assign) BOOL isWeek;
@property (assign) BOOL wasLoadedFromDisk;
@property (retain) NSString *name;

- (id)initWithCSV:(NSString *)csv;
- (Country *)countryNamed:(NSString *)countryName;
- (void)setDateString:(NSString *)dateString;
- (float)totalRevenueInBaseCurrency;
- (NSString *)dayString;
- (NSString *)weekdayString;
- (NSString *)weekEndDateString;
- (NSString *)totalRevenueString;
- (UIColor *)weekdayColor;
- (NSString *)proposedFilename;
- (NSArray *)children;

@end
