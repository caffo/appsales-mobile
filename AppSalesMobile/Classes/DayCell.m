//
//  DayCell.m
//  AppSalesMobile
//
//  Created by Ole Zorn on 31.10.08.
//  Copyright 2008 omz:software. All rights reserved.
//

#import "DayCell.h"
#import "Day.h"

@implementation DayCell

@synthesize day;
@synthesize maxRevenue;
@synthesize graphColor;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
		UIColor *calendarBackgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
		UIView *calendarBackgroundView = [[[UIView alloc] initWithFrame:CGRectMake(0,0,45,44)] autorelease];
		calendarBackgroundView.backgroundColor = calendarBackgroundColor;
		
		dayLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 45, 30)] autorelease];
		dayLabel.textAlignment = UITextAlignmentCenter;
		dayLabel.font = [UIFont boldSystemFontOfSize:22.0];
		dayLabel.backgroundColor = calendarBackgroundColor;
		dayLabel.opaque = YES;
		
		weekdayLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0, 27, 45, 14)] autorelease];
		weekdayLabel.textAlignment = UITextAlignmentCenter;
		weekdayLabel.font = [UIFont systemFontOfSize:10.0];
		weekdayLabel.backgroundColor = calendarBackgroundColor;
		weekdayLabel.opaque = YES;
		
		revenueLabel = [[[UILabel alloc] initWithFrame:CGRectMake(50, 0, 100, 30)] autorelease];
		revenueLabel.font = [UIFont boldSystemFontOfSize:20.0];
		revenueLabel.textAlignment = UITextAlignmentRight;
		revenueLabel.backgroundColor = [UIColor whiteColor];
		revenueLabel.adjustsFontSizeToFitWidth = YES;
		revenueLabel.opaque = YES;
		
		detailsLabel = [[[UILabel alloc] initWithFrame:CGRectMake(50, 27, 250, 14)] autorelease];
		detailsLabel.textColor = [UIColor grayColor];
		detailsLabel.backgroundColor = [UIColor whiteColor];
		detailsLabel.opaque = YES;
		detailsLabel.font = [UIFont systemFontOfSize:12.0];
		detailsLabel.textAlignment = UITextAlignmentCenter;
		
		//self.graphColor = [UIColor colorWithRed:0.54 green:0.61 blue:0.67 alpha:1.0];
		self.graphColor = [UIColor colorWithRed:0.81 green:1.0 blue:0.4 alpha:1.0]; //lime
		
		graphView = [[[UIView alloc] initWithFrame:CGRectMake(160, 0, 130, 20)] autorelease];
		graphView.opaque = YES;
		graphView.backgroundColor = self.graphColor;
		
		[self.contentView addSubview:calendarBackgroundView];
		[self.contentView addSubview:dayLabel];
		[self.contentView addSubview:weekdayLabel];
		[self.contentView addSubview:revenueLabel];
		[self.contentView addSubview:graphView];
		[self.contentView addSubview:detailsLabel];
		
		self.maxRevenue = 1.0;
    }
    return self;
}

- (void)setDay:(Day *)newDay
{
	[newDay retain];
	[day release];
	day = newDay;
	if (day == nil)
		return;
	
	dayLabel.text = [day dayString];
	weekdayLabel.text = [day weekdayString];
	revenueLabel.text = [day totalRevenueString];
	detailsLabel.text = [day description];
	
	
	dayLabel.textColor = [self.day weekdayColor];
	weekdayLabel.textColor = [self.day weekdayColor];
	graphView.frame = CGRectMake(160, 4, 130.0 * ([self.day totalRevenueInBaseCurrency] / self.maxRevenue), 21);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated 
{
	[super setSelected:selected animated:animated];
	
	if (selected) {
		dayLabel.textColor = [UIColor whiteColor];
		weekdayLabel.textColor = [UIColor whiteColor];
		revenueLabel.textColor = [UIColor whiteColor];
		detailsLabel.textColor = [UIColor whiteColor];
		graphView.backgroundColor = [UIColor whiteColor];
	}
	else {
		dayLabel.textColor = [self.day weekdayColor];
		weekdayLabel.textColor = [self.day weekdayColor];
		revenueLabel.textColor = [UIColor blackColor];
		detailsLabel.textColor = [UIColor grayColor];
		graphView.backgroundColor = self.graphColor;
	}
}


- (void)dealloc 
{
	self.day = nil;
	self.graphColor = nil;
    [super dealloc];
}


@end
