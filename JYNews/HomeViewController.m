//
//  HomeViewController.m
//  JYNews
//
//  Created by dqh on 16/6/29.
//  Copyright © 2016年 duqianhang. All rights reserved.
//

#import "HomeViewController.h"
#import "NewsViewController.h"
#import "HomeTableViewCell.h"
#import "MottoViewController.h"
#import "CoreDataManager.h"
#import "Calendar.h"
#import "CustomVisualEffectView.h"
#import "HomeVisualEffectView.h"
#import "NSDate+TimeState.h"
#import "AFNetworking.h"
#import "News.h"
#import "NSObject+YYModel.h"
#import "UIImageView+WebCache.h"
#import "UIViewExt.h"
#import "CustomVisualEffectView.h"
#import "WXRefresh.h"

#define KHeadViewHeight 500
#define KHeadToBeCutOff 70

static NSString * const HomeStateChange = @"HomeStateChange";
static const NSInteger kDistanceFromButtonToCell = 15;

@interface HomeViewController () <UITableViewDelegate,UITableViewDataSource>
{
    UITableView *_tableView;
    UIView *_tableHeadView;
    UIImageView *_headView;
    UILabel *_dateLabel;
    NSArray *_colorArray;               //颜色组
    
    UILabel *_countLabel;               //计数的label
    NSInteger _selectedNumber;          //当前选中的单元格
    UIView *_footView;
    CustomVisualEffectView *_effectView;
    CGFloat _oldOffSet;
    UIButton *_countDownButton;
    HomeVisualEffectView *_homeEffView;
    NSDate *_date;    //当前的时间
    BOOL _isReadArray[8];   //已经阅读过的数组
    BOOL _isAnimationArray[8];    //已经阅读并且执行过动画的数组
    BOOL _isStateAllRead;    //当前时间段的的是否全部读完
    NSInteger _state;    //100代表前一天晚上,101代表白天,102代表晚上
    NSTimer *_timer;    //添加一个计时器,时刻检测当前的状态是白天还是晚上
    NSMutableArray *_newsArray;
    UIScrollView *_scrollView;
    CustomVisualEffectView *_CusEffectView;
    NSInteger _buttonSelect;   //记录选中的button的tag值
    UITableView *_moreTabView;    //更多新闻里面的tableview
    
}

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //先创建当天的数据库
    
    _date = [NSDate date];
    [[CoreDataManager shareManager] saveDataWithDate:_date];
    _state = [_date timeState];
    //创建新闻内容的数据
    [self creatInformation];
    //添加计时器,检测现在是白天还是晚上
    [self creatTimer];
    //添加最下面6边形的那个视图,也就是单元格的最后一个视图
    [self creatFootView];
    //创建单元格
    [self creatTableView];
    //创建日期
    [self creatDateLabel];
    //创建倒计时的那个视图
    [self creatCountDown];
    //创建日历视图
    [self creatToolbar];
    
}

- (void)creatTimer {
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeAction) userInfo:nil repeats:YES];
    _buttonSelect = 100;
    
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
    if (nowHour>=0 && nowHour<=8) {
        
        NSString *string = [NSString stringWithFormat:@"%04ld-%02ld-%02ld 08:00:00",cmp.year,cmp.month,cmp.day];
        aDate = [matter dateFromString:string];
    } else if (nowHour>8 && nowHour<=18) {
        
        NSString *string = [NSString stringWithFormat:@"%04ld-%02ld-%02ld 18:00:00",cmp.year,cmp.month,cmp.day];
        aDate = [matter dateFromString:string];
    } else if (nowHour>18 && nowHour<24) {
        
        
        NSString *string = [NSString stringWithFormat:@"%04ld-%02ld-%02ld 08:00:00",cmp.year,cmp.month,cmp.day+1];
        aDate = [matter dateFromString:string];
    }
    //距离更换的时间
    NSTimeInterval time = [aDate timeIntervalSinceDate:[NSDate date]];
//    NSLog(@"shijian %f",time);
    //因为是double类型的,当它在0到1之间,即代表主题要更换了
    if (time<1 && time >=0) {
        
        if (cmp.hour < 8) {
            //主题变成早上
            _state = 101;
        } else if (cmp.hour > 8) {
            //主题变成晚上
            _state = 102;
        }
        //当状态从白天变更到晚上时,发送一个通知,并且重新加载新闻,然后重新刷新tableview
        [[NSNotificationCenter defaultCenter] postNotificationName:HomeStateChange object:nil];
        //重新加载数据
        [self creatInformation];
        [self creatFootView];
        //刷新单元格
        [_tableView reloadData];
            
    }
}

