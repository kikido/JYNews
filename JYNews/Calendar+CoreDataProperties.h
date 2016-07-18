//
//  Calendar+CoreDataProperties.h
//  JYNews
//
//  Created by dqh on 16/7/12.
//  Copyright © 2016年 duqianhang. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Calendar.h"

NS_ASSUME_NONNULL_BEGIN

@interface Calendar (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *dayDate;      //日期 也是主键
@property (nullable, nonatomic, retain) NSData *eveningArray;   //记录晚上读了哪几条新闻
@property (nullable, nonatomic, retain) NSData *eveningNews;    //晚上的新闻
@property (nullable, nonatomic, retain) NSNumber *isEvening;    //记录早上的新闻是否都读完了
@property (nullable, nonatomic, retain) NSNumber *isMorning;    //记录早上的新闻是否都读完了
@property (nullable, nonatomic, retain) NSData *morningArray;   //记录早上读了那几条新闻
@property (nullable, nonatomic, retain) NSData *morningNews;    //早上的新闻

@end

NS_ASSUME_NONNULL_END
