//
//  WeeksController.h
//  AppSalesMobile
//
//  Created by Ole Zorn on 31.10.08.
//  Copyright 2008 omz:software. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RootViewController;

@interface WeeksController : UITableViewController {

	IBOutlet RootViewController *rootViewController;
	NSMutableArray *daysByMonth;
	float maxRevenue;
}

@property (nonatomic, retain) NSMutableArray *daysByMonth;
@property (assign) float maxRevenue;

- (void)reload;

@end