//右上角的倒计时
- (void)creatCountDown {
    
    _countDownButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _countDownButton.frame = CGRectMake(KScreenWidth - 60, 20, 40, 40);
    _countDownButton.layer.cornerRadius = 20;
    _countDownButton.backgroundColor = [UIColor blackColor];
    [_countDownButton addTarget:self action:@selector(countDownAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_countDownButton];
}
//倒计时界面
- (void)countDownAction {
    
    UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    _homeEffView = [[HomeVisualEffectView alloc] initWithEffect:effect withFrame:self.view.bounds];
    [self.view addSubview:_homeEffView];
    _homeEffView.hidden = YES;
    
    [self creatScrollView];
    
    [UIView transitionWithView:self.view
                      duration:0.5
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        
                        _homeEffView.hidden = NO;
                        
                        
                    } completion:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    //隐藏导航栏
    [super viewWillAppear:YES];
        self.navigationController.navigationBarHidden = YES;
    //创建数字button颜色填充动画
    if (_selectedNumber < 100 || _selectedNumber > 107) {
        
        return;
    }
    
    
//    int j = 0;
//    for (int i = 0; i < 8; i++) {
//        
//        if (_isReadArray[i]) {
//            
//            j++;
//        }
//    }
    _selectedNumber -= 100;
    
    BOOL isRead = [[CoreDataManager shareManager] fetchOneNewsIsBeenRead:_date withState:_state withNumber:_selectedNumber];
    if (!isRead) {
        
        [UIView animateWithDuration:0.3 delay:1 options:UIViewAnimationOptionTransitionNone animations:^{
            
            NSIndexPath *index = [NSIndexPath indexPathForRow:(_selectedNumber) inSection:0];
            HomeTableViewCell *cell = [_tableView cellForRowAtIndexPath:index];
            cell.numberButton.backgroundColor = _colorArray[index.row];
            cell.numberButton.layer.borderWidth = 0;
            [cell.numberButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
            
        } completion:^(BOOL finished){
            
            //更新数据库
            [[CoreDataManager shareManager] saveDataWithDate:_date withState:_state withNumber:_selectedNumber];
            [_tableView reloadData];
        }];
    }
    

    
}
//全部读完之后,动画并且更换tableview的尾视图
- (void)readAll {
    
    
    
    
    
}

- (BOOL)prefersStatusBarHidden {
    
    return YES;
}

- (void)creatFootView {
    
    _selectedNumber = 200;
    
    _footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenWidth)];
    CGFloat basicWith = KScreenWidth / 6;
    CGRect buttonFrame = CGRectZero;
    
    for (int i = 0; i < 8; i++) {
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        buttonFrame.size = CGSizeMake(20, 20);
        button.frame = buttonFrame;
        if (i == 0) {
            
            button.center = CGPointMake(3 * basicWith, basicWith);
        } else if (i == 1) {
            
            button.center = CGPointMake(4.3 * basicWith, 1.6 * basicWith);
        } else if (i == 2) {
            
            button.center = CGPointMake(5 * basicWith, 3 * basicWith);
        } else if (i == 3) {
            
            button.center = CGPointMake(4.3 * basicWith, 4.4 * basicWith);
        } else if (i == 4) {
            
            button.center = CGPointMake(3 * basicWith, 5 * basicWith);
        } else if (i == 5) {
            
            button.center = CGPointMake(1.7 * basicWith, 4.4 * basicWith);
        } else if (i == 6) {
            
            button.center = CGPointMake(basicWith, 3 * basicWith);
        } else if (i == 7) {
            
            button.center = CGPointMake(1.7 * basicWith, 1.6 * basicWith);
        }
        
        button.layer.cornerRadius = 10;
        button.layer.borderWidth = 1;
        button.layer.borderColor = [UIColor lightGrayColor].CGColor;
        button.tag = i + 100;
        [button setTitle:[NSString stringWithFormat:@"%d",i+1] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button setFont:[UIFont systemFontOfSize:12]];
        [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        BOOL isBeenRead = [[CoreDataManager shareManager] fetchOneNewsIsBeenRead:_date withState:_state withNumber:i];
        if (isBeenRead == YES) {
            
            button.backgroundColor = _colorArray[i];
            button.layer.borderWidth = 0;
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            _isAnimationArray[i] = YES;
            
        }
        _footView.backgroundColor = [UIColor blackColor];
        if (_state == 101) {
            _footView.backgroundColor = [UIColor whiteColor];
        }
        
        
        [_footView addSubview:button];
        
    }
    
    UILabel *fixedLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 3 * basicWith, 20)];
    fixedLabel.center = CGPointMake(_footView.center.x, 3 * basicWith - 20);
    fixedLabel.font = [UIFont systemFontOfSize:13];
    fixedLabel.text = @"You've read";
    fixedLabel.tag = 100 + 8;
    fixedLabel.textAlignment = NSTextAlignmentCenter;
    fixedLabel.textColor = [UIColor whiteColor];
    if (_state == 101) {
        
        fixedLabel.textColor = [UIColor blackColor];
    }
    
    [_footView addSubview:fixedLabel];
    
    _countLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 3 * basicWith, 40)];
    _countLabel.center = CGPointMake(_footView.center.x, 3 * basicWith);
    _countLabel.font = [UIFont systemFontOfSize:26];
    _countLabel.textAlignment = NSTextAlignmentCenter;
    _countLabel.textColor = [UIColor whiteColor];
    if (_state == 101) {
        
        _countLabel.textColor = [UIColor blackColor];
    }
    NSInteger numberOfRead = [[CoreDataManager shareManager] fetchTheNumberOfReadWithDate:_date withState:_state];
    _countLabel.text = [NSString stringWithFormat:@"%ld of 8",numberOfRead];
    
    UIButton *calenButton = [UIButton buttonWithType:UIButtonTypeCustom];
    calenButton.frame = CGRectMake(KScreenWidth - 25, 10, 15, 15);
    calenButton.backgroundColor = [UIColor blackColor];
    [calenButton addTarget:self action:@selector(calendarButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [_footView addSubview:calenButton];
    
    [_footView addSubview:_countLabel];
    
}

- (void)buttonAction:(UIButton *)button {
    
    NewsViewController *vc = [[NewsViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
    
    _selectedNumber = button.tag;
    
}

- (CGRect)setTextViewFrame:(NSString *)text {
    
    CGSize size = CGSizeMake(KScreenWidth - 50, 1000);
    NSDictionary *dic = @{NSFontAttributeName : [UIFont systemFontOfSize:24]};
    
    CGRect rect = [text boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil];
    return rect;
}

- (void)creatInformation {
    
    _colorArray = @[[UIColor greenColor],
                    [UIColor colorWithRed:73/255.0 green:159/255.0 blue:128/255.0 alpha:1],
                    [UIColor colorWithRed:119/255.0 green:197/255.0 blue:57/255.0 alpha:1],
                    [UIColor colorWithRed:207/255.0 green:18/255.0 blue:110/255.0 alpha:1],
                    [UIColor colorWithRed:235/255.0 green:115/255.0 blue:18/255.0 alpha:1],
                    [UIColor colorWithRed:237/255.0 green:183/255.0 blue:43/255.0 alpha:1],
                    [UIColor purpleColor],
                    [UIColor cyanColor]
                    ];
    
    NSMutableArray *mArray = [[NSMutableArray alloc] init];
    //先试试看能不能获取到数据库里面保存过得数据,如果不能代表还没保存进去,所以自己进行创建
    NSArray *oldNews = [[CoreDataManager shareManager] fectDataWithDate:_date withSate:_state];
    //没有数据
    if (oldNews == nil) {
        
        if (_state == 101) {
            //创建连接
            NSURL * url = [NSURL URLWithString:@"http://v.juhe.cn/toutiao/index?type=guoji&key=c02ac895f14031dd399d238d26788da7"];
            NSURLRequest * request = [[NSURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10];
            NSHTTPURLResponse * response = nil;
            //发送同步请求
            NSData * returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
            //将请求回来的数据转化成数组
            NSArray *array = [NSJSONSerialization JSONObjectWithData:returnData options:NSJSONReadingMutableLeaves error:nil][@"result"][@"data"];
            //将里面的字典元素用yymodel转化成自定义的变量
            for (NSDictionary *dic in array) {
                
                News *news = [News yy_modelWithJSON:dic];
                [mArray addObject:news];
            }
            
        } else if (_state == 102) {
            //创建连接
            NSURL * url = [NSURL URLWithString:@"http://v.juhe.cn/toutiao/index?type=guonei&key=c02ac895f14031dd399d238d26788da7"];
            NSURLRequest * request = [[NSURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10];
            NSHTTPURLResponse * response = nil;
            //发送同步请求
            NSData * returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
            //将请求回来的数据转化成数组
            NSArray *array = [NSJSONSerialization JSONObjectWithData:returnData options:NSJSONReadingMutableLeaves error:nil][@"result"][@"data"];
            //将里面的字典元素用yymodel转化成自定义的变量
            for (NSDictionary *dic in array) {
                
                News *news = [News yy_modelWithJSON:dic];
                [mArray addObject:news];
            }
        }
        _newsArray = [mArray mutableCopy];
        [[CoreDataManager shareManager] saveNewsDataWithDate:[NSDate date] withState:_state withNews:_newsArray];
        
    } else {
        
        _newsArray = [oldNews copy];
        
    }
    
}

- (void)creatDateLabel {
    
    NSDateFormatter *matter = [[NSDateFormatter alloc] init];
    matter.dateFormat = @"MMM d";
    NSString *string = [matter stringFromDate:_date];
    
    _dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(20,20-KHeadViewHeight+KHeadToBeCutOff, 200, 40)];
    _dateLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:30];
    _dateLabel.text = string;
    _dateLabel.textColor = [UIColor whiteColor];

    [_headView addSubview:_dateLabel];
    [_tableView addSubview:_dateLabel];
    
}

- (void)creatTableView {
    
    _isStateAllRead = [[CoreDataManager shareManager] fetchIsAllReadWithDate:_date withState:_state];
   
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.backgroundColor = [UIColor blackColor];
    if (_state == 101) {
        _tableView.backgroundColor = [UIColor whiteColor];
    }
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    [_tableView registerClass:[HomeTableViewCell class] forCellReuseIdentifier:@"HomeTableViewCell"];
    [self.view addSubview:_tableView];
    //添加上拉刷新
    __weak HomeViewController *weakSelf = self;
    
    [_tableView addInfiniteScrollingWithActionHandler:^{
        
        __strong HomeViewController *strongSelf = weakSelf;
        [strongSelf performSelector:@selector(creatAnotherTableView) withObject:strongSelf afterDelay:2];
        NSLog(@"shangla");
        
    }];
    //添加头视图
    News *news = _newsArray[0];
    NSURL *imageURL = [NSURL URLWithString:news.thumbnail_pic_s];
    _tableView.contentInset = UIEdgeInsetsMake(KHeadViewHeight-KHeadToBeCutOff, 0, 0, 0);
    _headView = [[UIImageView alloc] initWithFrame:CGRectMake(0, -KHeadViewHeight+KHeadToBeCutOff, KScreenWidth, KHeadViewHeight)];
    [_headView sd_setImageWithURL:imageURL];
    [self creatHeadViewWithRect:_headView.frame];
    [_tableView addSubview:_headView];
    
}
#pragma mark 创建更多新闻里面的tableView
- (void)creatAnotherTableView {
    
        _moreTabView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    [self.view addSubview:_moreTabView];
    
    _moreTabView.dataSource = self;
    _moreTabView.delegate = self;
    _moreTabView.rowHeight = 100;
    _moreTabView.tag = 100;
    
    __weak UITableView *weekView = _moreTabView;
    [_moreTabView addPullDownRefreshBlock:^{
        
        __strong UITableView *strongView = weekView;
        [strongView removeFromSuperview];
        
    }];
    
    [_tableView.infiniteScrollingView stopAnimating];
    
    [_moreTabView addInfiniteScrollingWithActionHandler:^{
        
        
    }];
    [_moreTabView registerClass:[HomeTableViewCell class] forCellReuseIdentifier:@"HomeTableViewCell"];

    
    
}



#pragma mark ---UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (tableView.tag == 100) {
        
        return 14;
    }
    
    
    return 9;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView.tag == 100) {
        
        HomeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HomeTableViewCell"];
        
        News *news = _newsArray[indexPath.row + 8];
        NSInteger colorNumber = random() % 8;
        UIColor *color = _colorArray[colorNumber];
        CGRect textFrame = [self setTextViewFrame:news.title];
        [cell addDataWithNews:news withColor:color withTextFrame:textFrame withIndex:indexPath.row];
        
        UIView *view = [[UIView alloc] initWithFrame:cell.frame];
        UIColor *alphaColor = [color colorWithAlphaComponent:0.3];
        cell.titleLabel.textColor = [UIColor whiteColor];
        cell.backgroundColor = [UIColor blackColor];
        
        if (_state == 101) {
            cell.titleLabel.textColor = [UIColor blackColor
                                         ];
            cell.backgroundColor = [UIColor whiteColor];
        }
        view.backgroundColor = alphaColor;
        cell.selectedBackgroundView = view;
        return cell;
    }
    
    
    
    HomeTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell == nil) {
        
        cell = [[HomeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCellStyleDefault"];
    }
    if (indexPath.row == 0) {
        
        cell.bgView.frame = CGRectMake(0, 35, KScreenWidth, 140);
    }
    //自定义最后一个单元格
    if (indexPath.row == 8) {
        
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        if (cell == nil) {
            
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            //如果没有全部读完的话
            if (!_isStateAllRead) {
                
                [cell.contentView addSubview:_footView];
                
//                if (_selectedNumber<0 || _selectedNumber>7) {
//                    
//                    return cell;
//                }

                int j = 0;
                NSMutableArray *mArray = [[NSMutableArray alloc] init];
                for (int i = 0; i < 8; i++) {
                    
                    BOOL read = [[CoreDataManager shareManager] fetchOneNewsIsBeenRead:_date withState:_state withNumber:i];
                    if (read && !_isAnimationArray[i]) {
                        j++;
                        NSLog(@"youshuzi %d",i);
                        [mArray addObject:[NSNumber numberWithInt:i]];
                    } else if (_isReadArray[i]) {
                        j++;
                    }
                }
                
                [NSThread sleepForTimeInterval:0.1];
                NSInteger numberOfRead = [[CoreDataManager shareManager] fetchTheNumberOfReadWithDate:_date withState:_state];
                for (NSNumber *number in mArray) {
                    
                    NSInteger tag = [number intValue] + 100;
                    [UIView animateWithDuration:0.4 delay:1 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                        
                        UIButton *button = [_footView viewWithTag:tag];
                        button.layer.borderWidth = 0;
                        button.backgroundColor = _colorArray[tag - 100];
                        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                        _countLabel.text = [NSString stringWithFormat:@"%ld of 8",numberOfRead];
                        _isAnimationArray[tag-100] = YES;
                        
                        
                    } completion:nil];
                }
                
                [NSThread sleepForTimeInterval:0.1];
                //判断是不是刚全部读完,如果是的话就执行动画
                if (numberOfRead == 8 && !_isStateAllRead) {
                    
                    _isStateAllRead = YES;
                    //更新数据库
                    [[CoreDataManager shareManager] saveDataWithDate:_date withState:_state];
                    
                    for (int i = 0; i < 8; i++) {
                        
                        UIButton *button = [_footView viewWithTag:i + 100];
                        UILabel *label = [_footView viewWithTag:108];
                        
                        
                        [UIView animateWithDuration:1.2 animations:^{
                            button.center = _footView.center;
                            [button setTitle:@"" forState:UIControlStateNormal];
                            label.text = @"";
                            _countLabel.text = @"";
                        } completion:^(BOOL finished) {
                            
                            UIView *view = [self getLastCellView];
                            view.hidden = YES;
                            [cell.contentView addSubview:view];
                            
                            [UIView animateWithDuration:1 delay:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                                
                                
                                view.hidden = NO;
                                
                            } completion:nil];
                            
                        }];
                    }
                    
                }
                
            } else {
                
                UIView *view = [self getLastCellView];
                [cell.contentView addSubview:view];
            }
            
            
        }
        
        
        return cell;
        
    }
    //填充单元格数据部分
    //如果新闻组里面没有对象的话就返回,防止崩溃了
    if (_newsArray.count < 8) {
        
        return cell;
    }
    News *news = _newsArray[indexPath.row];
    UIColor *color = _colorArray[indexPath.row];
    CGRect textFrame = [self setTextViewFrame:news.title];
    [cell addDataWithNews:news withColor:color withTextFrame:textFrame withIndex:indexPath.row];
    cell.titleLabel.textColor = [UIColor whiteColor];
    cell.backgroundColor = [UIColor blackColor];
    if (_state == 101) {
        cell.titleLabel.textColor = [UIColor blackColor];
        cell.backgroundColor = [UIColor whiteColor];
    }
    //如果已经新闻已经被阅读过了,则改变numberi按钮的样式
    BOOL oneHaveRead = [[CoreDataManager shareManager] fetchOneNewsIsBeenRead:_date withState:_state withNumber:indexPath.row];
    
    if (oneHaveRead) {

        cell.numberButton.layer.backgroundColor = color.CGColor;
        [cell.numberButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

    }

    UIView *view = [[UIView alloc] initWithFrame:cell.frame];
    UIColor *alphaColor = [color colorWithAlphaComponent:0.3];
    view.backgroundColor = alphaColor;
    cell.selectedBackgroundView = view;
    
    
    return cell;

}
#pragma mark 全部读完之后的最后一个单元格
- (UIView *)getLastCellView {
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenWidth)];
    view.backgroundColor = [UIColor greenColor];
    
    //第一个label
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(KScreenWidth/4, KScreenWidth/3, KScreenWidth/2, 60)];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = @"DONE";
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:24];
    [view addSubview:label];
    //第二个label
    UILabel *aLabel = [[UILabel alloc] initWithFrame:CGRectMake(KScreenWidth/4, KScreenWidth/3 + 60, KScreenWidth/2, 20)];
    aLabel.textColor = [UIColor whiteColor];
    aLabel.textAlignment = NSTextAlignmentCenter;
    aLabel.text = @"Do you know..?";
    aLabel.font = [UIFont systemFontOfSize:14];
    [view addSubview:aLabel];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(KScreenWidth - 50, 20, 30, 30);
    button.backgroundColor = [UIColor blackColor];
    [button addTarget:self action:@selector(calendarAction) forControlEvents:UIControlEventAllEvents];
    [view addSubview:button];
    
    UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    CGRect frame = CGRectMake(0, KScreenHeight, KScreenWidth, KScreenHeight);
    
    _effectView = [[CustomVisualEffectView alloc] initWithEffect:effect withFrame:frame];
    
    UIButton *calenButton = [UIButton buttonWithType:UIButtonTypeCustom];
    calenButton.frame = CGRectMake(KScreenWidth - 25, 10, 15, 15);
    calenButton.backgroundColor = [UIColor blackColor];
    [calenButton addTarget:self action:@selector(calendarButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [_effectView addSubview:calenButton];
    
    [self.view addSubview:_effectView];
    
    return view;
    
}




- (void)calendarAction {
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionTransitionCurlUp animations:^{
        
        _effectView.transform = CGAffineTransformMakeTranslation(0, -KScreenHeight);
        
    } completion:nil];

}
#pragma mark ---UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 8 && _isStateAllRead) {
        
        MottoViewController *vc = [[MottoViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
        
        return;
        
    } else if (indexPath.row == 8) {
        
        return;
    }
    
    News *news = [[CoreDataManager shareManager] fectDataWithDate:_date withSate:_state][indexPath.row];
    NewsViewController *vc = [[NewsViewController alloc] init];
    vc.news = news;
    
    [self.navigationController pushViewController:vc animated:YES];
    
    if (tableView.tag == 100) {
        
        return;
    }
    
    
    _selectedNumber = indexPath.row + 100;
    
}

