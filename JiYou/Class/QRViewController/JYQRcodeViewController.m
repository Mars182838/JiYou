//
//  JYQRcodeViewController.m
//  JiYou
//
//  Created by 俊王 on 15/8/17.
//  Copyright (c) 2015年 JY. All rights reserved.
//

#import "JYQRcodeViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>
#import "JYQRViewController.h"
#import "BKCustomProgressHUD.h"
#import "JYSettingViewController.h"
#import "VPImageCropperViewController.h"
#import "JYMyExchangeViewController.h"
#import "JYAccountViewController.h"
#import "JYExchangeDetailViewController.h"
#import "JYLoginViewController.h"
#import "UIImageView+WebCache.h"
#import "JYBuyViewController.h"
#import "JYUserModel.h"
#import "JYUploadProtraitImageNetworking.h"
#import "MD5.h"
#import "JYGuidanceView.h"
#import "NSNumber+BKAddition.h"
#import "NSString+Additions.h"
#import <pop/POP.h>
#import "JYShowPhotoViewController.h"
#import "UIImage-Helpers.h"
#import "YJNavigationController.h"
#import "UIGestureRecognizer+BlocksKit.h"
#import "JYShowNewVersion.h"
#import "JYNewBuyViewController.h"
#import "JYMobileAddressController.h"
#import "JYWebViewController.h"
#import "JYShakeModel.h"
#import "JYChooseViewController.h"
#import "WXApi.h"

#define ORIGINAL_MAX_WIDTH 2*kScreenWidth

#define FirstUpdate @"update"

#define WORKSTATUS @"00"

#import "JYShakeViewController.h"

@interface JYQRcodeViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate, VPImageCropperDelegate,UIGestureRecognizerDelegate,WXApiDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *portraitImageView;

@property (weak, nonatomic) IBOutlet UIImageView *homeImageView;
@property (weak, nonatomic) IBOutlet UIView *scanView;

@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;//用户名
@property (weak, nonatomic) IBOutlet UILabel *accountLabel;//积分
@property (weak, nonatomic) IBOutlet UILabel *accountNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalConsumeLabel;//消费次数
@property (weak, nonatomic) IBOutlet UILabel *totalNameLabel;

@property (weak, nonatomic) IBOutlet UIButton *addressBtn;

@property (nonatomic, strong) UIView *customView;

@property (strong, nonatomic) JYGuidanceView *guidance;

@property(nonatomic, strong) NSMutableData *mdata;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scantopViewConstraint;

@property (nonatomic, strong) JYShakeModel *shakeModel;

- (IBAction)openQR:(id)sender;

- (IBAction)editButtonClick:(id)sender;

- (IBAction)addressButtonClick:(id)sender;

- (IBAction)myAccountButttonClick:(id)sender;

- (IBAction)consumeButtonClick:(id)sender;

- (IBAction)showWebViewClick:(id)sender;

- (IBAction)showIntegralClick:(id)sender;

@end

@implementation JYQRcodeViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];

    self.navTitle = @"积友";
    self.leftImage = nil;
    self.navigationBarHidden = YES;
    
    __block JYQRcodeViewController *weakself = self;
    _portraitImageView.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *portraitTap = [UITapGestureRecognizer bk_recognizerWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        
        [weakself editPortrait];
    }];
    
    
    [_portraitImageView addGestureRecognizer:portraitTap];
    [JYUserModel shareInstance].imgString = [[NSUserDefaults standardUserDefaults] objectForKey:@"imgString"];
    if (!NSString_ISNULL([JYUserModel shareInstance].imgString)) {
        
        [self uploadPotraitImageView];
        
    }
    else{
        
        UIImage *image = [UIImage imageNamed:@"iconBlack.jpeg"];
        self.portraitImageView.image = image;
        [self blurImage:image];
    }
    
    if ([JYUserModel shareInstance].isLogin) {
        
        [self getPersonImformation];
    }
    else{
        
        [[JYUserModel shareInstance] loginWithFinishBlock:^{
            
            if ([JYUserModel shareInstance].isLogin) {
                
                [weakself getPersonImformation];
            }
        }];
    }
    
    [self creatImformation];
}

