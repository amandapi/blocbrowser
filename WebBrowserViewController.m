//
//  WebBrowserViewController.m
//  BlocBrowser
//
//  Created by Amanda Pi on 2015-01-30.
//  Copyright (c) 2015 Bloc. All rights reserved.
//

#import "WebBrowserViewController.h"
#import "AwesomeFloatingToolbar.h"

#define kWebBrowserBackString NSLocalizedString(@"Back", @"Back command")
#define kWebBrowserForwardString NSLocalizedString(@"Forward", @"Forward command")
#define kWebBrowserStopString NSLocalizedString(@"Stop", @"Stop command")
#define kWebBrowserRefreshString NSLocalizedString(@"Refresh", @"Reload command")

@interface WebBrowserViewController () <UIWebViewDelegate, UITextFieldDelegate, AwesomeFloatingToolbarDelegate>

@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) AwesomeFloatingToolbar *awesomeToolbar;
@property (nonatomic, assign) NSUInteger frameCount;

@end

@implementation WebBrowserViewController

#pragma mark - UIViewController


- (void)loadView
{
    // override loadView to create a main container to place all subviews
    UIView *mainView = [UIView new];
    
    //Assignment checkpoint Clearing Browser History
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Welcome!", @"Welcome title") message:NSLocalizedString(@"Get excited to use the best web browser ever!", @"Welcome comment") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK, I'am excited!", @"Welcome button title") otherButtonTitles:nil];
    [alert show];
    // End assignment
        
    self.webView = [[UIWebView alloc] init];
    self.webView.delegate = self;
    
    self.textField = [[UITextField alloc] init];
    self.textField.keyboardType = UIKeyboardTypeURL;
    self.textField.returnKeyType = UIReturnKeyDone;
    self.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
    // Assignment #4 - change placeholder text
    // self.textField.placeholder = NSLocalizedString(@"Website URL", @"Placeholder text for web browser URL field");
    self.textField.placeholder = NSLocalizedString(@"Search Google or enter an URL address", @"Placeholder text for web browser URL field");
    self.textField.backgroundColor = [UIColor colorWithWhite:220/255.0f alpha:1];
    self.textField.Delegate = self;
    
    self.awesomeToolbar = [[AwesomeFloatingToolbar alloc] initWithFourTitles:@[kWebBrowserBackString, kWebBrowserForwardString, kWebBrowserStopString, kWebBrowserRefreshString]];
    
    self.awesomeToolbar.delegate = self;
    
    for (UIView *viewToLoad in @[self.webView, self.textField, self.awesomeToolbar]) {
        [mainView addSubview:viewToLoad];
    }
    
    self.view = mainView;
}


- (void)viewDidLoad
    // Do any additional setup after loading the view.
{
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.activityIndicator];
}


- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    // self.webView.frame = self.view.frame; We don't want the webView to fill the main page
  
    // First, calculate some dimensions
    static const CGFloat itemHeight = 50;
    CGFloat width = CGRectGetWidth(self.view.bounds);
    CGFloat browserHeight = CGRectGetHeight(self.view.bounds) - itemHeight;
    
    // Now assign the frames
    self.textField.frame = CGRectMake(0, 0, width, itemHeight);
    self.webView.frame = CGRectMake(0, CGRectGetMaxY(self.textField.frame), width, browserHeight);
    
    if (self.awesomeToolbar.frame.size.height == 0 && self.awesomeToolbar.frame.size.width == 0)
    {
        self.awesomeToolbar.frame = CGRectMake(20, 100, 280, 60);
    }
}


#pragma mark - UITextFieldDelegate


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    NSString *URLString = textField.text;
    
    NSURL *URL = [NSURL URLWithString:URLString];
    
    //Assignment #1 to #3
    NSRange spaceRange = [URLString rangeOfString:@" "];
    
    // if space exists
    if (spaceRange.location != NSNotFound) {
        NSString *stringAdd = [URLString stringByReplacingOccurrencesOfString:@" " withString:@"+"];
        NSString *searchURL = [NSString stringWithFormat:@"http://google.com/search?q=%@", stringAdd];
        URL = [NSURL URLWithString:searchURL];
    }
    
    // if space does not exist
    if (!URL.scheme && spaceRange.location == NSNotFound) {
        URL = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", URLString]];
    }
    
    // load the corresponding URL
    if (URL) {
        NSURLRequest *request = [NSURLRequest requestWithURL:URL];
        [self.webView loadRequest:request];
    }
    
    // Hardware > Home clear all history
    
    return NO;
}


