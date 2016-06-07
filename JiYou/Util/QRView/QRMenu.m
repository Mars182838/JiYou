//
//  QRMenu.m
//  QRWeiXinDemo
//
//  Created by lovelydd on 15/4/30.
//  Copyright (c) 2015年 lovelydd. All rights reserved.
//

#import "QRMenu.h"

@implementation QRMenu

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
     
        [self setupQRItem];
        
    }
    
    return self;
}

- (void)setupQRItem {
    
    self.qrItem = [[QRItem alloc] initWithFrame:(CGRect){
        .origin.x = 0,
        .origin.y = 0,
        .size.width = self.bounds.size.width,
        .size.height = self.bounds.size.height
    } titile:nil];
    _qrItem.type = QRItemTypeQRCode;
    [self addSubview:_qrItem];
 
    [_qrItem addTarget:self action:@selector(qrScan:) forControlEvents:UIControlEventTouchUpInside];
}


#pragma mark - Action

- (void)qrScan:(QRItem *)qrItem {
    
    if (self.didSelectedBlock) {
        
        self.didSelectedBlock(qrItem);
    }
}

@end