#pragma orgin TODO
-(void)creatImformation{
    
    [[BKRequestProxy sharedInstance] requestWithType:BKRequestTypeGET
                                           urlString:@"/activity/luckyDraw"
                                              params:nil
                                                part:nil
                                             success:^(BKRequestModel *request, BKResponseModel *response) {
                                                 
                                                 if ([response.responseObject isKindOfClass:[NSDictionary class]] && [JYSuccessCode isEqualToString:response.head.code]) {
                                                     
                                                     NSLog(@"%@",response.responseObject);
                                                     
                                                 }
                                                 else{
                                                     
                                                     [[BKCustomProgressHUD sharedCustomProgressHUD] showHUdModeTextViewWithMessage:response.head.msg];
                                                 }
                                                 
                                             }
                                             failure:^(BKRequestModel *request, NSError *error) {
                                                 
                                                 [[BKCustomProgressHUD sharedCustomProgressHUD] showHUdModeTextViewWithMessage:@"网络状态不佳，请稍后再试试哦!"];
                                             }];

}


-(void)creatCustomView{
    
    self.customView.backgroundColor = [UIColor clearColor];

    UIView *backView = [[UIView alloc] initWithFrame:self.customView.bounds];
    backView.backgroundColor = [UIColor blackColor];
    backView.alpha = 0.7f;
    [self.customView addSubview:backView];
    
    UIImage *tipsImage = [UIImage imageNamed:@"pageRectangle"];
    UIImageView *tipsImageView = [[UIImageView alloc] initWithFrame:CGRectMake(16, 32, tipsImage.size.width, tipsImage.size.height)];
    tipsImageView.image = tipsImage;
    [backView addSubview:tipsImageView];
    
    UIButton *clickBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    clickBtn.frame = CGRectMake(30, tipsImageView.originY + tipsImageView.height + 30, kScreenWidth - 60, 50);
    clickBtn.backgroundColor = [UIColor clearColor];
    clickBtn.layer.masksToBounds = YES;
    clickBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    clickBtn.layer.borderWidth = 1;
    clickBtn.layer.cornerRadius = 4;
    [clickBtn setTitle:@"太棒了" forState:UIControlStateNormal];

    [clickBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [clickBtn addTarget:self action:@selector(clickBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [backView addSubview:clickBtn];
}

-(void)clickBtnAction:(id)sender
{
    [UIView animateKeyframesWithDuration:0.5f delay:0 options:UIViewKeyframeAnimationOptionLayoutSubviews animations:^{
        
        self.customView.alpha = 0;
        
    } completion:^(BOOL finished) {
        
        [self.customView removeFromSuperview];
    }];
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:FirstUpdate];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    self.scantopViewConstraint.constant = (kScreenHeight - 49)*(0.618);

    [self.scanView needsUpdateConstraints];
    [self.scanView setNeedsLayout];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(buySuccessNotification:) name:JYOrderSuccess object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForegroundNotification:) name:UIApplicationWillEnterForegroundNotification object:nil];
}

#pragma mark -appWillEnterForegroundNotification

-(void)appWillEnterForegroundNotification:(NSNotification *)notification
{
    if ([JYUserModel shareInstance].isLogin) {
        
        [self getPersonImformation];
    }
}

#pragma mark -tradeSuccessNotification

-(void)buySuccessNotification:(NSNotification *)notification
{
    if ([JYUserModel shareInstance].isLogin) {
        [self getPersonImformation];
    }
}

#pragma mark 
#pragma mark FirstUserShow

