//
//  NSDate+TimeState.m
//  JYNews
//
//  Created by dqh on 16/7/11.
//  Copyright © 2016年 duqianhang. All rights reserved.
//

#import "NSDate+TimeState.h"

@implementation NSDate (TimeState)

- (NSInteger)timeState {
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSCalendarUnit unit = NSCalendarUnitHour | NSCalendarUnitMinute;
    NSDateComponents *cmp = [calendar components:unit fromDate:self];
    
    if (cmp.hour >= 8 && cmp.hour < 18) {
        //早上
        return 101;
    } else if (cmp.hour >= 18 && cmp.hour < 24){
        //晚上
        return 102;
    } else {
        //前一天晚上
        return 100;
    }
}

- (NSString *)numberDate {
    
    NSDateFormatter *matter = [[NSDateFormatter alloc] init];
    matter.dateFormat = @"MM/dd";
    NSString *string = [matter stringFromDate:self];
    
    return string;
}

- (NSString *)numberWeek {
   
    NSDateFormatter *matter = [[NSDateFormatter alloc] init];
    matter.dateFormat = @"EEE";
    NSString *string = [matter stringFromDate:self];
    
    return string;
    
}


@end