- (void)creatHeadViewWithRect:(CGRect)rect {
    

    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0, 0)];
    [path addLineToPoint:CGPointMake(rect.size.width, 0)];
    [path addLineToPoint:CGPointMake(rect.size.width, rect.size.height)];
    [path addLineToPoint:CGPointMake(0, rect.size.height - KHeadToBeCutOff)];

    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.path = path.CGPath;
    _headView.layer.mask = layer;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView.tag == 100) {
        
        News *news = _newsArray[indexPath.row + 8];
        NSString *string = news.title;
        CGRect rect = [self setTextViewFrame:string];
        
        CGFloat height = rect.size.height - 60;
        
        return 120 + height;
    }
    
    if (indexPath.row == 8) {
        
        return KScreenWidth;
    }
    News *news = _newsArray[indexPath.row];
    NSString *string = news.title;
    CGRect rect = [self setTextViewFrame:string];
    
    CGFloat height = rect.size.height - 60;
    
    if (indexPath.row == 0) {
        return 170 + height;
    }
    
    return 140 + height;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (_tableView.contentOffset.y < _oldOffSet) {
        
        _countDownButton.hidden = NO;
    } else {
        
        _countDownButton.hidden = YES;
    }
    
    _oldOffSet = _tableView.contentOffset.y;

    //下拉放大操作
    if (scrollView.contentOffset.y < -KHeadViewHeight+KHeadToBeCutOff) {
        
        CGFloat yOffset = scrollView.contentOffset.y;
        CGFloat scale = yOffset / (KHeadViewHeight-KHeadToBeCutOff);
        _headView.frame =  CGRectMake(-(scale -1)*KScreenWidth/2, yOffset, KScreenWidth *scale, -yOffset+KHeadToBeCutOff);
        _dateLabel.frame = CGRectMake(20, yOffset + 20, 200, 40);
        
        [self creatHeadViewWithRect:_headView.frame];
            
    }
    
    NSLog(@"lashen %f",scrollView.contentSize.height);
    
}
#pragma mark 创建倒计时界面下面的滑动视图,可切换新闻信息
- (void)creatScrollView {
    //1.创建滑动式图
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, KScreenHeight- KScreenHeight / 4, KScreenWidth , KScreenHeight / 4)];
    _scrollView.delegate = self;
    //设置基本数据
    const CGFloat viewWidth = KScreenWidth * 0.4;
    const CGFloat viewHeight = KScreenHeight / 4;
    const CGFloat buttonRadius = (viewWidth - 3*kDistanceFromButtonToCell) / 4;
    //设置Scrollview的属性
    _scrollView.contentSize = CGSizeMake(5*viewWidth , viewHeight);
    _scrollView.scrollEnabled = YES;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.pagingEnabled = NO;
    _scrollView.bounces = NO;