-(void)showAnimation{
    
    _guidance = [[JYGuidanceView shareInstance] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight) andWithString:[JYUserModel shareInstance].userName];
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"firstUse"]) {
        
        [self.view addSubview:_guidance];
        
        __block JYQRcodeViewController *weakSelf = self;
        _guidance.dismissBlock = ^(void){
            
            POPBasicAnimation *offscreenAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerPositionY];
            offscreenAnimation.toValue = @(1.5*weakSelf.view.height);
            
            POPSpringAnimation *scaleAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
            scaleAnimation.springBounciness = 10;
            scaleAnimation.fromValue = [NSValue valueWithCGPoint:CGPointMake(0.6, 0.8)];
            
            [offscreenAnimation setCompletionBlock:^(POPAnimation *anim, BOOL finished) {
                
                [weakSelf.guidance removeFromSuperview];
                [[NSUserDefaults standardUserDefaults] setBool:[JYUserModel shareInstance].firstUse forKey:@"firstUse"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }];
            
            [weakSelf.guidance.imageView.layer pop_addAnimation:scaleAnimation forKey:@"scaleAnimation"];
            [weakSelf.guidance.imageView.layer pop_addAnimation:offscreenAnimation forKey:@"offscreenAnimation"];
        };
    }
}


-(void)getPersonImformation
{
    [[BKRequestProxy sharedInstance] requestWithType:BKRequestTypeGET
                                           urlString:@"/user/account"
                                              params:nil
                                                part:nil
                                             success:^(BKRequestModel *request, BKResponseModel *response) {
                                                                                                                                                   
                                                 if ([response.responseObject isKindOfClass:[NSDictionary class]] && [JYSuccessCode isEqualToString:response.head.code]) {
                                                
                                                     NSLog(@"%@",response.responseObject);
                                                     
                                                     [JYUserModel shareInstance].userName = response.responseObject[@"name"];
                                                     [JYUserModel shareInstance].pointCount = [[response.responseObject objectForKey:@"pointCount"] floatValue];
                                                     [JYUserModel shareInstance].exchangeSum = [response.responseObject[@"exchangeMemoCount"] floatValue];
                                                     [JYUserModel shareInstance].imgString = response.responseObject[@"headUrl"];
                                                     
                                                     [JYUserModel shareInstance].isExermt = [response.responseObject[@"noPwdPayFlag"] boolValue];
                                                     
                                                     [JYUserModel shareInstance].isShowTouchID = [response.responseObject[@"fingerPayFlag"] boolValue];
                                                     
                                                     [JYUserModel shareInstance].appVersion = response.responseObject[@"versionIos"];
                                                     [JYUserModel shareInstance].appVersionMsg = response.responseObject[@"versionIosMsg"];
                                                     
                                                     [JYUserModel shareInstance].workingStatus = response.responseObject[@"workingStatus"];
                                                     
                                                     if ([JYUserModel shareInstance].imgString != [[NSUserDefaults standardUserDefaults] objectForKey:@"imgString"]) {
                                                         
                                                         [self uploadPotraitImageView];
                                                     }
                                                     
                                                     [self updateUI];
                                                     
                                                     [self updateShakeModelDataWithDic:response.responseObject];
                                                
                                                     if ([JYUserModel shareInstance].firstUse) {
                                                     
                                                         [self showAnimation];
                                                     }
                                                     else{
                                                         
                                                         if ([[JYUserModel shareInstance].workingStatus isEqualToString:WORKSTATUS] || [[JYUserModel shareInstance].workingStatus isEqualToString:@"99"]) {
                                                             
                                                             if (![[NSUserDefaults standardUserDefaults] objectForKey:FirstUpdate]) {
                                                                 
                                                                 self.customView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
                                                                 [self.view addSubview:self.customView];
                                                                 
                                                                 [self creatCustomView];
                                                             }
                                                         }
                                                     }
                                                 }
                                                 else{
                                                     
                                                     [[BKCustomProgressHUD sharedCustomProgressHUD] showHUdModeTextViewWithMessage:response.head.msg];
                                                 }

                                             }
                                             failure:^(BKRequestModel *request, NSError *error) {
                                                 
                                                 [[BKCustomProgressHUD sharedCustomProgressHUD] showHUdModeTextViewWithMessage:@"网络状态不佳，请稍后再试试哦!"];
                                             }];
    
}

