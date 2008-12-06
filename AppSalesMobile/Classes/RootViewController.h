//
//  RootViewController.h
//  AppSalesMobile
//
//  Created by Ole Zorn on 30.10.08.
//  Copyright omz:software 2008. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Day;
@class DaysController;
@class WeeksController;
@class SettingsViewController;

@interface RootViewController : UIViewController {
	
	NSMutableDictionary *days;
	NSMutableDictionary *weeks;
	
	BOOL isRefreshing;
	IBOutlet UIProgressView *progressView;
	IBOutlet DaysController *daysController;
	IBOutlet WeeksController *weeksController;
	IBOutlet SettingsViewController *settingsController;
	IBOutlet UITableView *tableView;
	
	BOOL changeDone;
}

@property (retain) NSMutableDictionary *days;
@property (retain) NSMutableDictionary *weeks;

- (IBAction)downloadReports:(id)sender;
- (void)setProgress:(NSNumber *)progress;
- (void)deleteDay:(Day *)dayToDelete;
- (void)refreshDayList;
- (void)refreshWeekList;
- (void)saveData;
- (NSString *)docPath;

@end
