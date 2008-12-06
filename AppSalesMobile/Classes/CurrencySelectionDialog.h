//
//  CurrencySelectionDialog.h
//  AppSalesMobile
//
//  Created by Ole Zorn on 20.11.08.
//  Copyright 2008 omz:software. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CurrencySelectionDialog : UITableViewController {

	NSMutableArray *sortedCurrencies;
	
}

@property (retain) NSMutableArray *sortedCurrencies;

- (void)dismiss;

@end
