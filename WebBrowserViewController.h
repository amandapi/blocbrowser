//
//  WebBrowserViewController.h
//  BlocBrowser
//
//  Created by Amanda Pi on 2015-01-30.
//  Copyright (c) 2015 Bloc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebBrowserViewController : UIViewController
/* Replaces the web view with a fresh one, erasing all history. Also updates the URL field and toolbar buttons appropriately. */
- (void) resetWebView;
@end