#pragma mark - UIWebViewDelegate


- (void)webViewDidStartLoad:(UIWebView *)webView
{
    self.frameCount++;
    [self updateButtonsAndTitle];
}


- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    self.frameCount--;
    [self updateButtonsAndTitle];
}


- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    if (error.code !=-999) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error") message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
        [alert show];
    }
    [self updateButtonsAndTitle];
    self.frameCount--;
}


#pragma mark - AwesomeFloatingToolbarDelegate


- (void) floatingToolbar:(AwesomeFloatingToolbar *)toolbar didSelectButtonWithTitle:(NSString *)title {
    // assignment checkpoint Adding a New toolbar - replaced statements with definitions
    if ([title isEqual:kWebBrowserBackString]) {
        [self.webView goBack];
    } else if ([title isEqual:kWebBrowserForwardString]) {
        [self.webView goForward];
    } else if ([title isEqual:kWebBrowserStopString]) {
        [self.webView stopLoading];
    } else if ([title isEqual:kWebBrowserRefreshString]) {
        [self.webView reload];
    }
}


- (void) floatingToolbar:(AwesomeFloatingToolbar *)toolbar didTryToPanWithOffset:(CGPoint)offset
{
    CGPoint startingPoint = toolbar.frame.origin;
    // first, we get toolbar's top-left corner after moving to newPoint
    CGPoint newPoint = CGPointMake(startingPoint.x + offset.x, startingPoint.y + offset.y);
    // then, create a new CGRect for the potential toolbar
    CGRect potentialNewFrame = CGRectMake(newPoint.x, newPoint.y, CGRectGetWidth(toolbar.frame), CGRectGetHeight(toolbar.frame));
    // then, test if new rect is contained by old rect
    if (CGRectContainsRect(self.view.bounds, potentialNewFrame)) {
        toolbar.frame = potentialNewFrame;
    }
}


- (void) floatingToolbar:(AwesomeFloatingToolbar *)toolbar didTryToPinchWithScale:(CGFloat)scale
{
    CGRect newFrame = CGRectMake(toolbar.frame.origin.x, toolbar.frame.origin.y, CGRectGetWidth(toolbar.frame) * scale, CGRectGetHeight(toolbar.frame) * scale);
    
    if (CGRectContainsRect(self.view.bounds, newFrame) ) {
        toolbar.frame = newFrame;
    }
}


#pragma mark - Miscellaneous


- (void) updateButtonsAndTitle
{
    NSString *webpageTitle = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
                              
    if (webpageTitle) {
        self.title = webpageTitle;
    } else {
        self.title = self.webView.request.URL.absoluteString;
    }
    
    if (self.frameCount > 0) {
        [self.activityIndicator startAnimating];
    } else {
        [self.activityIndicator stopAnimating];
    }
                              
    [self.awesomeToolbar setEnabled:[self.webView canGoBack] forButtonWithTitle:kWebBrowserBackString];
    [self.awesomeToolbar setEnabled:[self.webView canGoForward] forButtonWithTitle:kWebBrowserForwardString];
    [self.awesomeToolbar setEnabled:self.frameCount > 0 forButtonWithTitle:kWebBrowserStopString];
    [self.awesomeToolbar setEnabled:self.webView.request.URL && self.frameCount == 0 forButtonWithTitle:kWebBrowserRefreshString];

}


- (void) resetWebView
{
    [self.webView removeFromSuperview];
    
    UIWebView *newWebView = [[UIWebView alloc] init];
    newWebView.delegate = self;
    [self.view addSubview:newWebView];
    
    self.webView = newWebView;
    
    self.textField.text = nil;
    [self updateButtonsAndTitle];
}


@end
