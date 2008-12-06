//
//  ProductCell.h
//  AppSalesMobile
//
//  Created by Ole Zorn on 31.10.08.
//  Copyright 2008 omz:software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProductCell : UITableViewCell {
	
	UIImageView *iconView;
	UILabel *revenueLabel;
	UILabel *detailsLabel;
	UIView *graphView;
	UILabel *graphLabel;
	float totalRevenue;
	UIColor *graphColor;
	NSNumberFormatter *percentFormatter;
	NSNumberFormatter *revenueFormatter;
	NSDictionary *productInfo;
}

@property (retain) NSDictionary *productInfo;
@property (retain) UIColor *graphColor;
@property (assign) float totalRevenue;

@end
