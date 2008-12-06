//
//  WeekCell.h
//  AppSalesMobile
//
//  Created by Ole Zorn on 31.10.08.
//  Copyright 2008 omz:software. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Day;

@interface WeekCell : UITableViewCell {
	
	UILabel *dayLabel;
	UILabel *weekdayLabel;
	UILabel *revenueLabel;
	UILabel *detailsLabel;
	UIView *graphView;
	Day *day;
	float maxRevenue;
	UIColor *graphColor;
}

@property (retain) Day *day;
@property (assign) float maxRevenue;
@property (retain) UIColor *graphColor;

@end
