//
//  EntryCell.h
//  AppSalesMobile
//
//  Created by Ole Zorn on 01.11.08.
//  Copyright 2008 omz:software. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Entry;

@interface EntryCell : UITableViewCell {

	UIImageView *iconView;
	UILabel *descriptionLabel;
	Entry *entry;
}

@property (retain) Entry *entry;

@end
