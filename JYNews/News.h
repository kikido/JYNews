//
//  News.h
//  JYNews
//
//  Created by dqh on 16/7/11.
//  Copyright © 2016年 duqianhang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface News : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *date;
@property (nonatomic, copy) NSString *category; //分类
@property (nonatomic, copy) NSString *author_name; //来源
@property (nonatomic, copy) NSString *thumbnail_pic_s; //小图
@property (nonatomic, copy) NSString *url;  //新闻链接

- (void)setModelWithDictionary:(NSDictionary *)dic;

@end
