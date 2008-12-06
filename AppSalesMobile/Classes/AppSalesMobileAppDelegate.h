//
//  AppSalesMobileAppDelegate.h
//  AppSalesMobile
//
//  Created by Ole Zorn on 30.10.08.
//  Copyright omz:software 2008. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppSalesMobileAppDelegate : NSObject <UIApplicationDelegate> {
    
    UIWindow *window;
    UINavigationController *navigationController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

@end

