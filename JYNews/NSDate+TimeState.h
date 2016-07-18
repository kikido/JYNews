//
//  NSDate+TimeState.h
//  JYNews
//
//  Created by dqh on 16/7/11.
//  Copyright © 2016年 duqianhang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (TimeState)
//返回状态
- (NSInteger)timeState;
//返回01/01  月份/天 的字符串
- (NSString *)numberDate;
//返回monday这样的英文缩写字符串
- (NSString *)numberWeek;
@end
