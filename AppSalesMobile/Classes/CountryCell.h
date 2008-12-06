//
//  CountryCell.h
//  AppSalesMobile
//
//  Created by Ole Zorn on 31.10.08.
//  Copyright 2008 omz:software. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Country;

@interface CountryCell : UITableViewCell {

	UIImageView *flagView;
	UILabel *revenueLabel;
	UILabel *countryLabel;
	UILabel *detailsLabel;
	UIView *graphView;
	UILabel *graphLabel;
	float totalRevenue;
	Country *country;	
	UIColor *graphColor;
	NSNumberFormatter *percentFormatter;
}

@property (retain) Country *country;
@property (retain) UIColor *graphColor;
@property (assign) float totalRevenue;

@end
