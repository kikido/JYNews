//
//  HomeTableViewCell.h
//  JYNews
//
//  Created by dqh on 16/7/5.
//  Copyright © 2016年 duqianhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class News;

@interface HomeTableViewCell : UITableViewCell

@property (strong, nonatomic) UIButton *numberButton; //标记
@property (strong, nonatomic) UILabel *categoryLabel; //laiyuan
@property (strong, nonatomic) UILabel *titleLabel; //biaoti
//@property (strong, nonatomic) UILabel *sourceLabel;
@property (strong, nonatomic) UIView *bgView; //beijing

- (void)addDataWithNews:(News *)news withColor:(UIColor *)color withTextFrame:(CGRect)rect withIndex:(NSInteger)index;

@end
