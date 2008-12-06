//
//  SettingsViewController.m
//  AppSalesMobile
//
//  Created by Ole Zorn on 30.10.08.
//  Copyright 2008 omz:software. All rights reserved.
//

#import "SettingsViewController.h"
#import "CurrencyManager.h"
#import "CurrencySelectionDialog.h"
#import "PasswordKeeper.h"

@implementation SettingsViewController

/*
// Override initWithNibName:bundle: to load the view using a nib file then perform additional customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically.
- (void)loadView {
}
*/

- (void)viewDidLoad 
{
    [super viewDidLoad];
	self.navigationItem.title = NSLocalizedString(@"Settings",nil);
	self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
	explanationsLabel.font = [UIFont systemFontOfSize:12.0];
	explanationsLabel.text = NSLocalizedString(@"Exchange rates are automatically refreshed every 6 hours.\n\nAll information is presented without any warranties.\n\nThe presented market trend reports should not be considered to be your monthly royalty reports.",nil);
	copyrightLabel.font = [UIFont systemFontOfSize:12.0];
	currencySectionLabel.font = [UIFont boldSystemFontOfSize:16.0];
	loginSectionLabel.font = [UIFont boldSystemFontOfSize:16.0];
	lastRefreshLabel.font = [UIFont systemFontOfSize:12.0];
	
	NSString *username = [[PasswordKeeper sharedInstance] objectForKey:@"iTunesConnectUsername"];
	if (username) usernameTextField.text = username;
	NSString *password = [[PasswordKeeper sharedInstance] objectForKey:@"iTunesConnectPassword"];
	if (password) passwordTextField.text = password;
	
	[self baseCurrencyChanged];
	
	[self currencyRatesDidUpdate]; //set proper refresh date in label
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(currencyRatesDidUpdate) name:@"CurrencyManagerDidUpdate" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(currencyRatesFailedToUpdate) name:@"CurrencyManagerError" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(baseCurrencyChanged) name:@"CurrencyManagerDidChangeBaseCurrency" object:nil];
}

- (void)currencyRatesDidUpdate
{
	NSDate *lastRefresh = [[CurrencyManager sharedManager] lastRefresh];
	NSDateFormatter *formatter = [[NSDateFormatter new] autorelease];
	[formatter setTimeStyle:NSDateFormatterShortStyle];
	[formatter setDateStyle:NSDateFormatterMediumStyle];
	NSString *lastRefreshString = [formatter stringFromDate:lastRefresh];
	
	lastRefreshLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Last refresh: %@",nil), lastRefreshString];
}

- (void)currencyRatesFailedToUpdate
{
	UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error",nil) message:NSLocalizedString(@"The currency exchange rates could not be refreshed. Please check your internet connection.",nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil] autorelease];
	[alert show];
}

- (void)baseCurrencyChanged
{
	[currencySelectionControl setTitle:[NSString stringWithFormat:NSLocalizedString(@"Select... ( %@ )",nil), [[CurrencyManager sharedManager] baseCurrencyDescription]] forSegmentAtIndex:0];
}

- (void)viewWillDisappear:(BOOL)animated
{
	if (usernameTextField.text)
		[[PasswordKeeper sharedInstance] setObject:usernameTextField.text forKey:@"iTunesConnectUsername"];
	if (passwordTextField.text)
		[[PasswordKeeper sharedInstance] setObject:passwordTextField.text forKey:@"iTunesConnectPassword"];
	
}

- (IBAction)changeCurrency:(id)sender
{
	CurrencySelectionDialog *currencySelectionDialog = [[CurrencySelectionDialog new] autorelease];
	UINavigationController *navController = [[[UINavigationController alloc] initWithRootViewController:currencySelectionDialog] autorelease];
	[self presentModalViewController:navController animated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	return YES;
}

- (IBAction)refreshExchangeRates:(id)sender
{
	[[CurrencyManager sharedManager] forceRefresh];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [super dealloc];
}


@end
