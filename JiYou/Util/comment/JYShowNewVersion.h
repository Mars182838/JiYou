//
//  JYShowNewVersion.h
//  JiYou
//
//  Created by 俊王 on 15/9/29.
//  Copyright © 2015年 JY. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JYShowNewVersion : NSObject<UIAlertViewDelegate>

@property (nonatomic, copy) NSString *applicationStoreVersion;

@property (nonatomic, strong) NSArray *titleArray;

@property (nonatomic, strong) id visibleAlert;

//application details - these are set automatically
@property (nonatomic, copy) NSString *applicationName;
@property (nonatomic, copy) NSString *applicationVersion;

//message text, you may wish to customise these
@property (nonatomic, copy) NSString *messageTitle;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, copy) NSString *cancelButtonLabel;
@property (nonatomic, copy) NSString *remindButtonLabel;
@property (nonatomic, copy) NSString *updateButtonLabel;

@property (nonatomic, strong) NSDate *firstUsed;
@property (nonatomic, strong) NSDate *lastReminded;
@property (nonatomic, readonly) CGFloat usesPerWeek;
@property (nonatomic, assign) BOOL declinedThisVersion;
@property (nonatomic, readonly) BOOL declinedAnyVersion;

@property (nonatomic, strong) UIView *showView;

+ (instancetype)sharedInstance;

-(void)show;

@end
