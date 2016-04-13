//
//  SystemDecodeViewController.m
//  LYQRCodeDemo
//
//  Created by LuYang on 16/4/13.
//  Copyright © 2016年 LuYang. All rights reserved.
//

#import "SystemDecodeViewController.h"

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface SystemDecodeViewController ()<AVCaptureMetadataOutputObjectsDelegate>
@property (nonatomic,assign)BOOL isQRCodeCaptured;
@property (nonatomic,strong)  AVCaptureSession *captureSession;
@end

@implementation SystemDecodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _isQRCodeCaptured = NO;
    self.isSystem = YES;
    // Do any additional setup after loading the view.
    AVAuthorizationStatus authorizationStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (authorizationStatus) {
        case AVAuthorizationStatusNotDetermined: {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler: ^(BOOL granted) {
                if (granted) {
                    [self startCapture];
                } else {
                    NSLog(@"%@", @"访问受限");
                }
            }];
            break;
        }
        case AVAuthorizationStatusAuthorized: {
            [self startCapture];
            break;
        }
        case AVAuthorizationStatusRestricted:
        case AVAuthorizationStatusDenied: {
            NSLog(@"%@", @"访问受限");
            break;
        }
        default: {
            break;
        }
    }
}

- (void)dealloc{
    [_captureSession stopRunning];
    _captureSession = nil;
}

- (void)startCapture{
    _captureSession = [[AVCaptureSession alloc] init];
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error;
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (deviceInput) {
        [_captureSession addInput:deviceInput];
        AVCaptureMetadataOutput *metadataOutput = [[AVCaptureMetadataOutput alloc] init];
        [metadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        [_captureSession addOutput:metadataOutput]; // 这行代码要在设置 metadataObjectTypes 前
        metadataOutput.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
        AVCaptureVideoPreviewLayer *previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        previewLayer.frame = self.view.frame;
        [self.view.layer insertSublayer:previewLayer atIndex:0];
        
        CGRect frame = self.scanRectView.frame;
        frame.size = CGSizeMake(2 * frame.size.width, 2 * frame.size.height);
        //metadataOutput.rectOfInterest = [previewLayer metadataOutputRectOfInterestForRect:frame];
        metadataOutput.rectOfInterest = CGRectMake(frame.origin.y/SCREEN_HEIGHT, frame.origin.x/SCREEN_WIDTH, frame.size.height/SCREEN_HEIGHT, frame.size.width/SCREEN_WIDTH);
        
        [_captureSession startRunning];
    } else {
        NSLog(@"%@", error);
    }
}

#pragma AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    AVMetadataMachineReadableCodeObject *metadataObject = metadataObjects.firstObject;
    if ([metadataObject.type isEqualToString:AVMetadataObjectTypeQRCode] && !self.isQRCodeCaptured) { // 成功后系统不会停止扫描，可以用一个变量来控制。
        self.isQRCodeCaptured = YES;
        [self.resultLabel setText:metadataObject.stringValue];
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        
        __weak typeof(self) weak_self = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            weak_self.isQRCodeCaptured = NO;
        });
    }
}

@end
