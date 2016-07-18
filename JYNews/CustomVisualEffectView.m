//
//  CustomVisualEffectView.m
//  JYNews
//
//  Created by dqh on 16/7/8.
//  Copyright © 2016年 duqianhang. All rights reserved.
//

#import "CustomVisualEffectView.h"
#import "CoreDataManager.h"
#import "Calendar.h"

@interface CustomVisualEffectView ()
{
    NSInteger _count;
    NSInteger _day;
    NSInteger _month;
    NSArray *_colorArray;
}

@end

@implementation CustomVisualEffectView

- (instancetype)initWithEffect:(UIVisualEffect *)effect withFrame:(CGRect)frame {
    
    self = [super initWithEffect:effect];
    self.frame = frame;
    
    _colorArray = @[[UIColor colorWithRed:197/255.0 green:197/255.0 blue:197/255.0 alpha:1],
                    [UIColor colorWithRed:192/255.0 green:165/255.0 blue:149/255.0 alpha:1],
                    [UIColor colorWithRed:216/255.0 green:205/255.0 blue:214/255.0 alpha:1],
                    [UIColor colorWithRed:208/255.0 green:157/255.0 blue:26/255.0 alpha:1],
                    [UIColor colorWithRed:151/255.0 green:171/255.0 blue:196/255.0 alpha:1],
                    [UIColor colorWithRed:39/255.0 green:80/255.0 blue:145/255.0 alpha:1],
                    [UIColor colorWithRed:172/255.0 green:23/255.0 blue:32/255.0 alpha:1],
                    [UIColor colorWithRed:217/255.0 green:225/255.0 blue:95/255.0 alpha:1],
                    [UIColor colorWithRed:129/255.0 green:173/255.0 blue:135/255.0 alpha:1],
                    [UIColor colorWithRed:231/255.0 green:130/255.0 blue:47/255.0 alpha:1],
                    [UIColor colorWithRed:194/255.0 green:192/255.0 blue:171/255.0 alpha:1],
                    [UIColor colorWithRed:133/255.0 green:168/255.0 blue:180/255.0 alpha:1],
                    [UIColor colorWithRed:168/255.0 green:147/255.0 blue:173/255.0 alpha:1],
                    ];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(10, KScreenHeight/6, KScreenWidth-20, 2 * KScreenHeight /3)];
    view.backgroundColor = [UIColor whiteColor];
    [self addSubview:view];
    //创建返回按钮
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(KScreenWidth/2 - 10, KScreenHeight - 40, 20, 20);
    backButton.layer.cornerRadius = 10;
    backButton.backgroundColor = [UIColor redColor];
    [backButton addTarget:self action:@selector(backAction1) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:backButton];
    
    //创建文字部分
    UILabel *readLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, KScreenWidth-60, 30)];
    readLabel.text = @"What You've Read";
    readLabel.textAlignment = NSTextAlignmentCenter;
    readLabel.font = [UIFont systemFontOfSize:20];
    [view addSubview:readLabel];
    //
    CGFloat dieWidth = 8;
    CGFloat layerRadius = 4;
    CGFloat liveWidth = (0.75 * (KScreenWidth - 20) - layerRadius*8 - dieWidth*4 - 40*2 - 30*2)/3;
   //
    

