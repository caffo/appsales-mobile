//
//  AbstractDayOrWeekController.h
//  AppSalesMobile
//
//  Created by Evan Schoenberg on 1/29/09.
//  Copyright 2009 Adium X / Saltatory Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RootViewController;

@interface AbstractDayOrWeekController : UITableViewController {
	IBOutlet RootViewController *rootViewController;
	NSMutableArray *daysByMonth;
	float maxRevenue;
	NSMutableDictionary *sectionTitles;	
}

@property (retain) NSMutableArray *daysByMonth;
@property (assign) float maxRevenue;
@property (retain) NSMutableDictionary *sectionTitles;

- (void)reload;

@end
