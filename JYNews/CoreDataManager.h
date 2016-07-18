//
//  CoreDataManager.h
//  JYNews
//
//  Created by dqh on 16/7/7.
//  Copyright © 2016年 duqianhang. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Calendar;

@interface CoreDataManager : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

//创建单例对象
+ (instancetype)shareManager;
//保存 在主界面进去的时候调用,如果已经存在则不创建
- (void)saveDataWithDate:(NSDate *)date;
//保存新闻读完全部读完之后的状态
- (void)saveDataWithDate:(NSDate *)date withState:(NSInteger)state;
//根据日期来查询数据
- (Calendar *)fetchDayWithDayDate:(NSDate *)dayDate;
//保存数据 在点击单元格之后调用
- (void)saveDataWithDate:(NSDate *)today withState:(NSInteger)state withNumber:(NSInteger)number;
//根据日期来获取当天的新闻数据
- (NSArray *)fectDataWithDate:(NSDate *)date withSate:(NSInteger)state;
//保存当天的新闻
- (void)saveNewsDataWithDate:(NSDate *)date withState:(NSInteger)state withNews:(NSArray *)news;
//查询新闻是否全部读完
- (BOOL)fetchIsAllReadWithDate:(NSDate *)date withState:(NSInteger)state;
//查询单条新闻是否被阅读了
- (BOOL)fetchOneNewsIsBeenRead:(NSDate *)date withState:(NSInteger)state withNumber:(NSInteger)number;
//查询某个时间段多少条新闻被阅读过了
- (NSInteger)fetchTheNumberOfReadWithDate:(NSDate *)date withState:(NSInteger)state;

@end


