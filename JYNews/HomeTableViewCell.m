//
//  HomeTableViewCell.m
//  JYNews
//
//  Created by dqh on 16/7/5.
//  Copyright © 2016年 duqianhang. All rights reserved.
//

#import "HomeTableViewCell.h"
#import "News.h"
#import "UIViewExt.h"

@implementation HomeTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    [self creatView];
    return self;
}

- (void)creatView {
    
    _bgView = [[UIView alloc] initWithFrame:self.frame];
    _bgView.backgroundColor = [UIColor clearColor];
    
    _numberButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _numberButton.frame = CGRectMake(10, 10, 24, 24);
    _numberButton.layer.cornerRadius = 12;
    _numberButton.layer.borderWidth = 1;
    [_bgView addSubview:_numberButton];
    
    _categoryLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 8, KScreenWidth - 50, 30)];
    _categoryLabel.font = [UIFont systemFontOfSize:13];
    [_bgView addSubview:_categoryLabel];
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 40, KScreenWidth - 50, 60)];
    _titleLabel.font = [UIFont systemFontOfSize:24];
    _titleLabel.numberOfLines = 0;
    [_bgView addSubview:_titleLabel];
    
//    _sourceLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 110, KScreenWidth - 50, 20)];
//    _sourceLabel.text = @"From:adafafnajknfknf";
//    _sourceLabel.font = [UIFont systemFontOfSize:13];
//    [_bgView addSubview:_sourceLabel];
    
    [self.contentView addSubview:_bgView];
    
}

- (void)addDataWithNews:(News *)news withColor:(UIColor *)color withTextFrame:(CGRect)rect withIndex:(NSInteger)index{
    
    self.categoryLabel.text = news.author_name;
    self.titleLabel.text = news.title;
    self.categoryLabel.textColor = color;
    
    self.titleLabel.frame = rect;
    self.titleLabel.top = self.categoryLabel.bottom;
    self.titleLabel.left = 40;
    
    self.numberButton.layer.borderColor = color.CGColor;
    [self.numberButton setTitleColor:color forState:UIControlStateNormal];
    [self.numberButton setTitle:[NSString stringWithFormat:@"%ld",index+1] forState:UIControlStateNormal];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
