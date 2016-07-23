//
//  CircularLoaderView.h
//  ceshi0718
//
//  Created by dqh on 16/7/18.
//  Copyright © 2016年 duqianhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CircularLoaderView : UIView

@property (nonatomic, strong) CAShapeLayer *circlePathLayer;
@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, assign) CGFloat circleRadius;

- (void)reveal;

@end
