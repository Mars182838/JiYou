//
//  JYBaseViewController.m
//  JiYou
//
//  Created by 俊王 on 15/8/17.
//  Copyright (c) 2015年 JY. All rights reserved.
//

#import "JYBaseViewController.h"
#import "JYUserModel.h"
#import "JYLoginViewController.h"
@interface JYBaseViewController ()

@property (nonatomic, strong) UILabel * navTitleLabel;

@property (nonatomic, strong) NSArray *itemArray;
@property (nonatomic, strong) id<NSObject> loginObserver;


@end

@implementation JYBaseViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init
{
    if (self = [super init])
    {
        [self setHidesBottomBarWhenPushed:YES];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ApplicationWillEnterForegroundNotification:) name:UIApplicationWillEnterForegroundNotification object:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (IS_IPHONE6) {
        
        self.navBackgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"header_750"]];

    }
    else{
        self.navBackgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"header"]];
    }
    self.leftImage = [UIImage imageNamed:@"back.png"];
    self.rightTitle = @"";
    
  }


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // 防止style改变时来回切换后，状态不变
    self.statusbarStyle = _statusbarStyle;
    
//    if (!self.navigationBarHidden)
//    {
//        [self.view bringSubviewToFront:self.navbar];
//    }
//    [self resetViewLayoutIfNeeded];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    if (self.view.window == nil)
    {
        self.navbar = nil;
        self.navTitleLabel = nil;
        self.navLeftButton = nil;
        self.navRightButton = nil;
    }
}

- (void)resetLeftTitleToFitLongWords
{
    _navTitleLabel.frame = CGRectMake(60, 0, self.view.width - 120, 44);
    _navLeftButton.frame = CGRectMake(0, 0, 60, 44);
    _navRightButton.frame = CGRectMake(0, 0, 60, 44);
}

#pragma mark --
#pragma mark -- action

- (void)navBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)navNext
{
    
}

- (void)resetViewLayoutIfNeeded
{
    
}

- (void)popToViewController:(Class)class
{
    __block UIViewController * vc = nil;
    [self.navigationController.viewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:class])
        {
            vc = obj;
        }
    }];
    if (vc == nil)
    {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    else
    {
        [self.navigationController popToViewController:vc animated:YES];
    }
}

#pragma mark --
#pragma mark -- setter getter

- (UIView *)navbar
{
    if (_navbar == nil)
    {
        _navbar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width,kNavigationBarHeight)];
        _navbar.autoresizingMask=UIViewAutoresizingFlexibleWidth;
//        //添加头部
//        UIImageView * _backImgageView = [[UIImageView alloc] initWithFrame:_navbar.bounds];
//        _backImgageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//        UIImage * image = [UIImage imageNamed:@""];
//        image=[image resizableImageWithCapInsets:UIEdgeInsetsMake(image.size.height-5, 0, 0,0) resizingMode:UIImageResizingModeTile];
//        _backImgageView.image =image;
//        _backImgageView.userInteractionEnabled = YES;
//        [_navbar addSubview:_backImgageView];
        
        [self.view addSubview:_navbar];
    }
    return _navbar;
}

-(void)closeNavBar{
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)creatButtonArray{
    
    if (!_itemArray) {
        
        UIBarButtonItem *item = [UIBarButtonItem appearance];
        
        //设置item普通状态
        NSMutableDictionary *attrs = [NSMutableDictionary dictionary];
        attrs[NSFontAttributeName] = [UIFont systemFontOfSize:17];
        attrs[NSForegroundColorAttributeName] = [UIColor whiteColor];
        [item setTitleTextAttributes:attrs forState:UIControlStateNormal];
        
        UIBarButtonItem *barBtn1 = [[UIBarButtonItem alloc] initWithCustomView:_navLeftButton];
        
        UIBarButtonItem *barBtn2 = [[UIBarButtonItem alloc] initWithTitle:@"关闭"
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(closeNavBar)];
        NSArray *arr = [[NSArray alloc] initWithObjects:barBtn1,barBtn2, nil];
        _itemArray = arr;
    }
    
    self.navigationItem.leftBarButtonItems = _itemArray;
}


