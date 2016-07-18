//
//  HomeVisualEffectView.m
//  JYNews
//
//  Created by dqh on 16/7/10.
//  Copyright © 2016年 duqianhang. All rights reserved.
//

#import "HomeVisualEffectView.h"

@interface HomeVisualEffectView () <UIScrollViewDelegate>
{
    UILabel *_label;  //显示倒计时的label
    NSTimer *_timer;  //计时器
    NSInteger _number;
    UIScrollView *_scrollView;
    NSInteger _state;  //暂时的状态
}

@end


@implementation HomeVisualEffectView

- (instancetype)initWithEffect:(UIVisualEffect *)effect withFrame:(CGRect)frame {
    
    self = [super initWithEffect:effect];
    if (self != nil) {
        
        self.frame = frame;
        [self givetime];
        
        _label = [[UILabel alloc] initWithFrame:CGRectMake(KScreenWidth/6 + 10, 0.35*KScreenHeight - 20, 2*KScreenWidth / 3 - 20, 40)];
        _label.text = nil;
        _label.textColor = [UIColor blackColor];
        _label.backgroundColor = [UIColor clearColor];
        [self addSubview:_label];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(KScreenWidth-40, 20, 30, 30);
        button.layer.cornerRadius = 15;
        [button setImage:[UIImage imageNamed:@"back1.png"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(buttonAction) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(givetime) name:@"HomeStateChange" object:nil];
        
        
        
        _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeAction) userInfo:nil repeats:YES];
    }
    
    return self;
    
}



- (void)buttonAction {
    
    [UIView transitionWithView:self.window
                      duration:0.3
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        
                        [self removeFromSuperview];
                        
                        
                        
                    } completion:nil];
    
}

- (void)dealloc {
    
    [_timer invalidate];
    _timer = nil;
}

- (void)timeAction {
    
    NSDate *Date = [NSDate date];
    NSDate *aDate = nil;
    //获取当前时间的day跟hour
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSCalendarUnit unit = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute;
    NSDateComponents *cmp = [calendar components:unit fromDate:Date];
    
    NSDateFormatter *matter = [[NSDateFormatter alloc] init];
    matter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    //    NSDate *aDate = [aMatter dateFromString:string];
    //判断是hour在哪个时间段
    NSInteger nowHour = cmp.hour;
    if (nowHour>=0 && nowHour<8) {
        
        NSString *string = [NSString stringWithFormat:@"%04ld-%02ld-%02ld 08:00:00",cmp.year,cmp.month,cmp.day];
        aDate = [matter dateFromString:string];
    } else if (nowHour>=8 && nowHour<18) {
        
        NSString *string = [NSString stringWithFormat:@"%04ld-%02ld-%02ld 18:00:00",cmp.year,cmp.month,cmp.day];
        aDate = [matter dateFromString:string];
    } else if (nowHour>=18 && nowHour<=24) {
        
        
        NSString *string = [NSString stringWithFormat:@"%04ld-%02ld-%02ld 08:00:00",cmp.year,cmp.month,cmp.day+1];
        aDate = [matter dateFromString:string];
    }
    
    NSTimeInterval time = [aDate timeIntervalSinceDate:[NSDate date]];
    
    NSInteger hour = time / 3600;
    NSInteger min = (time - 3600*hour) / 60;
    NSInteger sec = (time - 3600*hour - 60*min);
    //有属性的文本
    NSMutableAttributedString *timeString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%02ldh %02ldm %02lds", hour, min, sec]];
    [timeString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"ArialUnicodeMS" size:40] range:NSMakeRange(0, 2)];
    [timeString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"ArialUnicodeMS" size:40] range:NSMakeRange(4, 2)];
    [timeString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"ArialUnicodeMS" size:40] range:NSMakeRange(8, 2)];
    
    _label.attributedText = timeString;
    _label.textAlignment = NSTextAlignmentCenter;
    
}