//    CGFloat explainWidth = 2 * (KScreenWidth - 20) / 3 / 4;
    for (int i = 0; i < 4; i++) {
        
        if (i == 0) {
            
            CGPoint exCenter = CGPointMake((KScreenWidth - 20)/8 + layerRadius, 60);
    
            CAShapeLayer *layer = [CAShapeLayer layer];
            UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:exCenter radius:4 startAngle:3 * M_PI_4 endAngle:7 * M_PI_4 clockwise:YES];
            path.lineCapStyle = kCGLineCapRound;
            path.lineJoinStyle = kCGLineJoinRound;
            layer.fillColor = [UIColor grayColor].CGColor;
            layer.path = path.CGPath;
            [view.layer addSublayer:layer];
            //再给他加个圆框
            UIBezierPath *aPath = [UIBezierPath bezierPathWithArcCenter:exCenter radius:4 startAngle:-M_PI_4 endAngle:7 * M_PI_4 clockwise:YES];
            aPath.lineCapStyle = kCGLineCapRound;
            aPath.lineJoinStyle = kCGLineJoinRound;
            CAShapeLayer *aLayer = [CAShapeLayer layer];
            aLayer.strokeColor = [UIColor grayColor].CGColor;
            aLayer.path = aPath.CGPath;
            aLayer.fillColor = NULL;
            [view.layer addSublayer:aLayer];
            //添加label说明
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(exCenter.x + layerRadius + dieWidth, 52, 40, 15)];
            label.text = @"Morning";
            label.font = [UIFont systemFontOfSize:10];
            label.textColor = [UIColor grayColor];
            [view addSubview:label];
            
        } else if (i == 1) {
            
            CGPoint exCenter = CGPointMake((KScreenWidth - 20)/8 + layerRadius*(2*i + 1) + dieWidth*i + liveWidth*i + 40 , 60);
            
            CAShapeLayer *layer = [CAShapeLayer layer];
            UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:exCenter radius:4 startAngle:-1 * M_PI_4 endAngle:3 * M_PI_4 clockwise:YES];
            path.lineCapStyle = kCGLineCapRound;
            path.lineJoinStyle = kCGLineJoinRound;
            layer.fillColor = [UIColor grayColor].CGColor;
            layer.path = path.CGPath;
            [view.layer addSublayer:layer];
            //再给他加个圆框
            UIBezierPath *aPath = [UIBezierPath bezierPathWithArcCenter:exCenter radius:4 startAngle:-M_PI_4 endAngle:7 * M_PI_4 clockwise:YES];
            aPath.lineCapStyle = kCGLineCapRound;
            aPath.lineJoinStyle = kCGLineJoinRound;
            CAShapeLayer *aLayer = [CAShapeLayer layer];
            aLayer.strokeColor = [UIColor grayColor].CGColor;
            aLayer.path = aPath.CGPath;
            aLayer.fillColor = NULL;
            [view.layer addSublayer:aLayer];
            //添加label说明
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(exCenter.x + layerRadius + dieWidth, 52, 40, 15)];
            label.text = @"Evening";
            label.font = [UIFont systemFontOfSize:10];
            label.textColor = [UIColor grayColor];
            [view addSubview:label];
            
        }else if (i == 2) {
            
            CGPoint exCenter = CGPointMake((KScreenWidth - 20)/8 + layerRadius*(2*i + 1) + dieWidth*i + liveWidth*i + 40*i , 60);
            
            CAShapeLayer *layer = [CAShapeLayer layer];
            UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:exCenter radius:4 startAngle:-M_PI_4 endAngle:7 * M_PI_4 clockwise:YES];
            path.lineCapStyle = kCGLineCapRound;
            path.lineJoinStyle = kCGLineJoinRound;
            layer.fillColor = [UIColor grayColor].CGColor;
            layer.path = path.CGPath;
            [view.layer addSublayer:layer];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(exCenter.x + layerRadius + dieWidth, 52, 30, 15)];
            label.text = @"Both";
            label.font = [UIFont systemFontOfSize:10];
            label.textColor = [UIColor grayColor];
            [view addSubview:label];
        } else if (i == 3) {
            
            CGPoint exCenter = CGPointMake((KScreenWidth - 20)/8 + layerRadius*(2*i + 1) + dieWidth*i + liveWidth*i + 40*2 + 26 , 60);
            
            CAShapeLayer *layer = [CAShapeLayer layer];
            UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:exCenter radius:4 startAngle:-M_PI_4 endAngle:7 * M_PI_4 clockwise:YES];
            path.lineCapStyle = kCGLineCapRound;
            path.lineJoinStyle = kCGLineJoinRound;
            layer.fillColor = NULL;
            layer.path = path.CGPath;
            layer.strokeColor = [UIColor grayColor].CGColor;
            [view.layer addSublayer:layer];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(exCenter.x + layerRadius + dieWidth, 52, 30, 15)];
            label.text = @"None";
            label.font = [UIFont systemFontOfSize:10];
            label.textColor = [UIColor grayColor];
            [view addSubview:label];
        }
        
        
    }
    
    
    //创建日历部分
    CGFloat layerWidth = (KScreenWidth - 30 * 6 - 30) / 7;
    CGFloat layerHeight = (KScreenHeight * 2/5 - 30) / 4;
    CGFloat calendarHeight = KScreenHeight / 6;
    
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:3600 * 24 * 0];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSCalendarUnit unit = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute;
    NSDateComponents *nowCmp = [calendar components:unit fromDate:date];
    
    _day = nowCmp.day;
    _month = nowCmp.month;
    _count = 0;
    
    NSInteger timeInterval = 0;

    for (int i = 0; i < 5; i++) {
        for (int j = 0; j < 6; j++) {
            
            NSInteger colorNumber = random() % (_colorArray.count);
            UIColor *color = _colorArray[colorNumber];
            
            if (i == 0 && j == 0) {
                //这里是第一个视图 月份
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(layerWidth + j * (30 + layerWidth), calendarHeight + layerHeight*i, 50, 30)];
                label.text = [self trasformMonth:_month];
                
                [view addSubview:label];
            } else if (_day == 0) {
                //这里是后面的月份
                _day = [self changeTheDay:_month];
                _month--;
                //如果月份变成0的话赋值成12
                if (_month == 0) {
                    
                    _month = 12;
                }
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(layerWidth + j * (30 + layerWidth), calendarHeight + layerHeight*i, 50, 30)];
                label.text = [self trasformMonth:_month];
                
                [view addSubview:label];
                
                
            } else {
                //这里才是普通的圈圈
                NSDate *viewDate = [NSDate dateWithTimeIntervalSinceNow: - 3600 * 24 * timeInterval];
                Calendar *viewCal = [[CoreDataManager shareManager] fetchDayWithDayDate:viewDate];
                BOOL isMorning = [viewCal.isMorning boolValue];
                BOOL isEvening = [viewCal.isEvening boolValue];

                CGPoint center = CGPointMake(layerWidth + 15 + j * (30 + layerWidth), calendarHeight + 15 + layerHeight*i);
                CAShapeLayer *layer = [CAShapeLayer layer];
                
                if ((viewCal == nil) || (!isMorning && !isEvening)) {
                    //数据库没有当天的数据或者有数据可是早上跟晚上都没读
                    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center radius:15 startAngle:-M_PI_4 endAngle:7 * M_PI_4 clockwise:YES];
                    path.lineCapStyle = kCGLineCapRound;
                    path.lineJoinStyle = kCGLineJoinRound;
                    layer.strokeColor = color.CGColor;
                    layer.fillColor = NULL;
                    layer.path = path.CGPath;
                    
                } else if (isMorning && !isEvening) {
                    //早上读了,晚上没有读
                    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center radius:15 startAngle:3 * M_PI_4 endAngle:7 * M_PI_4 clockwise:YES];
                    path.lineCapStyle = kCGLineCapRound;
                    path.lineJoinStyle = kCGLineJoinRound;
                    layer.fillColor = color.CGColor;
                    layer.path = path.CGPath;
                    //再给他加个圆框
                    UIBezierPath *aPath = [UIBezierPath bezierPathWithArcCenter:center radius:15 startAngle:-M_PI_4 endAngle:7 * M_PI_4 clockwise:YES];
                    aPath.lineCapStyle = kCGLineCapRound;
                    aPath.lineJoinStyle = kCGLineJoinRound;
                    CAShapeLayer *aLayer = [CAShapeLayer layer];
                    aLayer.strokeColor = color.CGColor;
                    aLayer.path = aPath.CGPath;
                    aLayer.fillColor = NULL;
                    [view.layer addSublayer:aLayer];
                    
                    
                } else if (!isMorning && isEvening) {
                    //早上没有读,晚上读了
                    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center radius:15 startAngle:-M_PI_4 endAngle:3 * M_PI_4 clockwise:YES];
                    path.lineCapStyle = kCGLineCapRound;
                    path.lineJoinStyle = kCGLineJoinRound;
                    layer.fillColor = color.CGColor;
                    layer.path = path.CGPath;
                    //再给他加个圆框
                    UIBezierPath *aPath = [UIBezierPath bezierPathWithArcCenter:center radius:15 startAngle:-M_PI_4 endAngle:7 * M_PI_4 clockwise:YES];
                    aPath.lineCapStyle = kCGLineCapRound;
                    aPath.lineJoinStyle = kCGLineJoinRound;
                    CAShapeLayer *aLayer = [CAShapeLayer layer];
                    aLayer.strokeColor = color.CGColor;
                    aLayer.path = aPath.CGPath;
                    aLayer.fillColor = NULL;
                    [view.layer addSublayer:aLayer];
                    
                } else if (isMorning && isEvening) {
                   //早上跟晚上都读了
                    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center radius:15 startAngle:-M_PI_4 endAngle:7 * M_PI_4 clockwise:YES];
                    path.lineCapStyle = kCGLineCapRound;
                    path.lineJoinStyle = kCGLineJoinRound;
                    layer.fillColor = color.CGColor;
                    layer.path = path.CGPath;
                }
                
                
                //圈圈下面的日期数字,不知道怎么用drawinrect这个方法所以只能用比较占资源的label了
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(layerWidth + j * (30 + layerWidth), calendarHeight + 30 + i*layerHeight, 30, 10)];
                label.text = [NSString stringWithFormat:@"%ld",_day];
                label.textAlignment = NSTextAlignmentCenter;
                label.font = [UIFont systemFontOfSize:10];
                label.textColor = color;
                [view addSubview:label];
                
                _day--;
                timeInterval++;
                
                
                [view.layer addSublayer:layer];
            
            }
            
            
            
            
        }
    }
    
    return self;

}


