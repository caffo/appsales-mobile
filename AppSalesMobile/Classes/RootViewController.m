/*
RootViewController.m
AppSalesMobile

* Copyright (c) 2008, omz:software
* All rights reserved.
*
* Redistribution and use in source and binary forms, with or without
* modification, are permitted provided that the following conditions are met:
*     * Redistributions of source code must retain the above copyright
*       notice, this list of conditions and the following disclaimer.
*     * Redistributions in binary form must reproduce the above copyright
*       notice, this list of conditions and the following disclaimer in the
*       documentation and/or other materials provided with the distribution.
*     * Neither the name of the <organization> nor the
*       names of its contributors may be used to endorse or promote products
*       derived from this software without specific prior written permission.
*
* THIS SOFTWARE IS PROVIDED BY omz:software ''AS IS'' AND ANY
* EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
* WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
* DISCLAIMED. IN NO EVENT SHALL <copyright holder> BE LIABLE FOR ANY
* DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
* (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
* LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
* ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
* (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
* SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import <zlib.h>
#import "RootViewController.h"
#import "AppSalesMobileAppDelegate.h"
#import "NSDictionary+HTTP.h"
#import "Day.h"
#import "Country.h"
#import "Entry.h"
#import "CurrencyManager.h"
#import "SettingsViewController.h"
#import "DaysController.h"
#import "WeeksController.h"
#import "HelpBrowser.h"
#import "SFHFKeychainUtils.h"
#import "Reachability.h"

@implementation RootViewController

@synthesize days;
@synthesize weeks;

- (id)initWithCoder:(NSCoder *)coder
{
	[super initWithCoder:coder];
	
	self.days = [NSMutableDictionary dictionary];
	self.weeks = [NSMutableDictionary dictionary];
	
	NSArray *filenames = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self docPath] error:NULL];
	//NSLog(@"Filenames: %@", filenames);
	
	for (NSString *filename in filenames) {
		if (![[filename pathExtension] isEqual:@"dat"])
			continue;
		NSString *fullPath = [[self docPath] stringByAppendingPathComponent:filename];
		Day *loadedDay = [NSKeyedUnarchiver unarchiveObjectWithFile:fullPath];
		if (loadedDay != nil) {
			if (loadedDay.isWeek)
				[self.weeks setObject:loadedDay forKey:[loadedDay name]];
			else
				[self.days setObject:loadedDay forKey:[loadedDay name]];
		}
	}
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveData) name:UIApplicationWillTerminateNotification object:nil];
	
	return self;
}

- (void)dealloc 
{
	self.days = nil;
	self.weeks = nil;
	
    [super dealloc];
}

- (void)saveData
{
	//save all days/weeks in separate files:
	for (Day *d in [self.days allValues]) {
		NSString *fullPath = [[self docPath] stringByAppendingPathComponent:[d proposedFilename]];
		//wasLoadedFromDisk is set to YES in initWithCoder: ...
		if (!d.wasLoadedFromDisk) {
			[NSKeyedArchiver archiveRootObject:d toFile:fullPath];
		}
	}
	for (Day *w in [self.weeks allValues]) {
		NSString *fullPath = [[self docPath] stringByAppendingPathComponent:[w proposedFilename]];
		//wasLoadedFromDisk is set to YES in initWithCoder: ...
		if (!w.wasLoadedFromDisk) {
			[NSKeyedArchiver archiveRootObject:w toFile:fullPath];
		}
	}
}

- (NSString *)docPath
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	return documentsDirectory;
}

- (void)viewDidLoad 
{
    [super viewDidLoad];
    self.navigationItem.title = @"App Sales";
	progressView.alpha = 0.0;
	
	UIButton *footer = [UIButton buttonWithType:UIButtonTypeCustom];
	[footer setFrame:CGRectMake(0,0,320,20)];
	[footer setFont:[UIFont systemFontOfSize:14.0]];
	[footer setTitleColor:[UIColor colorWithRed:0.3 green:0.34 blue:0.42 alpha:1.0] forState:UIControlStateNormal];
	[footer addTarget:self action:@selector(visitIconDrawer) forControlEvents:UIControlEventTouchUpInside];
	[footer setTitle:NSLocalizedString(@"Flag icons by icondrawer.com",nil) forState:UIControlStateNormal];
	[tableView setTableFooterView:footer];
		
	[[CurrencyManager sharedManager] refreshIfNeeded];
}

- (void)visitIconDrawer
{
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://icondrawer.com"]];
}

- (void)deleteDay:(Day *)dayToDelete
{
	NSString *fullPath = [[self docPath] stringByAppendingPathComponent:[dayToDelete proposedFilename]];
	[[NSFileManager defaultManager] removeItemAtPath:fullPath error:NULL];
	if (dayToDelete.isWeek) {
		[self.weeks removeObjectForKey:dayToDelete.name];
		[self refreshWeekList];
	}
	else {
		[self.days removeObjectForKey:dayToDelete.name];
		[self refreshDayList];
	}
}

- (void)refreshDayList
{
	float max = 0.1;
	for (Day *d in [days allValues]) {
		float r = [d totalRevenueInBaseCurrency];
		if (r > max)
			max = r;
	}
	daysController.maxRevenue = max;
	
	NSMutableArray *daysByMonth = [NSMutableArray array];
	NSSortDescriptor *dateSorter = [[[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO] autorelease];
	NSArray *sortedDays = [[days allValues] sortedArrayUsingDescriptors:[NSArray arrayWithObject:dateSorter]];
	int lastMonth = -1;
	for (Day *d in sortedDays) {
		NSDate *date = d.date;
		NSDateComponents *components = [[NSCalendar currentCalendar] components:NSMonthCalendarUnit fromDate:date];
		int month = [components month];
		if (month != lastMonth) {
			[daysByMonth addObject:[NSMutableArray array]];
			lastMonth = month;
		}
		[[daysByMonth lastObject] addObject:d];
	}
	daysController.daysByMonth = daysByMonth;
	[daysController reload];
	
	[tableView reloadData];
}

- (void)refreshWeekList
{
	float max = 0.1;
	for (Day *w in [weeks allValues]) {
		float r = [w totalRevenueInBaseCurrency];
		if (r > max)
			max = r;
	}
	weeksController.maxRevenue = max;
	
	NSMutableArray *daysByMonth = [NSMutableArray array];
	NSSortDescriptor *dateSorter = [[[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO] autorelease];
	NSArray *sortedDays = [[weeks allValues] sortedArrayUsingDescriptors:[NSArray arrayWithObject:dateSorter]];
	int lastMonth = -1;
	for (Day *d in sortedDays) {
		NSDate *date = d.date;
		NSDateComponents *components = [[NSCalendar currentCalendar] components:NSMonthCalendarUnit fromDate:date];
		int month = [components month];
		if (month != lastMonth) {
			[daysByMonth addObject:[NSMutableArray array]];
			lastMonth = month;
		}
		[[daysByMonth lastObject] addObject:d];
	}
	weeksController.daysByMonth = daysByMonth;
	[weeksController reload];
	
	[tableView reloadData];
}

#pragma mark Download
- (void)downloadFailed
{
	isRefreshing = NO;
	[self setProgress:[NSNumber numberWithFloat:1.0]];
	UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Download Failed",nil) message:NSLocalizedString(@"Sorry, an error occured when trying to download the report files. Please check your username, password and internet connection.",nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil] autorelease];
	[alert show];
}

- (void)successfullyDownloadedDays:(NSDictionary *)newDays
{
	[days addEntriesFromDictionary:newDays];
	[self refreshDayList];
}

- (void)successfullyDownloadedWeeks:(NSDictionary *)newDays
{
	isRefreshing = NO;
	[self setProgress:[NSNumber numberWithFloat:1.0]];
	[weeks addEntriesFromDictionary:newDays];
	[self refreshWeekList];
	//NSLog(@"Downloaded weeks: %@", newDays);
}

- (void)setProgress:(NSNumber *)progress
{
	float p = [progress floatValue];
	//NSLog(@"progress: %f", p);
	progressView.progress = p;
	if (p <= 0.0) {
		[UIView beginAnimations:@"fade" context:nil];
		progressView.alpha = 1.0;
		[UIView commitAnimations];
	}
	if (p >= 1.0) {
		[UIView beginAnimations:@"fade" context:nil];
		progressView.alpha = 0.0;
		[UIView commitAnimations];
	}
}

- (void)fetchReportsWithUserInfo:(NSDictionary *)userInfo
{
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	//NSLog(@"Starting download...");
	NSMutableDictionary *downloadedDays = [NSMutableDictionary dictionary];
	
	[self performSelectorOnMainThread:@selector(setProgress:) withObject:[NSNumber numberWithFloat:0.0] waitUntilDone:YES];
	
	NSString *username = [userInfo objectForKey:@"username"];
	NSString *password = [userInfo objectForKey:@"password"];
	
	NSString *ittsBaseURL = @"https://itts.apple.com";
	NSString *ittsLoginPageURL = @"https://itts.apple.com/cgi-bin/WebObjects/Piano.woa";
	NSString *loginPage = [NSString stringWithContentsOfURL:[NSURL URLWithString:ittsLoginPageURL]];
	
	[self performSelectorOnMainThread:@selector(setProgress:) withObject:[NSNumber numberWithFloat:0.1] waitUntilDone:YES];
	
	NSScanner *scanner = [NSScanner scannerWithString:loginPage];
	NSString *loginAction = nil;
	[scanner scanUpToString:@"name=\"appleConnectForm\" action=\"" intoString:NULL];
	[scanner scanString:@"name=\"appleConnectForm\" action=\"" intoString:NULL];
	[scanner scanUpToString:@"\"" intoString:&loginAction];
	//if (!loginAction)
	//	NSLog(@"Login action not found, maybe already logged in...");
	NSString *dateTypeSelectionPage;
	if (loginAction) { //not logged in yet
		NSString *loginURLString = [ittsBaseURL stringByAppendingString:loginAction];
		NSURL *loginURL = [NSURL URLWithString:loginURLString];
		//NSLog(@"%@", loginURLString);
		NSDictionary *loginDict = [NSDictionary dictionaryWithObjectsAndKeys:username, @"theAccountName", password, @"theAccountPW", nil];
		NSString *encodedLoginDict = [loginDict formatForHTTP];
		NSData *httpBody = [encodedLoginDict dataUsingEncoding:NSASCIIStringEncoding];
		NSMutableURLRequest *loginRequest = [NSMutableURLRequest requestWithURL:loginURL];
		[loginRequest setHTTPMethod:@"POST"];
		[loginRequest setHTTPBody:httpBody];
		NSData *dateTypeSelectionPageData = [NSURLConnection sendSynchronousRequest:loginRequest returningResponse:NULL error:NULL];
		if (dateTypeSelectionPageData == nil) {
			NSLog(@"Error: could not login");
			[pool release];
			[self performSelectorOnMainThread:@selector(downloadFailed) withObject:nil waitUntilDone:YES];
			return;
		}
		dateTypeSelectionPage = [[[NSString alloc] initWithData:dateTypeSelectionPageData encoding:NSUTF8StringEncoding] autorelease];
	}
	else
		dateTypeSelectionPage = loginPage; //already logged in
	
	[self performSelectorOnMainThread:@selector(setProgress:) withObject:[NSNumber numberWithFloat:0.2] waitUntilDone:YES];
	
	scanner = [NSScanner scannerWithString:dateTypeSelectionPage];
	NSString *dateTypeAction = nil;
	[scanner scanUpToString:@"name=\"frmVendorPage\" action=\"" intoString:NULL];
	[scanner scanString:@"name=\"frmVendorPage\" action=\"" intoString:NULL];
	[scanner scanUpToString:@"\"" intoString:&dateTypeAction];
	if (dateTypeAction == nil) {
		NSLog(@"Error: couldn't select date type");
		[pool release];
		[self performSelectorOnMainThread:@selector(downloadFailed) withObject:nil waitUntilDone:YES];
		return;
	}
	
	float prog = 0.2;
	for (int i=0; i<=1; i++) {
		NSString *downloadType;
		NSString *downloadActionName;
		if (i==0) {
			downloadType = @"Daily";
			downloadActionName = @"9.11.1";
			//NSLog(@"Downloading days...");
		}
		else {
			downloadType = @"Weekly";
			downloadActionName = @"9.13.1";
			//NSLog(@"Downloading weeks...");
		}
	
		NSString *dateTypeSelectionURLString = [ittsBaseURL stringByAppendingString:dateTypeAction]; 
		//NSLog(@"%@", dateTypeSelectionURLString);
		NSDictionary *dateTypeDict = [NSDictionary dictionaryWithObjectsAndKeys:
									  downloadType, @"9.9", 
									  downloadType, @"hiddenDayOrWeekSelection", 
									  @"Summary", @"9.7", 
									  @"ShowDropDown", @"hiddenSubmitTypeName", nil];
		NSString *encodedDateTypeDict = [dateTypeDict formatForHTTP];
		NSData *httpBody = [encodedDateTypeDict dataUsingEncoding:NSASCIIStringEncoding];
		NSMutableURLRequest *dateTypeRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:dateTypeSelectionURLString]];
		[dateTypeRequest setHTTPMethod:@"POST"];
		[dateTypeRequest setHTTPBody:httpBody];
		NSData *daySelectionPageData = [NSURLConnection sendSynchronousRequest:dateTypeRequest returningResponse:NULL error:NULL];
		
		//[self performSelectorOnMainThread:@selector(setProgress:) withObject:[NSNumber numberWithFloat:0.3] waitUntilDone:YES];
		
		if (daySelectionPageData == nil) {
			//NSLog(@"Error: could not get list of days");
			[pool release];
			[self performSelectorOnMainThread:@selector(downloadFailed) withObject:nil waitUntilDone:YES];
			return;
		}
		NSString *daySelectionPage = [[[NSString alloc] initWithData:daySelectionPageData encoding:NSUTF8StringEncoding] autorelease];
		scanner = [NSScanner scannerWithString:daySelectionPage];
		NSMutableArray *availableDays = [NSMutableArray array];
		BOOL scannedDay = YES;
		while (scannedDay) {
			NSString *dayString = nil;
			scannedDay = [scanner scanUpToString:@"<option value=\"" intoString:NULL];
			scannedDay = [scanner scanString:@"<option value=\"" intoString:NULL];
			scannedDay = [scanner scanUpToString:@"\"" intoString:&dayString];
			if (dayString) {
				//NSLog(@"%@", dayString);
				if ([dayString rangeOfString:@"/"].location != NSNotFound)
					[availableDays addObject:dayString];
				scannedDay = YES;
			}
			else {
				scannedDay = NO;
			}
		}
		//NSLog(@"Available downloads: %@", availableDays);
			
		if (i==0) { //daily
			NSArray *daysToSkip = [userInfo objectForKey:@"daysToSkip"];
			[availableDays removeObjectsInArray:daysToSkip];			
		}
		else { //weekly
			NSArray *weeksToSkip = [userInfo objectForKey:@"weeksToSkip"];
			[availableDays removeObjectsInArray:weeksToSkip];
		}
		
		//NSLog(@"New downloads: %@", availableDays);
		
		float progressForOneDay = 0.4 / ((float)[availableDays count]);
		scanner = [NSScanner scannerWithString:daySelectionPage];
		NSString *dayDownloadAction = nil;
		[scanner scanUpToString:@"name=\"frmVendorPage\" action=\"" intoString:NULL];
		[scanner scanString:@"name=\"frmVendorPage\" action=\"" intoString:NULL];
		[scanner scanUpToString:@"\"" intoString:&dayDownloadAction];
		if (dayDownloadAction == nil) {
			//NSLog(@"Error: couldn't find download action");
			[pool release];
			[self performSelectorOnMainThread:@selector(downloadFailed) withObject:nil waitUntilDone:YES];
			return;
		}
		NSString *dayDownloadActionURLString = [ittsBaseURL stringByAppendingString:dayDownloadAction];
		//NSLog(@"%@", dayDownloadActionURLString);
		for (NSString *dayString in availableDays) {
			NSDictionary *dayDownloadDict = [NSDictionary dictionaryWithObjectsAndKeys:
											 downloadType, @"9.9", 
											 downloadType, @"hiddenDayOrWeekSelection",
											 @"Download", @"hiddenSubmitTypeName",
											 @"Summary", @"9.7",
											 dayString, downloadActionName, 
											 @"Download", @"download", nil];
			NSString *encodedDayDownloadDict = [dayDownloadDict formatForHTTP];
			httpBody = [encodedDayDownloadDict dataUsingEncoding:NSASCIIStringEncoding];
			NSMutableURLRequest *dayDownloadRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:dayDownloadActionURLString]];
			[dayDownloadRequest setHTTPMethod:@"POST"];
			[dayDownloadRequest setHTTPBody:httpBody];
			NSData *dayData = [NSURLConnection sendSynchronousRequest:dayDownloadRequest returningResponse:NULL error:NULL];
			
			if (daySelectionPageData == nil) {
				//NSLog(@"Error: could not download day");
				[pool release];
				[self performSelectorOnMainThread:@selector(downloadFailed) withObject:nil waitUntilDone:YES];
				return;
			}
			
			NSString *zipFile = [NSTemporaryDirectory() stringByAppendingPathComponent:@"temp.gz"];
			NSString *textFile = [NSTemporaryDirectory() stringByAppendingPathComponent:@"temp.txt"];
			[dayData writeToFile:zipFile atomically:YES];
			gzFile file = gzopen([zipFile UTF8String], "rb");
			FILE *dest = fopen([textFile UTF8String], "w");
			unsigned char buffer[262144];
			int uncompressedLength = gzread(file, buffer, 262144);
			if(fwrite(buffer, 1, uncompressedLength, dest) != uncompressedLength || ferror(dest)) {
				NSLog(@"error writing data");
			}
			fclose(dest);
			gzclose(file);
			
			NSString *text = [NSString stringWithContentsOfFile:textFile];
						
			[[NSFileManager defaultManager] removeItemAtPath:zipFile error:NULL];
			[[NSFileManager defaultManager] removeItemAtPath:textFile error:NULL];
			
			Day *day = [[[Day alloc] initWithCSV:text] autorelease];
			if (day != nil) {
				if (i != 0)
					day.isWeek = YES;
				[downloadedDays setObject:day forKey:dayString];
				day.name = dayString;
			}
			
			prog += progressForOneDay;
			[self performSelectorOnMainThread:@selector(setProgress:) withObject:[NSNumber numberWithFloat:prog] waitUntilDone:YES];
		}
		if (i == 0) {
			[self performSelectorOnMainThread:@selector(successfullyDownloadedDays:) withObject:downloadedDays waitUntilDone:YES];
			[downloadedDays removeAllObjects];
		}
		else
			[self performSelectorOnMainThread:@selector(successfullyDownloadedWeeks:) withObject:downloadedDays waitUntilDone:YES];
	}
}

- (IBAction)downloadReports:(id)sender
{
	if (!isRefreshing) {
		NSString *username = [[NSUserDefaults standardUserDefaults] stringForKey:@"iTunesConnectUsername"];
		NSString *password = [SFHFKeychainUtils getPasswordForUsername:username
														andServiceName:@"omz:software AppSales Mobile Service"
																 error:NULL];
		if (!username || !password || [username isEqual:@""] || [password isEqual:@""]) {
			UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Username / Password Missing",nil) message:NSLocalizedString(@"Please enter a username and a password in the settings.",nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil] autorelease];
			[alert show];
			return;
		}
		if (![[Reachability sharedReachability] checkInternetConnectionAndDisplayAlert])
			return;
		
		isRefreshing = YES;
		NSArray *daysToSkip = [days allKeys];
		NSArray *weeksToSkip = [weeks allKeys];
		NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:username, @"username", password, @"password", weeksToSkip, @"weeksToSkip", daysToSkip, @"daysToSkip", nil];
		[self performSelectorInBackground:@selector(fetchReportsWithUserInfo:) withObject:userInfo];
	}
}

#pragma mark Table View methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	if (section == 0)
		return 2; //daily + weekly
	else
		return 2; //settings + about
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if (section == 0)
		return NSLocalizedString(@"View Reports",nil);
	else
		return NSLocalizedString(@"Configuration",nil);
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
	int row = [indexPath row];
	int section = [indexPath section];
	if ((row == 0) && (section == 0)) {
		cell.image = [UIImage imageNamed:@"Daily.png"];
		//display trend:
		if ([days count] >= 2) {
			NSSortDescriptor *dateSorter = [[[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO] autorelease];
			NSArray *sortedWeeks = [[days allValues] sortedArrayUsingDescriptors:[NSArray arrayWithObject:dateSorter]];
			Day *lastWeek = [sortedWeeks objectAtIndex:0];
			Day *previousWeek = [sortedWeeks objectAtIndex:1];
			float lastRevenue = [lastWeek totalRevenueInBaseCurrency];
			float previousRevenue = [previousWeek totalRevenueInBaseCurrency];
			float percent = (previousRevenue > 0) ? (lastRevenue / previousRevenue) : 0.0;
			if (percent != 0.0) {
				float diff = percent - 1.0;
				NSNumberFormatter *formatter = [[NSNumberFormatter new] autorelease];
				[formatter setMaximumFractionDigits:1];
				[formatter setMinimumIntegerDigits:1];
				NSString *percentString = [formatter stringFromNumber:[NSNumber numberWithFloat:fabsf(diff)*100]];
				if (diff > 0)
					cell.text = [NSString stringWithFormat:@"%@ (+ %@%%)", NSLocalizedString(@"Daily",nil), percentString];
				else
					cell.text = [NSString stringWithFormat:@"%@ (- %@%%)", NSLocalizedString(@"Daily",nil), percentString];
			}
			else
				cell.text = NSLocalizedString(@"Daily",nil);
		}
		else {
			cell.text = NSLocalizedString(@"Daily",nil);
		}
	}
	else if ((row == 1) && (section == 0)) {
		cell.image = [UIImage imageNamed:@"Weekly.png"];
		if ([weeks count] >= 2) {
			NSSortDescriptor *dateSorter = [[[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO] autorelease];
			NSArray *sortedWeeks = [[weeks allValues] sortedArrayUsingDescriptors:[NSArray arrayWithObject:dateSorter]];
			Day *lastWeek = [sortedWeeks objectAtIndex:0];
			Day *previousWeek = [sortedWeeks objectAtIndex:1];
			float lastRevenue = [lastWeek totalRevenueInBaseCurrency];
			float previousRevenue = [previousWeek totalRevenueInBaseCurrency];
			float percent = (previousRevenue > 0) ? (lastRevenue / previousRevenue) : 0.0;
			if (percent != 0.0) {
				float diff = percent - 1.0;
				NSNumberFormatter *formatter = [[NSNumberFormatter new] autorelease];
				[formatter setMaximumFractionDigits:1];
				[formatter setMinimumIntegerDigits:1];
				NSString *percentString = [formatter stringFromNumber:[NSNumber numberWithFloat:fabsf(diff)*100]];
				if (diff > 0)
					cell.text = [NSString stringWithFormat:@"%@ (+ %@%%)", NSLocalizedString(@"Weekly",nil), percentString];
				else
					cell.text = [NSString stringWithFormat:@"%@ (- %@%%)", NSLocalizedString(@"Weekly",nil), percentString];
			}
			else
				cell.text = NSLocalizedString(@"Weekly",nil);
		}
		else {
			cell.text = NSLocalizedString(@"Weekly",nil);
		}
	}
	else if ((row == 0) && (section == 1)) {
		cell.image = [UIImage imageNamed:@"Settings.png"];
		cell.text = NSLocalizedString(@"Settings",nil);
	}
	else if ((row == 1) && (section == 1)) {
		cell.image = [UIImage imageNamed:@"About.png"];
		cell.text = NSLocalizedString(@"About",nil);
	}
    return cell;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	int row = [indexPath row];
	int section = [indexPath section];
	if ((row == 0) && (section == 0)) {
		[self refreshDayList];
		[self.navigationController pushViewController:daysController animated:YES];
	}
	else if ((row == 1) && (section == 0)) {
		[self refreshWeekList];
		[self.navigationController pushViewController:weeksController animated:YES];
	}
	else if ((row == 0) && (section == 1)) {
		[self.navigationController pushViewController:settingsController animated:YES];
	}
	else if ((row == 1) && (section == 1)) {
		HelpBrowser *browser = [[HelpBrowser new] autorelease];
		[self.navigationController pushViewController:browser animated:YES];
	}
	
	[aTableView deselectRowAtIndexPath:indexPath animated:YES];
}


@end

