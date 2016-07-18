//
//  News.m
//  JYNews
//
//  Created by dqh on 16/7/11.
//  Copyright © 2016年 duqianhang. All rights reserved.
//

#import "News.h"

@implementation News

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.title = @"";
        self.date = @"";
        self.category = @"";
        self.author_name = @"";
        self.thumbnail_pic_s = @"";
        self.url = @"";
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.title forKey:@"title"];
    [aCoder encodeObject:self.date forKey:@"date"];
    [aCoder encodeObject:self.category forKey:@"category"];
    [aCoder encodeObject:self.author_name forKey:@"author_name"];
    [aCoder encodeObject:self.thumbnail_pic_s forKey:@"thumbnail_pic_s"];
    [aCoder encodeObject:self.url forKey:@"url"];
    
}
-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if ([self init]) {
        //解压过程
        self.title = [aDecoder decodeObjectForKey:@"title"];
        self.date = [aDecoder decodeObjectForKey:@"date"];
        self.category = [aDecoder decodeObjectForKey:@"category"];
        self.author_name = [aDecoder decodeObjectForKey:@"author_name"];
        self.thumbnail_pic_s = [aDecoder decodeObjectForKey:@"thumbnail_pic_s"];
        self.url =[aDecoder decodeObjectForKey:@"url"];
        
    }
    return self;
}
- (void)setModelWithDictionary:(NSDictionary *)dic {
    
    self.title = dic[@"title"];
    self.date = dic[@"date"];
    self.category = dic[@"category"];
    self.author_name = dic[@"author_name"];
    self.thumbnail_pic_s = dic[@"thumbnail_pic_s"];
    self.url = dic[@"url"];
    
}

@end