//    _scrollView.backgroundColor = [UIColor redColor];
    //怎么样判断要创建多少个子视图呢
    for (int i = 0; i < 5; i++) {
        
        UIView *firstView = [[UIView alloc] initWithFrame:CGRectZero];
        NSDate *thisDay = [NSDate date];
        NSInteger state = [thisDay timeState];
        if (state == 101) {
            //如果是代表早间新闻的时候
            firstView.frame = CGRectMake(0, 0, viewWidth/2, viewHeight);
            UIButton *firstButton = [UIButton buttonWithType:UIButtonTypeCustom];
            firstButton.frame = CGRectMake(kDistanceFromButtonToCell, 50, 2*buttonRadius, 2*buttonRadius);
            firstButton.layer.cornerRadius = buttonRadius;
            firstButton.tag = 1;
            firstButton.backgroundColor = [UIColor greenColor];
            [firstButton addTarget:self action:@selector(buttonChangedate:) forControlEvents:UIControlEventTouchUpInside];
            //根据tag值来确定是哪个View
            firstView.tag = 0;
            [firstView addSubview:firstButton];
            [_scrollView addSubview:firstView];
        }
        //背景视图,也就是scrollview的一个子视图
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(firstView.width + viewWidth*i, 0, viewWidth, viewHeight)];
        //根据tag值来确定是哪个Bgview
        bgView.tag = i + 1;
        //日期的label
        //今天的日期
        NSDate *today = [NSDate dateWithTimeIntervalSinceNow:-3600 * 24 * (4-i)];
        if (state == 100) {
            
            today = [NSDate dateWithTimeIntervalSinceNow:-3600 * 24 * (5-i)];
        }
        
        UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(3, 0, viewWidth - 10, 15)];
        dateLabel.text = [today numberDate];
        dateLabel.textColor = [UIColor blackColor];
        dateLabel.font = [UIFont fontWithName:@"ArialUnicodeMS" size:16];
        [bgView addSubview:dateLabel];
        //星期几的label
        UILabel *weekLabel = [[UILabel alloc] initWithFrame:CGRectMake(3, 17, viewWidth - 10, 15)];
        weekLabel.text = [today numberWeek];
        weekLabel.textColor = [UIColor darkGrayColor];
        weekLabel.font = [UIFont fontWithName:@"ArialMT" size:13];
        [bgView addSubview:weekLabel];
        //白天按钮
        UIButton *morButton = [UIButton buttonWithType:UIButtonTypeCustom];
        morButton.frame = CGRectMake(kDistanceFromButtonToCell, 50, 2*buttonRadius, 2*buttonRadius);
        morButton.layer.cornerRadius = buttonRadius;
        morButton.tag = 2 * i + 2;
        if (state == 100) {
            
            morButton.tag = 2 * i ;
        }
        [morButton setImage:[UIImage imageNamed:@"o101sun.png"] forState:UIControlStateNormal];
        if (_buttonSelect == morButton.tag) {
            [morButton setImage:[UIImage imageNamed:@"o102sun.png"] forState:UIControlStateNormal];
        }