-(void)updateShakeModelDataWithDic:(NSDictionary *)dic
{
    JYShakeModel *model = [[JYShakeModel alloc] initWithDataDic:dic];
    model.isEpoint = [model.isEpointTime boolValue];
    model.isLotteryDrawTime = [model.isMovieTime boolValue];

    self.shakeModel = model;
}

-(void)updateUI
{
    self.userNameLabel.text = [JYUserModel shareInstance].userName;
    self.accountLabel.text =  [[[NSNumber numberWithFloat:[JYUserModel shareInstance].pointCount] toCurrencyWithoutSymbol] formatStringWithOutDecimal];
    self.accountLabel.font = [UIFont fontWithName:@"Impact" size:32];
    self.totalConsumeLabel.text = [[[NSNumber numberWithFloat:[JYUserModel shareInstance].exchangeSum] toCurrencyWithoutSymbol] formatStringWithOutDecimal];
    self.totalConsumeLabel.font = [UIFont fontWithName:@"Impact" size:32];
    
    [JYShowNewVersion sharedInstance].applicationStoreVersion = [JYUserModel shareInstance].appVersion;
    [JYShowNewVersion sharedInstance].message = [JYUserModel shareInstance].appVersionMsg;
    if ([JYShowNewVersion sharedInstance].applicationVersion.length > 0) {
        
        [[JYShowNewVersion sharedInstance] show];
    }
    
    if (![[JYUserModel shareInstance].workingStatus isEqualToString:WORKSTATUS] && ![[JYUserModel shareInstance].workingStatus isEqualToString:@"99"]) {
        
//        self.leftImage = nil;
//        self.navLeftButton.userInteractionEnabled = NO;
        
        self.addressBtn.hidden = YES;
    }
}

#pragma mark
#pragma mark VPImageCropperDelegate

- (void)editPortrait {
    UIActionSheet *choiceSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"取消"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"拍照", @"从相册中选取", nil];
    [choiceSheet showInView:self.view];
}

- (void)imageCropper:(VPImageCropperViewController *)cropperViewController selectedSize:(CGRect)rect didFinished:(UIImage *)editedImage {
    
    self.portraitImageView.image = [self getSubImageWith:editedImage rect:rect];
    
    [self blurImage:[self getSubImageWith:editedImage rect:rect]];
    
    [cropperViewController dismissViewControllerAnimated:YES completion:^{
        
        [[JYUploadProtraitImageNetworking sharedInstance] uploadImageWithProtrait:editedImage];
        
    }];
}

-(UIImage *)getSubImageWith:(UIImage *)image rect:(CGRect)rect{
    
    CGRect myImageRect = rect;
    CGImageRef imageRef = image.CGImage;
    CGImageRef subImageRef = CGImageCreateWithImageInRect(imageRef, myImageRect);
    CGSize size;
    size.width = myImageRect.size.width;
    size.height = myImageRect.size.height;
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context, myImageRect, subImageRef);
    UIImage* smallImage = [UIImage imageWithCGImage:subImageRef];
    UIGraphicsEndImageContext();
    return smallImage;
}


- (void)imageCropperDidCancel:(VPImageCropperViewController *)cropperViewController {
    [cropperViewController dismissViewControllerAnimated:YES completion:^{
        
    }];
}

