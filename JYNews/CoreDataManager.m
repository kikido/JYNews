//
//  CoreDataManager.m
//  JYNews
//
//  Created by dqh on 16/7/7.
//  Copyright © 2016年 duqianhang. All rights reserved.
//

#import "CoreDataManager.h"
#import "Calendar.h"

@interface CoreDataManager ()

@property (nonatomic, strong) NSDateFormatter *formatter;

@end

@implementation CoreDataManager

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

+ (instancetype)shareManager {
    
    static CoreDataManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        if (manager == nil) {
            
            manager = [[super allocWithZone:NULL] init];
        
        }
    });
    return manager;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    
    return [self shareManager];
}

- (id)copy {
    
    return self;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
    if (_persistentStoreCoordinator == nil) {
        
        _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
        
        NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/myData.sqlite"];
        NSURL *url = [NSURL fileURLWithPath:path];
        NSLog(@"dizhi %@",url);
        [_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:url options:nil error:nil];
    }
    
    return _persistentStoreCoordinator;
}

- (NSManagedObjectModel *)managedObjectModel {
    
    if (_managedObjectModel != nil) {
        
        return _managedObjectModel;
    }
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:url];
    
    return _managedObjectModel;
    
}

- (NSManagedObjectContext *)managedObjectContext {
    
    if (_managedObjectContext != nil) {
        
        return _managedObjectContext;
    }
    NSPersistentStoreCoordinator *psc = self.persistentStoreCoordinator;
    if (psc == nil) {
        
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:psc];
    
    return _managedObjectContext;
}

- (NSDateFormatter *)formatter {
    
    if (_formatter != nil) {
        
        return _formatter;
    }
    _formatter = [[NSDateFormatter alloc] init];
    _formatter.dateFormat = @"yyyy-MM-dd";
    
    return _formatter;
    
}

- (Calendar *)fetchDayWithDayDate:(NSDate *)dayDate {
        
    NSString *string = [self.formatter stringFromDate:dayDate];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Calendar"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"dayDate=%@",string];
    request.predicate = predicate;
    
    NSArray *result = [self.managedObjectContext executeFetchRequest:request error:nil];
    
    return [result firstObject];
    
}

- (void)saveDataWithDate:(NSDate *)date withState:(NSInteger)state {
    
    if (state == 101) {
        //先查询
        //先查询有没有这个数据
        Calendar *calendar = [self fetchDayWithDayDate:date];
        //早上
        calendar.isMorning = @YES;
    } else if (state == 102){
        //先查询
        //先查询有没有这个数据
        Calendar *calendar = [self fetchDayWithDayDate:date];
        //晚上
        calendar.isEvening = @YES;
    } else if (state == 100) {
        //先查询
        //先查询有没有这个数据
        Calendar *calendar = [self fetchDayWithDayDate:[NSDate dateWithTimeInterval:-3600 * 24 sinceDate:date]];
        //晚上
        calendar.isEvening = @YES;
    }
    
    [self.managedObjectContext save:nil];
    
}

- (void)saveDataWithDate:(NSDate *)date {
    //先查询有没有这个数据
    Calendar *hh = [self fetchDayWithDayDate:date];
    
    if (hh == nil) {
        //没有这个数据的时候再进行创建
        Calendar *calendar = [NSEntityDescription insertNewObjectForEntityForName:@"Calendar" inManagedObjectContext:self.managedObjectContext];
        
        calendar.dayDate = [self.formatter stringFromDate:date];
        NSArray *morning = @[@NO,@NO,@NO,@NO,@NO,@NO,@NO,@NO];
        NSArray *evening = @[@NO,@NO,@NO,@NO,@NO,@NO,@NO,@NO];
        
        NSData *da1 = [NSKeyedArchiver archivedDataWithRootObject:morning];
        NSData *da2 = [NSKeyedArchiver archivedDataWithRootObject:evening];
        
        calendar.morningArray = da1;
        calendar.eveningArray = da2;
        
        calendar.isMorning = @NO;
        calendar.isEvening = @NO;
        
        [self.managedObjectContext save:nil];
    }
}

