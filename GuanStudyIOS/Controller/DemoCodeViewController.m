//
//  DemoCodeViewController.m
//  StudyiOS
//
//  Created by ZhangYiCheng on 12-12-7.
//  Copyright (c) 2012年 ZhangYiCheng. All rights reserved.
//

#import "DemoCodeViewController.h"

@interface DemoCodeViewController ()
{
    NSString *path_uuid;
    NSString *path_Introduction;
}

@end

@implementation DemoCodeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.webView.delegate = self;
    path_uuid = [[NSBundle mainBundle] pathForResource:self.uuid ofType:@"html"];
    path_Introduction = [[NSBundle mainBundle]pathForResource:self.Introduction ofType:@"html"];
    if (path_uuid) {
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath: path_uuid]]];
    }
    
    if ((![self.Introduction isEqualToString:@""])&&(self.Introduction)) {
        UIBarButtonItem *RightBarButton = [[UIBarButtonItem alloc]initWithTitle:@"简介" style:UIBarButtonItemStyleBordered target:self action:@selector(RightBarButtonAction:)];
        self.navigationItem.rightBarButtonItem = RightBarButton;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [self setWebView:nil];
    [super viewDidUnload];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSURL *requestURL = [request URL];
    if (([[requestURL scheme] isEqualToString: @"http"] || [[requestURL scheme] isEqualToString:@"https"] || [[requestURL scheme] isEqualToString: @"mailto" ])
        && (navigationType == UIWebViewNavigationTypeLinkClicked)) {
        return ![[UIApplication sharedApplication] openURL:requestURL];
    }
    return YES;
}

- (IBAction)RightBarButtonAction:(UIBarButtonItem *)sender {
    if ([sender.title isEqualToString:@"简介"]) {
        [sender setTitle:@"代码"];
        if (path_Introduction) {
            [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath: path_Introduction]]];
        }
    }else{
        [sender setTitle:@"简介"];
        if (path_uuid) {
            [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath: path_uuid]]];
        }

    }
}

@end
