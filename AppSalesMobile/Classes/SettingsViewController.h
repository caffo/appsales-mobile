//
//  SettingsViewController.h
//  AppSalesMobile
//
//  Created by Ole Zorn on 30.10.08.
//  Copyright 2008 omz:software. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SettingsViewController : UIViewController <UITextFieldDelegate> {
	
	IBOutlet UILabel *explanationsLabel;
	IBOutlet UILabel *copyrightLabel;
	IBOutlet UITextField *usernameTextField;
	IBOutlet UITextField *passwordTextField;
	IBOutlet UISegmentedControl *currencySelectionControl;
	IBOutlet UILabel *loginSectionLabel;
	IBOutlet UILabel *currencySectionLabel;
	IBOutlet UILabel *lastRefreshLabel;
}

- (IBAction)refreshExchangeRates:(id)sender;
- (IBAction)changeCurrency:(id)sender;
- (void)currencyRatesDidUpdate;
- (void)currencyRatesFailedToUpdate;
- (void)baseCurrencyChanged;

@end
