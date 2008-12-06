//
//  CountriesController.h
//  AppSalesMobile
//
//  Created by Ole Zorn on 31.10.08.
//  Copyright 2008 omz:software. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CountriesController : UITableViewController {

	NSArray *countries;
	NSArray *products;
	
	float totalRevenue;
	int displayMode;
}

@property (retain) NSArray *countries;
@property (retain) NSArray *products;
@property (assign) float totalRevenue;
@property (assign) int displayMode;

@end