- (UILabel *)navTitleLabel
{
    if (_navTitleLabel == nil)
    {
        _navTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.width , 44)];
        _navTitleLabel.backgroundColor = [UIColor clearColor];
        _navTitleLabel.textColor = [UIColor whiteColor];
        _navTitleLabel.textAlignment = NSTextAlignmentCenter;
        _navTitleLabel.font = [UIFont boldSystemFontOfSize:18];
    }
    return _navTitleLabel;
}

- (UIButton *)navLeftButton
{
    if (_navLeftButton == nil)
    {
        _navLeftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _navLeftButton.frame = CGRectMake(0, 0, 40, 44);
        _navLeftButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        _navLeftButton.backgroundColor = [UIColor clearColor];
        _navLeftButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
        _navLeftButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [_navLeftButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_navLeftButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        [_navLeftButton addTarget:self action:@selector(navBack) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_navLeftButton];
    }
    return _navLeftButton;
}

- (UIButton *)navRightButton
{
    if (_navRightButton == nil)
    {
        _navRightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _navRightButton.frame = CGRectMake(0, 0, 40, 44);
        _navRightButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        _navRightButton.backgroundColor = [UIColor clearColor];
        _navRightButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
        _navRightButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [_navRightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_navRightButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        [_navRightButton addTarget:self action:@selector(navNext) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_navRightButton];
    }
    return _navRightButton;
}

- (void)setStatusbarStyle:(JYStatusBarStyle)statusbarStyle
{
    _statusbarStyle = statusbarStyle;
    
    switch (_statusbarStyle)
    {
        case JYStatusBarStyleLight:
            [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent; break;
        case JYStatusBarStyleDark:
        default:
            
            [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault; break;
    }
}

- (void)setNavigationBarHidden:(BOOL)navigationBarHidden
{
    _navigationBarHidden = navigationBarHidden;
    self.navbar.hidden = _navigationBarHidden;
}

- (void)setNavBackgroundColor:(UIColor *)navBackgroundColor
{
    _navBackgroundColor = navBackgroundColor;
    self.navbar.backgroundColor = _navBackgroundColor;
}

- (void)setNavTitle:(NSString *)navtitle
{
    _navTitle = navtitle;
    self.navigationItem.titleView = self.navTitleLabel;
    self.navTitleLabel.text = _navTitle;
}

- (void)setLeftTitle:(NSString *)leftTitle
{
    _leftTitle = leftTitle;
    [self.navLeftButton setTitle:_leftTitle forState:UIControlStateNormal];
    [self.navLeftButton setImage:nil forState:UIControlStateNormal];
}

- (void)setRightTitle:(NSString *)rightTitle
{
    _rightTitle = rightTitle;
    [self.navRightButton setTitle:_rightTitle forState:UIControlStateNormal];
    [self.navRightButton setImage:nil forState:UIControlStateNormal];
}

- (void)setLeftImage:(UIImage *)leftImage
{
    _leftImage = leftImage;
    [self.navLeftButton setImage:_leftImage forState:UIControlStateNormal];
    [self.navLeftButton setTitle:nil forState:UIControlStateNormal];
}

- (void)setRightImage:(UIImage *)rightImage
{
    _rightImage = rightImage;
    [self.navRightButton setImage:_rightImage forState:UIControlStateNormal];
    [self.navRightButton setTitle:nil forState:UIControlStateNormal];
}

#pragma UIApplicationWillEnterForegroundNotification
-(void)ApplicationWillEnterForegroundNotification:(NSNotification*) notification
{
    [self ApplicationWillEnterForeground];
}

- (void)ApplicationWillEnterForeground
{
    
}

@end
