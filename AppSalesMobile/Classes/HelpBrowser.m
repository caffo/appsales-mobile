//
//  HelpBrowser.m
//  Newsstand
//
//  Created by Ole Zorn on 03.09.08.
//  Copyright 2008 omz:software. All rights reserved.
//

#import "HelpBrowser.h"


@implementation HelpBrowser

@synthesize webView;

- (void)loadView
{
	self.view = [[[UIWebView alloc] initWithFrame:CGRectMake(0,0,320,480)] autorelease];
	self.webView = (UIWebView *)self.view;
	self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	self.webView.scalesPageToFit = NO;
	
	self.title = NSLocalizedString(@"About AppSales", nil);
	
	NSString *helpPath = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html" inDirectory:@"help"];
	NSURL *helpURL = [NSURL fileURLWithPath:helpPath];
	[self.webView loadRequest:[NSURLRequest requestWithURL:helpURL]];
}

- (void)dealloc 
{
	self.webView = nil;	
	[super dealloc];
}


@end