- (void)givetime {
    //底层的layer
    CAShapeLayer *layer = [CAShapeLayer layer];
    //    CGRect rect = CGRectMake(100, 100, 100, 100);
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(KScreenWidth/2, 0.35 * KScreenHeight) radius:KScreenWidth/3 startAngle:0 endAngle:M_PI_4 * 8 clockwise:YES];
    
    layer.path = path.CGPath;
    layer.strokeColor = [UIColor grayColor].CGColor;
    layer.lineWidth = 3;
    layer.fillColor = NULL;
    [self.layer addSublayer:layer];
    //要画圆的那个layer
    CAShapeLayer *alayer = [CAShapeLayer layer];
    alayer.path = path.CGPath;
    alayer.strokeColor = [UIColor blueColor].CGColor;
    alayer.lineWidth = 3;
    alayer.fillColor = NULL;
    alayer.strokeStart = 0;
    alayer.anchorPoint = CGPointMake(1, 1);
//    alayer.position = CGPointMake(0, 200);
    alayer.strokeEnd = 0;
//    alayer.affineTransform = CGAffineTransformMakeRotation(-2*M_PI_4);
    [self.layer addSublayer:alayer];
    
    
    NSInteger totalTime = 0;
    
    NSDate *Date = [NSDate date];
    NSDate *aDate = nil;
    //获取当前时间的day跟hour
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSCalendarUnit unit = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute;
    NSDateComponents *cmp = [calendar components:unit fromDate:Date];
    
    NSDateFormatter *matter = [[NSDateFormatter alloc] init];
    matter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    //判断是hour在哪个时间段
    NSInteger nowHour = cmp.hour;
    if (nowHour>=0 && nowHour<8) {
        
        NSString *string = [NSString stringWithFormat:@"%04ld-%02ld-%02ld 08:00:00",cmp.year,cmp.month,cmp.day];
        aDate = [matter dateFromString:string];
        totalTime = 3600 * 14;
    } else if (nowHour>=8 && nowHour<18) {
        
        NSString *string = [NSString stringWithFormat:@"%04ld-%02ld-%02ld 18:00:00",cmp.year,cmp.month,cmp.day];
        aDate = [matter dateFromString:string];
        totalTime = 3600 * 10;
    } else if (nowHour>=18 && nowHour<=24) {
        
        
        NSString *string = [NSString stringWithFormat:@"%04ld-%02ld-%02ld 08:00:00",cmp.year,cmp.month,cmp.day+1];
        aDate = [matter dateFromString:string];
        totalTime = 3600 * 14;
    }
    
    
    NSTimeInterval time = [aDate timeIntervalSinceDate:[NSDate date]];
    
    CABasicAnimation *pathAnima1 = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    pathAnima1.duration = 2;
    pathAnima1.beginTime = 0;
    pathAnima1.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    pathAnima1.fromValue = [NSNumber numberWithFloat:0.0f];
    pathAnima1.toValue = [NSNumber numberWithFloat:(totalTime - time) / totalTime];
    pathAnima1.fillMode = kCAFillModeForwards;
    pathAnima1.removedOnCompletion = NO;
    [alayer addAnimation:pathAnima1 forKey:@"strokeEndAnimation"];
    
    
    
    CABasicAnimation *pathAnima = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    pathAnima.duration = time;
    pathAnima.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    pathAnima.beginTime = 10.0f + CACurrentMediaTime();
    pathAnima.fromValue = [NSNumber numberWithFloat:(totalTime - time) / totalTime];
    pathAnima.toValue = [NSNumber numberWithFloat:1.0f];
    
    pathAnima.fillMode = kCAFillModeForwards;
    pathAnima.removedOnCompletion = NO;
    [alayer addAnimation:pathAnima forKey:@"strokeEndAnimation"];
    
    CAAnimationGroup *group = [[CAAnimationGroup alloc] init];
    group.duration = time + 2;
    group.animations = @[pathAnima1,pathAnima];
    group.fillMode = kCAFillModeForwards;
    //    group.removedOnCompletion = NO;
    [alayer addAnimation:group forKey:@"group"];
    
    
}

@end
