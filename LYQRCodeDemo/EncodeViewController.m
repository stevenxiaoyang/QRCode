//
//  EncodeViewController.m
//  LYQRCodeDemo
//
//  Created by LuYang on 16/4/11.
//  Copyright © 2016年 LuYang. All rights reserved.
//

#import "EncodeViewController.h"

static NSString * const url = @"www.google.com";
@implementation EncodeViewController
- (void)viewDidLoad{
    [super viewDidLoad];
    UIImageView *codeImageView = [[UIImageView alloc] init];
    codeImageView.size = CGSizeMake(200,200);
    codeImageView.centerX = self.view.centerX;
    codeImageView.top = 100;
    [self.view addSubview:codeImageView];
    
    ZXEncodeHints *hints = [ZXEncodeHints hints];
    hints.encoding = NSUTF8StringEncoding;
    hints.margin = @(0);
    ZXQRCodeWriter *writer = [[ZXQRCodeWriter alloc] init];
    ZXBitMatrix *result = [writer encode:url
                                  format:kBarcodeFormatQRCode
                                   width:200*[UIScreen screenScale]
                                  height:200*[UIScreen screenScale]
                                   hints:hints
                                   error:nil];
    codeImageView.image = [UIImage imageWithCGImage:[[ZXImage imageWithMatrix:result] cgimage]];
    UIImageWriteToSavedPhotosAlbum(codeImageView.image, nil, nil, NULL);
}
@end

@implementation UIScreen (Add)
+ (CGFloat)screenScale {
    static CGFloat screenScale = 0.0;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if ([NSThread isMainThread]) {
            screenScale = [[UIScreen mainScreen] scale];
        } else {
            dispatch_sync(dispatch_get_main_queue(), ^{
                screenScale = [[UIScreen mainScreen] scale];
            });
        }
    });
    return screenScale;
}
@end