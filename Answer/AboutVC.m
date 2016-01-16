//
//  AboutVC.m
//  Answer
//
//  Created by wuyj on 16/1/6.
//  Copyright © 2016年 wuyj. All rights reserved.
//

#import "AboutVC.h"

@interface AboutVC ()<UIWebViewDelegate>

@end

@implementation AboutVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setNavTitle:@"关于图问圈"];
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, navigationBarHeight, self.view.frame.size.width, self.view.frame.size.height - navigationBarHeight)];
    
    webView.delegate = self;
    [webView setScalesPageToFit:YES];
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@",@"https://www.baidu.com"]];
    [webView loadRequest:[NSURLRequest requestWithURL:URL]];
    
    [self.view addSubview:webView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView  {
    
}


- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    
}

@end
