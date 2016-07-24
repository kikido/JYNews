//
//  MottoViewController.m
//  JYNews
//
//  Created by dqh on 16/7/6.
//  Copyright © 2016年 duqianhang. All rights reserved.
//

#import "MottoViewController.h"
#import "CustomVisualEffectView.h"

@interface MottoViewController ()
{
    CustomVisualEffectView *_effectView;
}

@end

@implementation MottoViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self creatButtons];
    [self creatToolbar];
    [self creatEverDay];
    self.view.backgroundColor = [UIColor greenColor];
}

- (void)creatEverDay {
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSCalendarUnit unit = NSCalendarUnitMonth | NSCalendarUnitDay;
    NSDateComponents *cmp = [calendar components:unit fromDate:[NSDate date]];
    
    NSString *urlString = [NSString stringWithFormat:@"http://api.juheapi.com/japi/toh?key=e261d404a3db52077656c64de46fb87a&v=1.0&month=%ld&day=%ld",cmp.month,cmp.day];
        NSURL * url = [NSURL URLWithString:urlString];
    
    NSURLRequest * request = [[NSURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10];
    NSHTTPURLResponse *response = nil;
    //发送同步请求
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
    //将请求回来的数据转化成数组
    NSArray *array = [NSJSONSerialization JSONObjectWithData:returnData options:NSJSONReadingMutableLeaves error:nil][@"result"];
    NSDictionary *dic = [array firstObject];
    NSString *des = dic[@"des"];
    CGSize size = CGSizeMake(KScreenWidth - 100, 1000);
    NSDictionary *dic1 = @{NSFontAttributeName : [UIFont systemFontOfSize:20]};
    
    CGRect rect = [des boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:dic1 context:nil];
    NSLog(@"ziti %@",des);
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(50, KScreenHeight/2 - 100, KScreenWidth - 100, rect.size.height)];
    label.numberOfLines = 0;
    label.font = [UIFont systemFontOfSize:20];
    label.text = dic[@"des"];
    label.textColor = [UIColor whiteColor];
    [self.view addSubview:label];
    
//    UILabel *headLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 50, KScreenWidth - 100, 40)];
//    headLabel.text = @"历史上的今天";
//    headLabel.font = [UIFont systemFontOfSize:24];
//    headLabel.textColor = [UIColor blackColor];
//    headLabel.textAlignment = NSTextAlignmentCenter;
//    [self.view addSubview:headLabel];
    
}

- (void)creatToolbar {
    
    UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    CGRect frame = CGRectMake(0, KScreenHeight, KScreenWidth, KScreenHeight);
    
    _effectView = [[CustomVisualEffectView alloc] initWithEffect:effect withFrame:frame];
    [self.view addSubview:_effectView];
    
}

- (void)creatButtons {
    //返回按钮
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    leftButton.frame = CGRectMake(10, 20, 30, 30);
    leftButton.layer.cornerRadius = 15;
    [leftButton setImage:[UIImage imageNamed:@"back4.png"] forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:leftButton];
    //日历按钮
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.frame = CGRectMake(KScreenWidth - 40, 10, 30, 30);
    rightButton.layer.cornerRadius = 15;
    [rightButton setImage:[UIImage imageNamed:@"date512*512.png"] forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(timeAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:rightButton];    
    
}

- (void)backAction {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)timeAction {
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionTransitionCurlUp animations:^{
        
        _effectView.transform = CGAffineTransformMakeTranslation(0, -KScreenHeight);
        
    } completion:nil];
}



- (BOOL)prefersStatusBarHidden {
    
    return YES;
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
