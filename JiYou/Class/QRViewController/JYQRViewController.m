//
//  JYQRViewController.m
//  YiYou
//
//  Created by Mars on 15/4/25.
//  Copyright (c) 2015年 lovelydd. All rights reserved.
//

#import "JYQRViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "QRView.h"
//#import "JYBuyViewController.h"
#import "JYNewBuyViewController.h"
#import "UIGestureRecognizer+BlocksKit.h"

#define QRIMAGEWIDTH 280*kScreenWidth/320

@interface JYQRViewController ()<AVCaptureMetadataOutputObjectsDelegate>
{
    BOOL torchIsOn;
}

@property (strong, nonatomic) AVCaptureDevice * device;
@property (strong, nonatomic) AVCaptureDeviceInput * input;
@property (strong, nonatomic) AVCaptureMetadataOutput * output;
@property (strong, nonatomic) AVCaptureSession * session;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer * preview;


@property (nonatomic, strong) UIButton *rightBtn;

@property(nonatomic, retain) AVCaptureSession * AVSession;

@end

@implementation JYQRViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationBarHidden = YES;
    self.leftImage = nil;
    
    torchIsOn = YES;
    
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // Input
    _input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    
    // Output
    _output = [[AVCaptureMetadataOutput alloc]init];
    [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    // Session
    _session = [[AVCaptureSession alloc]init];
    [_session setSessionPreset:AVCaptureSessionPresetHigh];
    if ([_session canAddInput:self.input])
    {
        [_session addInput:self.input];
    }
    
    if ([_session canAddOutput:self.output])
    {
        [_session addOutput:self.output];
    }
    
    
    // 条码类型 AVMetadataObjectTypeQRCode
    _output.metadataObjectTypes =@[AVMetadataObjectTypeQRCode];
    
    // Preview
    _preview =[AVCaptureVideoPreviewLayer layerWithSession:_session];
    _preview.videoGravity =AVLayerVideoGravityResize;
    _preview.frame =self.view.layer.bounds;
    [self.view.layer insertSublayer:_preview atIndex:0];
    
    
    QRView *qrRectView = [[QRView alloc] initWithFrame:self.view.frame];
    qrRectView.transparentArea = CGSizeMake(QRIMAGEWIDTH, QRIMAGEWIDTH);
    qrRectView.backgroundColor = [UIColor clearColor];
    qrRectView.center = CGPointMake(kScreenWidth / 2, kScreenHeight / 2);
    [self.view addSubview:qrRectView];
    
    //修正扫描区域
    CGRect cropRect = CGRectMake((kScreenWidth - qrRectView.transparentArea.width) / 2,
                                 (kScreenHeight - qrRectView.transparentArea.height) / 2,
                                 qrRectView.transparentArea.width,
                                 qrRectView.transparentArea.height);

    [_output setRectOfInterest:CGRectMake(cropRect.origin.y / kScreenHeight,
                                          cropRect.origin.x / kScreenWidth,
                                          cropRect.size.height / kScreenHeight,
                                          cropRect.size.width / kScreenWidth)];
    

    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    leftBtn.frame = CGRectMake(20, 20, 40, 40);
    [leftBtn setBackgroundImage:[UIImage imageNamed:@"back_oral.png"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(navBackBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:leftBtn];
    
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.frame = CGRectMake(kScreenWidth - 40 - 20, 20, 40, 40);
    [rightBtn setBackgroundImage:[UIImage imageNamed:@"flashlight_shut.png"] forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(flightTurnOn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:rightBtn];
    
    self.rightBtn = rightBtn;

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 90, kScreenWidth, 30)];
    label.text = @"请将二维码至于框内";
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:16];
    [self.view addSubview:label];

}

-(void)navNext
{
    [self flightTurnOn:self.rightBtn];
}

-(void)navBackBtnClick:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)prefersStatusBarHidden
{
    return YES; //返回NO表示要显示，返回YES将hiden
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [_session startRunning];

    [self.view bringSubviewToFront:self.rightBtn];
    
    __weak JYQRViewController* weakself = self;

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] bk_initWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        
        [weakself flightTurnOn:weakself.rightBtn];
        
    }];
    
    [self.rightBtn addGestureRecognizer:tap];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    torchIsOn = NO;
    [self turnTorchOn:torchIsOn];
}

#pragma mark QRViewDelegate

-(void)flightTurnOn:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    if (!torchIsOn) {
        
        [btn setBackgroundImage:[UIImage imageNamed:@"flashlight_shut.png"] forState:UIControlStateNormal];
        btn.alpha = 0.5f;
    }
    else{
        
        [btn setBackgroundImage:[UIImage imageNamed:@"flashlight_open.png"] forState:UIControlStateNormal];
    }
    
    [self turnTorchOn:torchIsOn];
}

/**
 * 是否打开闪光灯
 *
 *  @param on 传YES时表示可以打开闪光灯 否则关闭
 */
- (void) turnTorchOn:(BOOL) on {
    
    Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
    if (captureDeviceClass != nil) {
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        if ([device hasTorch] && [device hasFlash]){
            
            [device lockForConfiguration:nil];
            if (on) {
                [device setTorchMode:AVCaptureTorchModeOn];
                [device setFlashMode:AVCaptureFlashModeOn];
                torchIsOn = NO;
            } else {
                [device setTorchMode:AVCaptureTorchModeOff];
                [device setFlashMode:AVCaptureFlashModeOff];
                torchIsOn = YES;
            }
            [device unlockForConfiguration];
        }
    }
}


-(void)stopReading{
    
    [_session stopRunning];
    _session = nil;
    [_preview removeFromSuperlayer];
}

#pragma mark AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    NSString *stringValue;
    if ([metadataObjects count] >0)
    {
        //停止扫描
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex:0];
        stringValue = metadataObject.stringValue;

    }

    [self stopReading];
    
    JYNewBuyViewController *buyVC = [[JYNewBuyViewController alloc] init];
    buyVC.urlString = stringValue;
    [self.navigationController pushViewController:buyVC animated:YES];

    NSLog(@" %@",stringValue);
    
    if (self.qrUrlBlock) {
        self.qrUrlBlock(stringValue);
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    DLog(@"delate");
}

@end
