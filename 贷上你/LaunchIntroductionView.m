//
//  LaunchIntroductionView.m
//  qsd
//
//  Created by mc on 2018/4/20.
//  Copyright © 2018年 jiucangtouzi. All rights reserved.
//

#import "LaunchIntroductionView.h"
static NSString *const kAppVersion = @"appVersion";

@interface LaunchIntroductionView ()<UIScrollViewDelegate>
{
    UIScrollView  *launchScrollView;
    UIPageControl *page;
}
@end
@implementation LaunchIntroductionView

NSArray *images;
BOOL isScrollOut;//在最后一页再次滑动是否隐藏引导页
CGRect enterBtnFrame;
NSString *enterBtnImage ;
static LaunchIntroductionView *launch = nil;
NSString *storyboard;
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
#pragma mark - 创建对象-->>不带button
+(instancetype)sharedWithImages:(NSArray *)imageNames{
    images = imageNames;
    isScrollOut = YES;
    launch = [[LaunchIntroductionView alloc] initWithFrame:CGRectMake(0, 0, kScreen_width, kScreen_height)];
    launch.backgroundColor = [UIColor whiteColor];
    return launch;
}

#pragma mark - 创建对象-->>带button
+(instancetype)sharedWithImages:(NSArray *)imageNames buttonImage:(NSString *)buttonImageName buttonFrame:(CGRect)frame{
    images = imageNames;
    isScrollOut = NO;
    enterBtnFrame = frame;
    enterBtnImage = buttonImageName;
    launch = [[LaunchIntroductionView alloc] initWithFrame:CGRectMake(0, 0, kScreen_width, kScreen_height)];
    launch.backgroundColor = [UIColor whiteColor];
    return launch;
}
#pragma mark - 用storyboard创建的项目时调用，不带button
+ (instancetype)sharedWithStoryboardName:(NSString *)storyboardName images:(NSArray *)imageNames {
    images = imageNames;
    storyboard = storyboardName;
    isScrollOut = YES;
    launch = [[LaunchIntroductionView alloc] initWithFrame:CGRectMake(0, 0, kScreen_width, kScreen_height)];
    launch.backgroundColor = [UIColor whiteColor];
    return launch;
}
#pragma mark - 用storyboard创建的项目时调用，带button
+ (instancetype)sharedWithStoryboard:(NSString *)storyboardName images:(NSArray *)imageNames buttonImage:(NSString *)buttonImageName buttonFrame:(CGRect)frame{
    images = imageNames;
    isScrollOut = NO;
    enterBtnFrame = frame;
    storyboard = storyboardName;
    enterBtnImage = buttonImageName;
    launch = [[LaunchIntroductionView alloc] initWithFrame:CGRectMake(0, 0, kScreen_width, kScreen_height)];
    launch.backgroundColor = [UIColor whiteColor];
    return launch;
}
#pragma mark - 初始化
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addObserver:self forKeyPath:@"currentColor" options:NSKeyValueObservingOptionNew context:nil];
        [self addObserver:self forKeyPath:@"nomalColor" options:NSKeyValueObservingOptionNew context:nil];
        
        UIStoryboard *story;
        if (storyboard) {
            story = [UIStoryboard storyboardWithName:storyboard bundle:nil];
        }
        UIWindow *window = [UIApplication sharedApplication].delegate.window;
        if (story) {
            UIViewController * vc = story.instantiateInitialViewController;
            window.rootViewController = vc;
            [vc.view addSubview:self];
        }else {
            [window.rootViewController.view addSubview:self];
        }
        [self addImages];
       
    }
    return self;
}
#pragma mark - 判断是使用该项目
-(BOOL )isFirstLauch{
   
     //获取当前版本号
     NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
     NSString *currentAppVersion = infoDic[@"CFBundleShortVersionString"];
     //获取上次启动应用保存的appVersion
     NSString *version = [[NSUserDefaults standardUserDefaults] objectForKey:kAppVersion];
     //App首次运行
     if (version == nil || ![version isEqualToString:currentAppVersion]) {
     [[NSUserDefaults standardUserDefaults] setObject:currentAppVersion forKey:kAppVersion];
     [[NSUserDefaults standardUserDefaults] synchronize];
        return YES;
     }else{
        return NO;
     }
//    return YES;
}
#pragma mark - 添加引导页图片
-(void)addImages{
    [self createScrollView];
}
#pragma mark - 创建滚动视图
-(void)createScrollView{
    launchScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kScreen_width, kScreen_height)];
    launchScrollView.showsHorizontalScrollIndicator = NO;
    launchScrollView.bounces = NO;
    launchScrollView.pagingEnabled = YES;
    launchScrollView.delegate = self;
    launchScrollView.contentSize = CGSizeMake(kScreen_width * images.count, kScreen_height);
    [self addSubview:launchScrollView];
    for (int i = 0; i < images.count; i ++) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(i * kScreen_width, 0, kScreen_width, kScreen_height)];
        imageView.image = [UIImage imageNamed:images[i]];
        [launchScrollView addSubview:imageView];
        if (i == images.count - 1) {
            //判断要不要添加button
            if (!isScrollOut) {
                UIButton *enterButton = [[UIButton alloc] initWithFrame:CGRectMake(screenWidth/2-80,screenHeight-130, 160, 80)];
                [enterButton setImage:[UIImage imageNamed:enterBtnImage] forState:UIControlStateNormal];
                [enterButton addTarget:self action:@selector(enterBtnClick) forControlEvents:UIControlEventTouchUpInside];
                [imageView addSubview:enterButton];
                imageView.userInteractionEnabled = YES;
            }
        }
    }
    page = [[UIPageControl alloc] initWithFrame:CGRectMake(0, kScreen_height - 50, kScreen_width, 30)];
    page.numberOfPages = images.count;
//    page.backgroundColor = [UIColor clearColor];
//    page.backgroundColor = [UIColor cyanColor];
    page.currentPage = 0;
    page.defersCurrentPageDisplay = YES;
    [self addSubview:page];
}
#pragma mark - 进入按钮
-(void)enterBtnClick{
    [self hideGuidView];
}
#pragma mark - 隐藏引导页
-(void)hideGuidView{
    [UIView animateWithDuration:0.5 animations:^{
        self.alpha = 0;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"loadLuanch" object:nil];

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self removeFromSuperview];
        });
        
    }];
}
#pragma mark - scrollView Delegate
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    int cuttentIndex = (int)(scrollView.contentOffset.x + kScreen_width/2)/kScreen_width;
    if (cuttentIndex == images.count - 1) {
        if ([self isScrolltoLeft:scrollView]) {
            if (!isScrollOut) {
                return ;
            }
            [self hideGuidView];
        }
    }
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView == launchScrollView) {
        int cuttentIndex = (int)(scrollView.contentOffset.x + kScreen_width/2)/kScreen_width;
        page.currentPage = cuttentIndex;
    }
}
#pragma mark - 判断滚动方向
-(BOOL )isScrolltoLeft:(UIScrollView *) scrollView{
    //返回YES为向左反动，NO为右滚动
    if ([scrollView.panGestureRecognizer translationInView:scrollView.superview].x < 0) {
        return YES;
    }else{
        return NO;
    }
}
#pragma mark - KVO监测值的变化
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    #pragma mark - 注释颜色滑动颜色
    if ([keyPath isEqualToString:@"currentColor"]) {
//        page.currentPageIndicatorTintColor = self.currentColor;
    }
    if ([keyPath isEqualToString:@"nomalColor"]) {
//        page.pageIndicatorTintColor = self.nomalColor;
    }
}

@end
