//
//  JYBaseViewController.h
//  JiYou
//
//  Created by 俊王 on 15/8/17.
//  Copyright (c) 2015年 JY. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum

{
    JYStatusBarStyleLight = 0,
    JYStatusBarStyleDark
    
}JYStatusBarStyle;

@interface JYBaseViewController : UIViewController

@property (nonatomic) JYStatusBarStyle statusbarStyle;
@property (nonatomic) BOOL navigationBarHidden;
@property (nonatomic, strong) UIColor * navBackgroundColor;
@property (nonatomic, strong) UIImageView* backgroundView;
@property (nonatomic, strong) NSString * navTitle;
@property (nonatomic, strong) NSString * leftTitle;
@property (nonatomic, strong) NSString * rightTitle;
@property (nonatomic, strong) UIImage * leftImage;
@property (nonatomic, strong) UIImage * rightImage;
@property (nonatomic, strong) UIView * navbar;

@property (nonatomic) BOOL isButtonArray;

@property (nonatomic, strong) UIButton * navLeftButton;
@property (nonatomic, strong) UIButton * navRightButton;

-(void)creatButtonArray;

- (void)navBack;
- (void)navNext;
- (void)resetViewLayoutIfNeeded; // 在设置navbar以后，可能需要有特殊需求重置视图层级，复写该方法，默认不做任何事
- (void)popToViewController:(Class)class;
- (void)resetLeftTitleToFitLongWords;

@end
