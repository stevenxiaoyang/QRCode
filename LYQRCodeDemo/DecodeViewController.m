//
//  DecodeViewController.m
//  LYQRCodeDemo
//
//  Created by LuYang on 16/4/11.
//  Copyright © 2016年 LuYang. All rights reserved.
//

#import "DecodeViewController.h"

@interface DecodeViewController()<ZXCaptureDelegate>
@property (nonatomic, strong)UIView *scanRectView;
@property (nonatomic, strong)UIImageView *scanBackgroundView;
@property (nonatomic, weak)  UIImageView *scanLineView;
@property (nonatomic, strong)ZXCapture *capture;
@property (nonatomic, strong)NSTimer *timer;
@property (nonatomic, strong)UILabel *resultLabel;
@end

static const CGFloat Scan_Time = 2.f;
@implementation DecodeViewController{
    CGAffineTransform _captureSizeTransform;
    CGRect lineStartLocation;
    CGRect lineEndLocation;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"扫一扫";
    // Do any additional setup after loading the view.
    _capture = [[ZXCapture alloc] init];
    _capture.camera = self.capture.back;
    _capture.focusMode = AVCaptureFocusModeContinuousAutoFocus;
    [self.view.layer addSublayer:self.capture.layer];
    
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
    self.capture.delegate = self;
    [self applyOrientation];
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
- (void)dealloc {
    [self.capture.layer removeFromSuperlayer];
}

-(void)scanImage{
    __weak typeof(self) weak_self = self;
    weak_self.scanLineView.frame = lineStartLocation;
    [UIView animateWithDuration:Scan_Time animations:^{
        weak_self.scanLineView.frame = lineEndLocation;
    }];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return toInterfaceOrientation == UIInterfaceOrientationPortrait;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [self applyOrientation];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    __weak typeof(self) weak_self = self;
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context)
     {
         [weak_self applyOrientation];
     }];
}

#pragma mark - Private
- (void)applyOrientation {
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    float scanRectRotation;
    float captureRotation;
    
    switch (orientation) {
        case UIInterfaceOrientationPortrait:
            captureRotation = 0;
            scanRectRotation = 90;
            break;
        case UIInterfaceOrientationLandscapeLeft:
            captureRotation = 90;
            scanRectRotation = 180;
            break;
        case UIInterfaceOrientationLandscapeRight:
            captureRotation = 270;
            scanRectRotation = 0;
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            captureRotation = 180;
            scanRectRotation = 270;
            break;
        default:
            captureRotation = 0;
            scanRectRotation = 90;
            break;
    }
    [self applyRectOfInterest:orientation];
    CGAffineTransform transform = CGAffineTransformMakeRotation((CGFloat) (captureRotation / 180 * M_PI));
    [self.capture setTransform:transform];
    [self.capture setRotation:scanRectRotation];
    CGRect frame = self.view.frame;
    frame.origin.y -= 64;
    self.capture.layer.frame = frame;
}

- (void)applyRectOfInterest:(UIInterfaceOrientation)orientation {
    CGFloat scaleVideo, scaleVideoX, scaleVideoY;
    CGFloat videoSizeX, videoSizeY;
    CGRect frame = self.scanRectView.frame;
    frame.size = CGSizeMake(2 * frame.size.width, 2 * frame.size.height);
    CGRect transformedVideoRect = frame;
    if([self.capture.sessionPreset isEqualToString:AVCaptureSessionPreset1920x1080]) {
        videoSizeX = 1080;
        videoSizeY = 1920;
    } else {
        videoSizeX = 720;
        videoSizeY = 1280;
    }
    if(UIInterfaceOrientationIsPortrait(orientation)) {
        scaleVideoX = self.view.frame.size.width / videoSizeX;
        scaleVideoY = self.view.frame.size.height / videoSizeY;
        scaleVideo = MAX(scaleVideoX, scaleVideoY);
        if(scaleVideoX > scaleVideoY) {
            transformedVideoRect.origin.y += (scaleVideo * videoSizeY - self.view.frame.size.height) / 2;
        } else {
            transformedVideoRect.origin.x += (scaleVideo * videoSizeX - self.view.frame.size.width) / 2;
        }
    } else {
        scaleVideoX = self.view.frame.size.width / videoSizeY;
        scaleVideoY = self.view.frame.size.height / videoSizeX;
        scaleVideo = MAX(scaleVideoX, scaleVideoY);
        if(scaleVideoX > scaleVideoY) {
            transformedVideoRect.origin.y += (scaleVideo * videoSizeX - self.view.frame.size.height) / 2;
        } else {
            transformedVideoRect.origin.x += (scaleVideo * videoSizeY - self.view.frame.size.width) / 2;
        }
    }
    _captureSizeTransform = CGAffineTransformMakeScale(1/scaleVideo, 1/scaleVideo);
    self.capture.scanRect = CGRectApplyAffineTransform(transformedVideoRect, _captureSizeTransform);
}

#pragma mark - UIButton Response
- (void)getPhoto{
    __weak typeof(self) weak_self = self;
    [self selectPhotoFromAlbumWithSuccess:^(UIImage *image) {
        [weak_self decodeImage:image];
    }];
}

#pragma mark - ZXCaptureDelegate Methods
- (void)captureResult:(ZXCapture *)capture result:(ZXResult *)result {
    if (!result) return;
    
    CGAffineTransform inverse = CGAffineTransformInvert(_captureSizeTransform);
    NSMutableArray *points = [[NSMutableArray alloc] init];
    NSString *location = @"";
    for (ZXResultPoint *resultPoint in result.resultPoints) {
        CGPoint cgPoint = CGPointMake(resultPoint.x, resultPoint.y);
        CGPoint transformedPoint = CGPointApplyAffineTransform(cgPoint, inverse);
        transformedPoint = [self.scanRectView convertPoint:transformedPoint toView:self.scanRectView.window];
        NSValue* windowPointValue = [NSValue valueWithCGPoint:transformedPoint];
        location = [NSString stringWithFormat:@"%@ (%f, %f)", location, transformedPoint.x, transformedPoint.y];
        [points addObject:windowPointValue];
    }
    // Vibrate
    
    [_resultLabel setText:result.text];
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    
    [self.capture stop];
    
    __weak typeof(self) weak_self = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [weak_self.capture start];
    });
}

#pragma mark - Decode Image
- (void)decodeImage:(UIImage *) image{
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
        _resultLabel.text = result.text;
    } else {
        _resultLabel.text = @"无法识别";
    }
}

@end