#pragma mark UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        // 拍照
        if ([self validateCamera]) {
            UIImagePickerController *controller = [[UIImagePickerController alloc] init];
            controller.sourceType = UIImagePickerControllerSourceTypeCamera;
            if ([self isFrontCameraAvailable]) {
                controller.cameraDevice = UIImagePickerControllerCameraDeviceFront;
            }
            NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
            [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
            controller.mediaTypes = mediaTypes;
            controller.delegate = self;
            [self presentViewController:controller
                               animated:YES
                             completion:^(void){
                                 NSLog(@"Picker View Controller is presented");
                             }];
        }
        else{
        
            JYShowPhotoViewController *showPhotoVC = [[JYShowPhotoViewController alloc] init];
            showPhotoVC.titleString = @"请为我开放访问相机的权限\n设置>隐私>相机>积友（打开)";
            [self presentViewController:showPhotoVC animated:YES completion:nil];
        }
        
    } else if (buttonIndex == 1) {
        // 从相册中选取
        if ([self isPhotoLibraryAvailable]) {
            UIImagePickerController *controller = [[UIImagePickerController alloc] init];
            controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
            [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
            controller.mediaTypes = mediaTypes;
            controller.delegate = self;
            [self presentViewController:controller
                               animated:YES
                             completion:^(void){
                                 NSLog(@"Picker View Controller is presented");
                             }];
        }
        else{
            
            JYShowPhotoViewController *showPhotoVC = [[JYShowPhotoViewController alloc] init];
            showPhotoVC.titleString = @"此应用程序没有权限来访问您的照片或视频。您可以在“隐私设置”中启用访问。";
            [self presentViewController:showPhotoVC animated:YES completion:nil];
        }
    }
}

#pragma mark
#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:^() {
        UIImage *portraitImg = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        portraitImg = [self imageByScalingToMaxSize:portraitImg];
        // 裁剪
        VPImageCropperViewController *imgEditorVC = [[VPImageCropperViewController alloc]
                                                     initWithImage:portraitImg
                                                     cropFrame:CGRectMake(0, 120.0f, kScreenWidth, kScreenWidth)
                                                     limitScaleRatio:3.0];
        imgEditorVC.delegate = self;
        [self presentViewController:imgEditorVC animated:YES completion:^{
            // TO DO
        }];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^(){
        
    }];
}

#pragma mark
#pragma mark camera utility
- (BOOL) isFrontCameraAvailable {
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront];
}

- (BOOL) isPhotoLibraryAvailable{
    
    ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
    if (author == ALAuthorizationStatusRestricted || author == ALAuthorizationStatusDenied){
        //无权限
        return NO;
    }
    else{
    
        return [UIImagePickerController isSourceTypeAvailable:
                UIImagePickerControllerSourceTypePhotoLibrary];
    }
}

- (BOOL)validateCamera {
    
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if(authStatus == ALAuthorizationStatusRestricted || authStatus == ALAuthorizationStatusDenied){
        
        return NO;
    }
    else{
    
        return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] &&
        [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
    }
}

#pragma mark
#pragma mark image scale utility
- (UIImage *)imageByScalingToMaxSize:(UIImage *)sourceImage {
    if (sourceImage.size.width < ORIGINAL_MAX_WIDTH) return sourceImage;
    CGFloat btWidth = 0.0f;
    CGFloat btHeight = 0.0f;
    if (sourceImage.size.width > sourceImage.size.height) {
        btHeight = ORIGINAL_MAX_WIDTH;
        btWidth = sourceImage.size.width * (ORIGINAL_MAX_WIDTH / sourceImage.size.height);
    } else {
        btWidth = ORIGINAL_MAX_WIDTH;
        btHeight = sourceImage.size.height * (ORIGINAL_MAX_WIDTH / sourceImage.size.width);
    }
    CGSize targetSize = CGSizeMake(btWidth, btHeight);
    return [self imageByScalingAndCroppingForSourceImage:sourceImage targetSize:targetSize];
}

- (UIImage *)imageByScalingAndCroppingForSourceImage:(UIImage *)sourceImage targetSize:(CGSize)targetSize {
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor)
            scaleFactor = widthFactor; // scale to fit height
        else
            scaleFactor = heightFactor; // scale to fit width
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else
            if (widthFactor < heightFactor)
            {
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
            }
    }
    UIGraphicsBeginImageContext(targetSize); // this will crop
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil) NSLog(@"could not scale image");
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    return newImage;
}

