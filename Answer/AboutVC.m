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
    [self setNavTitle:@"关于图问"];
    
    UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 240)/2.0, 20 + navigationBarHeight, 240, 150)];
    [logoImageView setImage:[UIImage imageNamed:@"180"]];
    [self.view addSubview:logoImageView];
    
    UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10 + navigationBarHeight + 150 + 40, self.view.frame.size.width - 20, 0)];
    
    NSString *contentString = @"图问是由北京卓安志天科技有限公司于2016年创建，为用户提供基于图片问答的社交服务。图问是以用户体验为主旨，以人工智能为核心，旨在研发一款基于图片问答的智能系统。";
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:6.0];//调整行间距
    [paragraphStyle setFirstLineHeadIndent:30];
    [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
    [paragraphStyle setAlignment:NSTextAlignmentJustified];
    NSDictionary *attr1 = @{ NSFontAttributeName:[UIFont systemFontOfSize:15], NSForegroundColorAttributeName:[UIColor blackColor],NSParagraphStyleAttributeName:paragraphStyle };
    
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:contentString];
    [attrString addAttributes:attr1 range:NSMakeRange(0, [attrString length])];

    contentLabel.attributedText = attrString;
    contentLabel.numberOfLines = 0;
    [self.view addSubview:contentLabel];
    
    CGRect rect = [contentString boundingRectWithSize:CGSizeMake(self.view.frame.size.width - 20, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:attr1 context:nil];
    [contentLabel setFrame:CGRectMake(contentLabel.frame.origin.x, contentLabel.frame.origin.y, rect.size.width, rect.size.height)];
    
    UILabel *copyrightLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 50, self.view.frame.size.width, 20)];
    [copyrightLabel setFont:[UIFont systemFontOfSize:12]];
    [copyrightLabel setText:@"Copyright @2016-2016 All Rights Reserved."];
    [copyrightLabel setTextAlignment:NSTextAlignmentCenter];
    [copyrightLabel setTextColor:[UIColor grayColor]];
    [self.view addSubview:copyrightLabel];
    
    UILabel *companyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 30, self.view.frame.size.width, 20)];
    [companyLabel setFont:[UIFont systemFontOfSize:12]];
    [companyLabel setText:@"北京卓安志天科技有限公司"];
    [companyLabel setTextAlignment:NSTextAlignmentCenter];
    [companyLabel setTextColor:[UIColor grayColor]];
    [self.view addSubview:companyLabel];
    
    
    
    
//    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, navigationBarHeight, self.view.frame.size.width, self.view.frame.size.height - navigationBarHeight)];
//    
//    webView.delegate = self;
//    [webView setScalesPageToFit:YES];
//    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@",@"https://www.baidu.com"]];
//    [webView loadRequest:[NSURLRequest requestWithURL:URL]];
//    
//    [self.view addSubview:webView];
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