- (void)saveDataWithDate:(NSDate *)today withState:(NSInteger)state withNumber:(NSInteger)number {
    
    Calendar *hh = [self fetchDayWithDayDate:today];
    //state为101代表早上 102代表晚上 100代表前一天晚上
    if (state == 101) {
        //看的早上新闻
        //反序列化 将二进制数据提取成数组
        NSMutableArray *array = [[NSKeyedUnarchiver unarchiveObjectWithData:hh.morningArray] mutableCopy];
        [array replaceObjectAtIndex:number withObject:@YES];
        NSArray *a1 = array;
        //序列化
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:a1];
        hh.morningArray = data;
        
    } else if (state == 102) {
        //看的晚上新闻
        //反序列化
        NSMutableArray *array = [[NSKeyedUnarchiver unarchiveObjectWithData:hh.eveningArray] mutableCopy];
        [array replaceObjectAtIndex:number withObject:@YES];
        NSArray *a1 = array;
        //序列化
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:a1];
        hh.eveningArray = data;
    } else if (state == 100){
        //前一天
        Calendar *c1 = [self fetchDayWithDayDate:[NSDate dateWithTimeInterval:-3600 * 24 sinceDate:today]];
        //晚上新闻
        NSMutableArray *array = [[NSKeyedUnarchiver unarchiveObjectWithData:c1.eveningArray] mutableCopy];
        [array replaceObjectAtIndex:number withObject:@YES];
        NSArray *a1 = array;
        //序列化
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:a1];
        c1.eveningArray = data;
        
    }
    //保存
    [self.managedObjectContext save:nil];
    //移除所有的管理对象
    [self.managedObjectContext refreshAllObjects];
    
}
//按照时间的和晚上还是早上的状态来查询当天的新闻
- (NSArray *)fectDataWithDate:(NSDate *)date withSate:(NSInteger)state {
    NSArray *newsArray = nil;
    //根据state来选择data
    //白天
    if (state == 101) {
        //获取当天的数据
        Calendar *calendar = [self fetchDayWithDayDate:date];
        //获取白天的数据
        NSData *data = calendar.morningNews;
        newsArray = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    } else if (state == 102) {
        //获取当天的数据
        Calendar *calendar = [self fetchDayWithDayDate:date];
        //获取晚上的数据
        NSData *data = calendar.eveningNews;
        newsArray = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    } else if (state == 100){
        //获取前一天的数据
        Calendar *calendar = [self fetchDayWithDayDate:[NSDate dateWithTimeInterval:-3600 * 24 sinceDate:date]];
        //获取晚上的数据
        NSData *data = calendar.eveningNews;
        newsArray = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    
    return newsArray;
}
//查询单条新闻是否被阅读了
- (BOOL)fetchOneNewsIsBeenRead:(NSDate *)date withState:(NSInteger)state withNumber:(NSInteger)number {
    
    BOOL isBeenRead = NULL;
    
    if (state == 101) {
        Calendar *calendar = [self fetchDayWithDayDate:date];
        //早上
        NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithData:calendar.morningArray];
        isBeenRead = [array[number] boolValue];
    } else if (state == 102){
        Calendar *calendar = [self fetchDayWithDayDate:date];
        //晚上
        NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithData:calendar.eveningArray];
        isBeenRead = [array[number] boolValue];
    } else if (state == 100) {
        Calendar *calendar = [self fetchDayWithDayDate:[NSDate dateWithTimeInterval:-3600 * 24 sinceDate:date]];
        //前一天晚上
        NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithData:calendar.eveningArray];
        isBeenRead = [array[number] boolValue];        
    }
    
    return isBeenRead;

}
- (BOOL)fetchIsAllReadWithDate:(NSDate *)date withState:(NSInteger)state {
    
    BOOL isRead = NULL;
    
    if (state == 101) {
        Calendar *calendar = [self fetchDayWithDayDate:date];
        //早上
        isRead = [calendar.isMorning boolValue];
    } else if (state == 102) {
        Calendar *calendar = [self fetchDayWithDayDate:date];
        //晚上
        isRead = [calendar.isEvening boolValue];
    } else if (state == 100) {
        Calendar *calendar = [self fetchDayWithDayDate:[NSDate dateWithTimeInterval:-3600 * 24 sinceDate:date]];
        //前一天晚上
        isRead = [calendar.isEvening boolValue];
    }
    
    return isRead;
}

- (NSInteger)fetchTheNumberOfReadWithDate:(NSDate *)date withState:(NSInteger)state {
    
    NSInteger isRead = 0;
    NSArray *readArray = nil;
    
    if (state == 101) {
        //早上
        Calendar *calendar = [self fetchDayWithDayDate:date];
        readArray = [NSKeyedUnarchiver unarchiveObjectWithData:calendar.morningArray];
    } else if (state == 102) {
        //晚上
        Calendar *calendar = [self fetchDayWithDayDate:date];
        readArray = [NSKeyedUnarchiver unarchiveObjectWithData:calendar.eveningArray];
    } else if (state == 100) {
        //前一天晚上
        Calendar *calendar = [self fetchDayWithDayDate:[NSDate dateWithTimeInterval:-3600 * 24 sinceDate:date]];
        readArray = [NSKeyedUnarchiver unarchiveObjectWithData:calendar.eveningArray];
    }
    //计算有多少个读过的
    for (int i = 0; i < readArray.count; i++) {
        
        if ([readArray[i] boolValue]) {
            
            isRead++;
        }
    }
    
    return isRead;
    
}
//按照时间来保存当天的新闻
- (void)saveNewsDataWithDate:(NSDate *)date withState:(NSInteger)state withNews:(NSArray *)news {
    //获取当天的数据库
    Calendar *calendar = [self fetchDayWithDayDate:date];
    //将数组转化成nsdata
    NSData *newsData = [NSKeyedArchiver archivedDataWithRootObject:news];
    
    if (state == 101) {
        //保存为早上的新闻
        calendar.morningNews = newsData;
    } else if (state == 102) {
        //保存为晚上的新闻
        calendar.eveningNews = newsData;
    }
    //将修改后的数据保存到数据库中
    [self.managedObjectContext save:nil];
    
}

@end