//        morButton.backgroundColor = [UIColor purpleColor];
        [morButton addTarget:self action:@selector(buttonChangedate:) forControlEvents:UIControlEventTouchUpInside];
        [bgView addSubview:morButton];
        //晚上按钮
        UIButton *eveButton = [UIButton buttonWithType:UIButtonTypeCustom];
        eveButton.frame = CGRectMake(kDistanceFromButtonToCell*2 + 2*buttonRadius, 50, 2*buttonRadius, 2*buttonRadius);
        eveButton.layer.cornerRadius = buttonRadius;
        eveButton.tag = 2 * i + 3;
        if (state == 100) {
            
            eveButton.tag = 2 * i + 1;
        }
        [eveButton setImage:[UIImage imageNamed:@"o101moon.png"] forState:UIControlStateNormal];
        if (_buttonSelect == eveButton.tag) {
            
            [eveButton setImage:[UIImage imageNamed:@"o102moon.png"] forState:UIControlStateNormal];

        }
//        eveButton.backgroundColor = [UIColor yellowColor];
        [eveButton addTarget:self action:@selector(buttonChangedate:) forControlEvents:UIControlEventTouchUpInside];
        [bgView addSubview:eveButton];
        //绘制虚线
        CAShapeLayer *borderLayout = [CAShapeLayer layer];
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:CGPointMake(3, 34)];
        [path addLineToPoint:CGPointMake(3, 50 + 2*buttonRadius)];
        borderLayout.path = path.CGPath;
        borderLayout.lineWidth = 2. / [[UIScreen mainScreen] scale];
        //虚线边框
        borderLayout.lineDashPattern = @[@1, @1];
        //设置颜色
        borderLayout.strokeColor = [UIColor blackColor].CGColor;
        borderLayout.fillColor = [UIColor clearColor].CGColor;
        [bgView.layer addSublayer:borderLayout];

        
        [_scrollView addSubview:bgView];
}
    //创建好之后加载到毛玻璃视图上
    [_homeEffView addSubview:_scrollView];
    
}

