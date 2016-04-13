//
//  BaseDecodeViewController.h
//  LYQRCodeDemo
//
//  Created by LuYang on 16/4/13.
//  Copyright © 2016年 LuYang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseDecodeViewController : UIViewController
@property (nonatomic, strong)UIView *scanRectView;
@property (nonatomic, strong)UIImageView *scanBackgroundView;
@property (nonatomic, weak)  UIImageView *scanLineView;
@property (nonatomic, strong)NSTimer *timer;
@property (nonatomic, strong)UILabel *resultLabel;
@property (nonatomic, assign)BOOL isSystem;
@end