#pragma mark
#pragma mark portraitImageView getter
- (UIImageView *)portraitImageView
{
    [_portraitImageView.layer setCornerRadius:(_portraitImageView.height/2)];
    [_portraitImageView.layer setMasksToBounds:YES];
//    [_portraitImageView setContentMode:UIViewContentModeScaleAspectFill];
    [_portraitImageView setClipsToBounds:YES];
//    _portraitImageView.layer.borderColor = [[UIColor whiteColor] CGColor];
//    _portraitImageView.layer.borderWidth = 2.0f;
    _portraitImageView.userInteractionEnabled = YES;
    _portraitImageView.backgroundColor = [UIColor clearColor];

    return _portraitImageView;
}

-(void)uploadPotraitImageView
{
    __block JYQRcodeViewController *weakself = self;
    
    [self.portraitImageView sd_setImageWithURL:[NSURL URLWithString:[JYUserModel shareInstance].imgString]
                              placeholderImage:[UIImage imageNamed:@"portrait"]
                                     completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
        if (![[JYUserModel shareInstance].imgString isEqualToString:@""]) {
            
            [weakself blurImage:image];
        }
       
    }];
}
#pragma mark - BlurImage

-(void)blurImage:(UIImage *)b_image
{
    CGFloat quality = .00001f;
    CGFloat blurred = .65f;
    NSData *imageData = UIImageJPEGRepresentation(b_image, quality);
    UIImage *blurredImage = [[UIImage imageWithData:imageData] blurredImage:blurred];
    self.homeImageView.image = blurredImage;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark
#pragma mark QRCodeAction

- (void)showQRViewController {
    
    JYQRViewController *qrVC = [[JYQRViewController alloc] init];
    [self.navigationController pushViewController:qrVC animated:YES];
}

- (IBAction)openQR:(id)sender {
    
    if ([self validateCamera]) {
        
        [self showQRViewController];
        
    } else {
    
        JYShowPhotoViewController *showPhotoVC = [[JYShowPhotoViewController alloc] init];
        showPhotoVC.titleString = @"请为我开放访问相机的权限\n设置>隐私>相机>积友（打开)";
        [self presentViewController:showPhotoVC animated:YES completion:^{
            
        }];
    }
}

#pragma mark - Button Click

-(void)navBack
{
    NSLog(@"回不去了吧！");
}

- (IBAction)editButtonClick:(id)sender {
    
    JYSettingViewController *settingVC = [[JYSettingViewController alloc] initWithNibName:@"JYSettingViewController" bundle:nil];
    [self.navigationController pushViewController:settingVC animated:YES];
}

- (IBAction)addressButtonClick:(id)sender {
    
    JYMobileAddressController *mobileVC = [[JYMobileAddressController alloc] initWithNibName:@"JYMobileAddressController" bundle:nil];
    [self.navigationController pushViewController:mobileVC animated:YES];

}

- (IBAction)myAccountButttonClick:(id)sender {
    
    JYMyExchangeViewController *exchangeVC = [[JYMyExchangeViewController alloc] initWithNibName:@"JYMyExchangeViewController" bundle:nil];
    [self.navigationController pushViewController:exchangeVC animated:YES];
}

- (IBAction)consumeButtonClick:(id)sender {

    JYExchangeDetailViewController *exchangeVC = [[JYExchangeDetailViewController alloc] initWithNibName:@"JYExchangeDetailViewController" bundle:nil];
    [self.navigationController pushViewController:exchangeVC animated:YES];
}

- (IBAction)showWebViewClick:(id)sender {
    
    JYWebViewController *webController = [[JYWebViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:webController animated:YES];
}

- (IBAction)showIntegralClick:(id)sender {
    
//    JYChooseViewController *lotteryController = [[JYChooseViewController alloc] init];
//    lotteryController.shakeModel = self.shakeModel;
//    [self.navigationController pushViewController:lotteryController animated:YES];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:JYOrderSuccess object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];

    DLog(@"delate");
}

@end