- (void)creatToolbar {
    
    UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    CGRect frame = CGRectMake(0, KScreenHeight, KScreenWidth, KScreenHeight);
    
    _CusEffectView = [[CustomVisualEffectView alloc] initWithEffect:effect withFrame:frame];
    [self.view addSubview:_CusEffectView];
    
}

- (void)calendarButtonAction {
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionTransitionCurlUp animations:^{
        
        _CusEffectView.transform = CGAffineTransformMakeTranslation(0, -KScreenHeight);
        
    } completion:nil];

}
//选择切换不同时段的新闻
- (void)buttonChangedate:(UIButton *)button {
    
    NSInteger viewTag = button.tag / 2;
    
    if (button.tag % 2 == 0) {
        //没有余数代表早上
        _state = 101;
        [button setImage:[UIImage imageNamed:@"o102sun.png"] forState:UIControlStateNormal];
        
    } else {
        //有余数代表晚上
        _state = 102;
        [button setImage:[UIImage imageNamed:@"o102moon.png"] forState:UIControlStateNormal];
    }
    NSLog(@"%ld",button.tag);
    NSDate *date = [NSDate date];
    
    _date = [NSDate dateWithTimeInterval:-3600 * 24 * (5 - viewTag) sinceDate:date];
    
    [self creatInformation];
    _isStateAllRead = [[CoreDataManager shareManager] fetchIsAllReadWithDate:_date withState:_state];
    NSLog(@"duwanlemei %d",_isStateAllRead);
    for (int i = 0; i < 8; i++) {
        
        _isAnimationArray[i] = NO;
    }
    //改变视图
    [self creatFootView];
    _tableView.backgroundColor = [UIColor blackColor];
    if (_state == 101) {
        _tableView.backgroundColor = [UIColor whiteColor];
    }
    [_tableView reloadData];
    
    NSDateFormatter *matter = [[NSDateFormatter alloc] init];
    matter.dateFormat = @"MMM d";
    NSString *string = [matter stringFromDate:_date];
    _dateLabel.text = string;
    
    News *news = _newsArray[0];
    NSURL *imageURL = [NSURL URLWithString:news.thumbnail_pic_s];
    [_headView sd_setImageWithURL:imageURL];
    
    //改变按钮的背景图片
    //判断按钮跟上次选中的是不是同一个,如果不是的话要吧上一个选中的图片换回去
    if ((_buttonSelect != button.tag) && _buttonSelect != 100) {
        
        UIButton *secBgView = [_scrollView viewWithTag:_buttonSelect];
        if (_buttonSelect % 2 == 0) {
            //早上
            [secBgView setImage:[UIImage imageNamed:@"o101sun.png"] forState:UIControlStateNormal];
        } else {
            //有余数代表晚上
            [secBgView setImage:[UIImage imageNamed:@"o101moon.png"] forState:UIControlStateNormal];
        }
        
    }
    //将button的tag值赋给_secbutton
    _buttonSelect = button.tag;
    
    
    //将毛玻璃视图移除
    [self performSelector:@selector(removeView) withObject:self afterDelay:0.5];
//    [UIView animateWithDuration:0.5 delay:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
//    
//        [_homeEffView removeFromSuperview];
//    } completion:nil];

    
}

- (void)removeView {
    
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        
        [_homeEffView removeFromSuperview];
    } completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
