//
//  ProductCell.m
//  AppSalesMobile
//
//  Created by Ole Zorn on 31.10.08.
//  Copyright 2008 omz:software. All rights reserved.
//

#import "ProductCell.h"
#import "CurrencyManager.h"

@implementation ProductCell

@synthesize totalRevenue;
@synthesize graphColor;
@synthesize productInfo;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
		UIColor *calendarBackgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
		UIView *calendarBackgroundView = [[[UIView alloc] initWithFrame:CGRectMake(0,0,45,44)] autorelease];
		calendarBackgroundView.backgroundColor = calendarBackgroundColor;
		
		iconView = [[[UIImageView alloc] initWithFrame:CGRectMake(6, 7, 32, 32)] autorelease];
		iconView.image = [UIImage imageNamed:@"Product.png"];
		
		detailsLabel = [[[UILabel alloc] initWithFrame:CGRectMake(50, 27, 250, 14)] autorelease];
		detailsLabel.textColor = [UIColor blackColor];
		detailsLabel.font = [UIFont systemFontOfSize:12.0]; 
		detailsLabel.textAlignment = UITextAlignmentCenter;
		
		revenueLabel = [[[UILabel alloc] initWithFrame:CGRectMake(50, 0, 100, 30)] autorelease];
		revenueLabel.font = [UIFont boldSystemFontOfSize:20.0];
		revenueLabel.textAlignment = UITextAlignmentRight;
		revenueLabel.adjustsFontSizeToFitWidth = YES;
		
		graphLabel = [[[UILabel alloc] initWithFrame:CGRectMake(160, 4, 130, 21)] autorelease];
		graphLabel.textAlignment = UITextAlignmentRight;
		graphLabel.font = [UIFont boldSystemFontOfSize:12.0];
		graphLabel.backgroundColor = [UIColor clearColor];
		graphLabel.textColor = [UIColor whiteColor];
		graphLabel.text = @"## %";
		
		self.graphColor = [UIColor colorWithRed:0.54 green:0.61 blue:0.67 alpha:1.0];
		
		UIView *graphBackground = [[UIView alloc] initWithFrame:CGRectMake(160, 4, 130, 21)];
		graphBackground.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1.0];
		
		graphView = [[[UIView alloc] initWithFrame:CGRectMake(160, 4, 130, 21)] autorelease];
		graphView.backgroundColor = self.graphColor;
		
		[self.contentView addSubview:calendarBackgroundView];
		[self.contentView addSubview:iconView];
		[self.contentView addSubview:revenueLabel];
		[self.contentView addSubview:graphBackground];
		[self.contentView addSubview:graphView];
		[self.contentView addSubview:graphLabel];
		[self.contentView addSubview:iconView];
		[self.contentView addSubview:detailsLabel];
		
		percentFormatter = [NSNumberFormatter new];
		[percentFormatter setMaximumFractionDigits:1];
		[percentFormatter setMinimumIntegerDigits:1];
		
		revenueFormatter = [NSNumberFormatter new];
		[revenueFormatter setMinimumFractionDigits:2];
		[revenueFormatter setMaximumFractionDigits:2];
		[revenueFormatter setMinimumIntegerDigits:1];
		
		self.totalRevenue = 1.0;
    }
    return self;
}

- (void)setProductInfo:(NSDictionary *)newProductInfo
{
	[newProductInfo retain];
	[productInfo release];
	productInfo = newProductInfo;
	if (productInfo == nil)
		return;
	
	NSString *details = [NSString stringWithFormat:@"%@ × %@", [productInfo objectForKey:@"units"], [productInfo objectForKey:@"name"]];
	detailsLabel.text = details;
	
	revenueLabel.text = [NSString stringWithFormat:@"%@ %@", [revenueFormatter stringFromNumber:[productInfo objectForKey:@"revenue"]], [[CurrencyManager sharedManager] baseCurrencyDescription]];
	
	float revenue = [[productInfo objectForKey:@"revenue"] floatValue];
	float percent;
	if (revenue > 0)
		percent = revenue / self.totalRevenue;
	else
		percent = 0.0;
	NSString *percentString = [NSString stringWithFormat:@"%@ %% ", [percentFormatter stringFromNumber:[NSNumber numberWithFloat:percent*100]]];
	graphLabel.text = percentString;
	
	graphView.frame = CGRectMake(160, 4, 130.0 * percent, 21);
	
}

- (void)dealloc 
{
	self.graphColor = nil;
	self.productInfo = nil;
	[revenueFormatter release];
	[percentFormatter release];
	[super dealloc];
}


@end