- (void)backAction1 {
    
    [UIView animateWithDuration:0.3 animations:^{
        
        self.transform = CGAffineTransformIdentity;
    }];
}

- (NSString *)trasformMonth:(NSInteger)month {
    
    switch (month) {
        case 1:
            return @"JAN  |";
            break;
            
        case 2:
            return @"FEB  |";
            break;
            
        case 3:
            return @"MAR  |";
            break;
            
        case 4:
            return @"APR  |";
            break;
            
        case 5:
            return @"MAY  |";
            break;
            
        case 6:
            return @"JUN  |";
            break;
            
        case 7:
            return @"JUL  |";
            break;
            
        case 8:
            return @"AUG  |";
            break;
            
        case 9:
            return @"SEP  |";
            break;
            
        case 10:
            return @"OCT  |";
            break;
            
        case 11:
            return @"NOV  |";
            break;
            
        case 12:
            return @"DEC  |";
            break;
            
        default:
            break;
    }
    return nil;
    
}

- (NSInteger)changeTheDay:(NSInteger)month {
    
    switch (month) {
        case 1:
            return 31;
            break;
            
        case 2:
            return 28;
            break;
            
        case 3:
            return 31;
            break;
            
        case 4:
            return 30;
            break;
            
        case 5:
            return 31;
            break;
            
        case 6:
            return 30;
            break;
            
        case 7:
            return 31;
            break;
            
        case 8:
            return 31;
            break;
            
        case 9:
            return 30;
            break;
            
        case 10:
            return 31;
            break;
            
        case 11:
            return 30;
            break;
            
        case 12:
            return 31;
            break;
            
        default:
            break;
    }
    return 0;

    
    
}

@end
