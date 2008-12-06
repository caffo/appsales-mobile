//
//  EntryCell.m
//  AppSalesMobile
//
//  Created by Ole Zorn on 01.11.08.
//  Copyright 2008 omz:software. All rights reserved.
//

#import "EntryCell.h"
#import "Entry.h"

@implementation EntryCell

@synthesize entry;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier 
{
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
		iconView = [[[UIImageView alloc] initWithFrame:CGRectMake(6,6,32,32)] autorelease];
		descriptionLabel = [[[UILabel alloc] initWithFrame:CGRectMake(45, 0, 270, 44)] autorelease];
		descriptionLabel.font = [UIFont systemFontOfSize:15.0];
		descriptionLabel.lineBreakMode = UILineBreakModeWordWrap;
		descriptionLabel.numberOfLines = 2;
		
		[self.contentView addSubview:descriptionLabel];
		[self.contentView addSubview:iconView];
		
    }
    return self;
}

- (void)setEntry:(Entry *)newEntry
{
	[newEntry retain];
	[entry release];
	entry = newEntry;
	if (entry == nil)
		return;
	
	descriptionLabel.text = [self.entry description];
	UIImage *icon;
	if (self.entry.transactionType == 1) {
		if (self.entry.units >= 0)
			icon = [UIImage imageNamed:@"Purchase.png"];
		else
			icon = [UIImage imageNamed:@"Return.png"];
	}
	else {
		icon = [UIImage imageNamed:@"Download.png"];
	}
	iconView.image = icon;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];
}


- (void)dealloc 
{
	self.entry = nil;
    [super dealloc];
}


@end
