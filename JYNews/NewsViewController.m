//
//  NewsViewController.m
//  JYNews
//
//  Created by dqh on 16/7/4.
//  Copyright © 2016年 duqianhang. All rights reserved.
//

#import "NewsViewController.h"
#import "News.h"
#import "UIImageView+WebCache.h"

static const NSInteger HeadImageHeight = 430;
static const NSInteger HeadImageViewCutOff = 70;

@interface NewsViewController () <UIWebViewDelegate,UIScrollViewDelegate>
{
    UIButton *_backButton;
    UITableView *_tableView;
    CGFloat _oldOffSet;  //偏移量 判断向上还是向下滑动
    UIWebView *_webView;
    UIImageView *_headView;
}

@end

@implementation NewsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self creatWebView];
    [self creatBackButton];
//    [self creatHeadView];
//    [self creatTableView];
    
    
    
    
    self.view.backgroundColor = [UIColor yellowColor];
    // Do any additional setup after loading the view.
}

- (void)creatWebView {
    
    _webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    _webView.scrollView.delegate = self;
//    _webView.scrollView.contentInset = UIEdgeInsetsMake(HeadImageHeight, 0, 0, 0);
    
    NSURL *newsURL = [NSURL URLWithString:self.news.url];
    [_webView loadRequest:[NSURLRequest requestWithURL:newsURL]];
    [self.view addSubview:_webView];
}

- (void)creatHeadView {
    
//    _headView = [[UIImageView alloc] initWithFrame:CGRectMake(0, -HeadImageHeight, KScreenWidth, HeadImageHeight)];
    [_headView sd_setImageWithURL:[NSURL URLWithString:_news.thumbnail_pic_s]];
    [_webView addSubview:_headView];
    
    [self creatHeadViewWithRect:_headView.frame];
    
}

- (void)creatHeadViewWithRect:(CGRect)rect {
    
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0, 0)];
    [path addLineToPoint:CGPointMake(rect.size.width, 0)];
    [path addLineToPoint:CGPointMake(rect.size.width, rect.size.height)];
    [path addLineToPoint:CGPointMake(0, rect.size.height - HeadImageViewCutOff)];
    
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.path = path.CGPath;
    _headView.layer.mask = layer;
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (_webView.scrollView.contentOffset.y < _oldOffSet) {
    
        _backButton.hidden = NO;
    } else {
        
        _backButton.hidden = YES;
    }
    
    _oldOffSet = _webView.scrollView.contentOffset.y;
    
}

#pragma mark 创建返回按钮
- (BOOL)prefersStatusBarHidden {
    
    return YES;
}

- (void)creatBackButton {
    
    _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _backButton.frame = CGRectMake(10, 10, 40, 40);
    _backButton.layer.cornerRadius = 20;
    _backButton.backgroundColor = [UIColor whiteColor];
    [_backButton setImage:[UIImage imageNamed:@"map_return.png"] forState:UIControlStateNormal];
    
    [_backButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_backButton];
}

- (void)backAction {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}





/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
