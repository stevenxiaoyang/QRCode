//
//  BaseDecodeViewController.m
//  LYQRCodeDemo
//
//  Created by LuYang on 16/4/13.
//  Copyright © 2016年 LuYang. All rights reserved.
//

#import "BaseDecodeViewController.h"

static const CGFloat Scan_Time = 2.f;
@implementation BaseDecodeViewController{
    CGRect lineStartLocation;
    CGRect lineEndLocation;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UIImage *scanBgImage = [UIImage imageNamed:@"scanner_rect_icon"];
    _scanBackgroundView = [[UIImageView alloc] initWithImage:scanBgImage];
    _scanBackgroundView.size = CGSizeMake(260, 260);
    _scanBackgroundView.top = 100;
    _scanBackgroundView.centerX = self.view.centerX;
    [self.view addSubview:_scanBackgroundView];
    
    _scanRectView = [[UIView alloc]initWithFrame:CGRectZero];
    _scanRectView.frame = _scanBackgroundView.frame;
    [self.view addSubview:_scanRectView];
    
    _resultLabel = [[UILabel alloc] init];
    _resultLabel.frame = _scanBackgroundView.frame;
    [self.view addSubview:_resultLabel];
    
    UIImage *scannerImage = [UIImage imageNamed:@"scanner_line_icon"];
    lineStartLocation = CGRectMake((self.view.width - _scanBackgroundView.width)/2, 100, 260, scannerImage.size.height);
    lineEndLocation = CGRectMake(lineStartLocation.origin.x, lineStartLocation.origin.y+260, 260, scannerImage.size.height);
    UIImageView *lineView = [[UIImageView alloc] initWithFrame:lineStartLocation];
    lineView.image = scannerImage;
    [self.view addSubview:lineView];
    _scanLineView = lineView;
    
    UIView *backGroundViewTop = [[UIView alloc] init];
    backGroundViewTop.frame = CGRectMake(0, 0, self.view.width, _scanBackgroundView.top);
    backGroundViewTop.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
    [self.view addSubview:backGroundViewTop];
    
    UIView *backGroundViewBottom = [[UIView alloc] init];
    backGroundViewBottom.frame = CGRectMake(0, _scanBackgroundView.bottom, self.view.width, self.view.height - _scanBackgroundView.bottom);
    backGroundViewBottom.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
    [self.view addSubview:backGroundViewBottom];
    
    UIView *backGroundViewLeft = [[UIView alloc] init];
    backGroundViewLeft.frame = CGRectMake(0,_scanBackgroundView.top,(self.view.width - _scanBackgroundView.width)/2, _scanBackgroundView.height);
    backGroundViewLeft.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
    [self.view addSubview:backGroundViewLeft];
    
    UIView *backGroundViewRight = [[UIView alloc] init];
    backGroundViewRight.frame = CGRectMake(_scanBackgroundView.right,_scanBackgroundView.top,backGroundViewLeft.width, backGroundViewLeft.height);
    backGroundViewRight.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
    [self.view addSubview:backGroundViewRight];
    
    UIButton *photoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [photoButton setTitle:@"调入相册中的二维码" forState:UIControlStateNormal];
    [photoButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [photoButton.titleLabel setFont:[UIFont boldSystemFontOfSize:15]];
    photoButton.size = CGSizeMake(200, 15);
    photoButton.top = _scanBackgroundView.bottom + 20;
    photoButton.centerX = self.view.centerX;
    [photoButton addTarget:self action:@selector(getPhoto) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:photoButton];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _timer = [NSTimer scheduledTimerWithTimeInterval:Scan_Time target:self selector:@selector(scanImage) userInfo:nil repeats:YES];
    [_timer fire];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if (_timer && [_timer isValid]) {
        [_timer invalidate];
        _timer = nil;
    }
}

-(void)scanImage{
    __weak typeof(self) weak_self = self;
    weak_self.scanLineView.frame = lineStartLocation;
    [UIView animateWithDuration:Scan_Time animations:^{
        weak_self.scanLineView.frame = lineEndLocation;
    }];
}

#pragma mark - UIButton Response
- (void)getPhoto{
    __weak typeof(self) weak_self = self;
    [self selectPhotoFromAlbumWithSuccess:^(UIImage *image) {
        [weak_self decodeImage:image];
    }];
}

#pragma mark - Decode Image
- (void)decodeImage:(UIImage *) image{
    if (_isSystem) {
        NSData *imageData = UIImagePNGRepresentation(image);
        CIImage *ciImage = [CIImage imageWithData:imageData];
        CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{CIDetectorAccuracy: CIDetectorAccuracyLow}];
        NSArray *feature = [detector featuresInImage:ciImage];
        
        for (CIQRCodeFeature *result in feature) {
            self.resultLabel.text = result.messageString;
            return;
        }
        self.resultLabel.text = @"无法识别";
    }
    else{
        CGImageRef imageToDecode = image.CGImage;
        ZXLuminanceSource *source = [[ZXCGImageLuminanceSource alloc] initWithCGImage:imageToDecode];
        ZXBinaryBitmap *bitmap = [ZXBinaryBitmap binaryBitmapWithBinarizer:[ZXHybridBinarizer binarizerWithSource:source]];
        
        NSError *error = nil;
        
        // There are a number of hints we can give to the reader, including
        // possible formats, allowed lengths, and the string encoding.
        ZXDecodeHints *hints = [ZXDecodeHints hints];
        ZXQRCodeReader *reader = [[ZXQRCodeReader alloc] init];
        ZXResult *result = [reader decode:bitmap
                                    hints:hints
                                    error:&error];
        if (result) {
            self.resultLabel.text = result.text;
        } else {
            self.resultLabel.text = @"无法识别";
        }
    }
}

@end