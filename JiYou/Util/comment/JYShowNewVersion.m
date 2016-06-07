//
//  JYShowNewVersion.m
//  JiYou
//
//  Created by 俊王 on 15/9/29.
//  Copyright © 2015年 JY. All rights reserved.
//

#import "JYShowNewVersion.h"
#import "JYAlterView.h"

#define SECONDS_IN_A_DAY 86400.0
#define SECONDS_IN_A_WEEK 604800.0
#define MAC_APP_STORE_REFRESH_DELAY 5.0
#define REQUEST_TIMEOUT 60.0

//localisation string keys
static NSString *const iLinkMessageTitleKey = @"iLinkMessageTitle";
static NSString *const iLinkAppMessageKey = @"iLinkAppMessage";
static NSString *const iLinkGameMessageKey = @"iLinkGameMessage";
static NSString *const iLinkCancelButtonKey = @"iLinkCancelButton";
static NSString *const iLinkRemindButtonKey = @"iLinkRemindButton";
static NSString *const iLinkUpdateButtonKey = @"iLinkUpdateButton";

static NSString *const iLinkDeclinedVersionKey = @"iLinkDeclinedVersion";
static NSString *const iLinkLastRemindedKey = @"iLinkLastReminded";
static NSString *const iLinkLastVersionUsedKey = @"iLinkLastVersionUsed";
static NSString *const iLinkFirstUsedKey = @"iLinkFirstUsed";

static NSString *const kAppStoreUrlString = @"http://fir.im/jiyou";

@implementation JYShowNewVersion

+ (instancetype)sharedInstance
{
    static JYShowNewVersion *sharedInstance = nil;
    
    if (sharedInstance == nil)
    {
        sharedInstance = [[JYShowNewVersion alloc] init];
    }
    return sharedInstance;
}


- (JYShowNewVersion *)init
{
    self.applicationStoreVersion = nil;
    
    if ((self = [super init]))
    {
        NSString *key = nil;
        
        //application version (use short version preferentially)
        self.applicationVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
        if ([self.applicationVersion length] == 0)
        {
            key = CFBridgingRelease(kCFBundleVersionKey);
            self.applicationVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:key];
        }
        
        //localised application name
        self.applicationName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
        if ([self.applicationName length] == 0)
        {
            key = CFBridgingRelease(kCFBundleNameKey);
            self.applicationName = [[NSBundle mainBundle] objectForInfoDictionaryKey:key];
        }
        
    }
    return self;
}


- (NSString *)localizedStringForKey:(NSString *)key withDefault:(NSString *)defaultString
{
    static NSBundle *bundle = nil;
    if (bundle == nil)
    {
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"JiYou" ofType:@"bundle"];
        
        bundle = [NSBundle bundleWithPath:bundlePath];
        NSString *language = [[NSLocale preferredLanguages] count]? [NSLocale preferredLanguages][0]: @"en";
        if (![[bundle localizations] containsObject:language])
        {
            language = [language componentsSeparatedByString:@"-"][0];
        }
        if ([[bundle localizations] containsObject:language])
        {
            bundlePath = [bundle pathForResource:language ofType:@"lproj"];
        }
        bundle = [NSBundle bundleWithPath:bundlePath] ?: [NSBundle mainBundle];
    }
    defaultString = [bundle localizedStringForKey:key value:defaultString table:nil];
    return [[NSBundle mainBundle] localizedStringForKey:key value:defaultString table:nil];
}

- (NSString *)messageTitle
{
    return [_messageTitle ?: [self localizedStringForKey:iLinkMessageTitleKey withDefault:@"更新 %@"] stringByReplacingOccurrencesOfString:@"%@" withString:self.applicationName];
}

- (NSString *)message
{
    NSString *message = _message;
    if (!message)
    {
        message = [self localizedStringForKey:iLinkAppMessageKey withDefault:@"An update for %@ is available. \nWould you like to update it now?"];    }
    return [message stringByReplacingOccurrencesOfString:@"%@" withString:self.applicationName];
}

- (NSString *)cancelButtonLabel
{
    return _cancelButtonLabel ?: [self localizedStringForKey:iLinkCancelButtonKey withDefault:@"不再提醒"];
}

- (NSString *)updateButtonLabel
{
    return _updateButtonLabel ?: [self localizedStringForKey:iLinkUpdateButtonKey withDefault:@"立即更新"];
}

- (NSString *)remindButtonLabel
{
    return _remindButtonLabel ?: [self localizedStringForKey:iLinkRemindButtonKey withDefault:@"下次提醒"];
}


- (BOOL)shouldPromptForUpdate
{
    if (self.declinedThisVersion) {
        
        return NO;
    }
    else if (self.lastReminded != nil && self.usesPerWeek < 1)
    {
        return NO;
    }
    else if (self.applicationStoreVersion!=nil){
        
        if ([self.applicationStoreVersion compare:self.applicationVersion options:NSNumericSearch] == NSOrderedDescending){ // There is a new version
           
            return YES;
        }
    }

    return NO;//YES;
}


-(void)show
{
    if ([self shouldPromptForUpdate]) {
    
        if (!self.visibleAlert)
        {
            self.titleArray = @[self.updateButtonLabel,self.remindButtonLabel,self.cancelButtonLabel];
            
            JYAlterView *alter = [[JYAlterView alloc] initWithTitle:self.messageTitle
                                                            message:self.message
                                                        buttonArray:self.titleArray
                                                       dismissBlock:^(UIButton *button) {
                
                                                           NSInteger buttonIndex = button.tag;
                                                       
                                                           if (buttonIndex == 2)
                                                           {
                                                               //ignore this version
                                                               self.declinedThisVersion = YES;
                                                               
                                                           }
                                                           else if (buttonIndex == 1)
                                                           {
                                                               //remind later
                                                               self.lastReminded = [NSDate date];
                                                               
                                                           }
                                                           else
                                                           {
                                                               [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kAppStoreUrlString]];
                                                               
                                                               exit(0);
                                                               
                                                           }
                                                           
                                                           //release alert
                                                           self.visibleAlert = nil;

            }];
            
            self.visibleAlert = alter;
            [alter show];
        }
    }
}

- (NSDate *)lastReminded
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:iLinkLastRemindedKey];
}

- (void)setLastReminded:(NSDate *)date
{
    [[NSUserDefaults standardUserDefaults] setObject:date forKey:iLinkLastRemindedKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (CGFloat)usesPerWeek
{
    return ([[NSDate date] timeIntervalSinceDate:self.lastReminded] / SECONDS_IN_A_WEEK);
}

- (BOOL)declinedThisVersion
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:iLinkDeclinedVersionKey] isEqualToString:self.applicationStoreVersion];
}

- (void)setDeclinedThisVersion:(BOOL)declined
{
    [[NSUserDefaults standardUserDefaults] setObject:(declined? self.applicationStoreVersion: nil) forKey:iLinkDeclinedVersionKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
