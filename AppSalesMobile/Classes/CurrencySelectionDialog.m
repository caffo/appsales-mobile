//
//  CurrencySelectionDialog.m
//  AppSalesMobile
//
//  Created by Ole Zorn on 20.11.08.
//  Copyright 2008 omz:software. All rights reserved.
//

#import "CurrencySelectionDialog.h"
#import "CurrencyManager.h"

@implementation CurrencySelectionDialog

@synthesize sortedCurrencies;

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view.
- (void)viewDidLoad 
{
    [super viewDidLoad];
	
	self.title = NSLocalizedString(@"Currencies",nil);
	//Create sorted list of currencies:
	self.sortedCurrencies = [NSMutableArray array];
	NSArray *availableCurrencies = [[CurrencyManager sharedManager] availableCurrencies];
	for (NSString *currencyCode in availableCurrencies) {
		NSDictionary *currencyInfo = [NSDictionary dictionaryWithObjectsAndKeys:currencyCode, @"currencyCode", NSLocalizedString(currencyCode,nil), @"localizedName", nil];
		[self.sortedCurrencies addObject:currencyInfo];
	}
	NSSortDescriptor *sorter = [[[NSSortDescriptor alloc] initWithKey:@"localizedName" ascending:YES] autorelease];
	[self.sortedCurrencies sortUsingDescriptors:[NSArray arrayWithObject:sorter]];
	
	UIBarButtonItem *doneButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismiss)] autorelease];
	[self.navigationItem setRightBarButtonItem:doneButtonItem];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	return [self.sortedCurrencies count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
    }
	
	cell.text = [[self.sortedCurrencies objectAtIndex:[indexPath row]] objectForKey:@"localizedName"];
	
    return cell;
}

- (void)dismiss
{
	[self dismissModalViewControllerAnimated:YES];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	int row = [indexPath row];
	NSDictionary *selectedCurrency = [sortedCurrencies objectAtIndex:row];
	NSString *selectedCurrencyCode = [selectedCurrency objectForKey:@"currencyCode"];
	[[CurrencyManager sharedManager] setBaseCurrency:selectedCurrencyCode];
	[self dismiss];
}


/*
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
    }
    if (editingStyle == UITableViewCellEditingStyleInsert) {
    }
}
*/

/*
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/


/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
}
*/
/*
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
*/

- (void)dealloc 
{
	self.sortedCurrencies = nil;
	
    [super dealloc];
}


@end

