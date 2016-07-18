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
    self.view.backgroundColor = [UIColor greenColor];
}

- (void)creatToolbar {
    
    UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    CGRect frame = CGRectMake(0, KScreenHeight, KScreenWidth, KScreenHeight);
    
    _effectView = [[CustomVisualEffectView alloc] initWithEffect:effect withFrame:frame];
    [self.view addSubview:_effectView];
    
}

- (void)creatButtons {
    
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    leftButton.frame = CGRectMake(20, 20, 40, 40);
    leftButton.layer.cornerRadius = 20;
    leftButton.backgroundColor = [UIColor blackColor];
    [leftButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:leftButton];
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.frame = CGRectMake(KScreenWidth - 60, 20, 40, 40);
    rightButton.backgroundColor = [UIColor whiteColor];
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
