//
//  UIViewController+SelectPhoto.h
//  LYQRCodeDemo
//
//  Created by LuYang on 16/4/11.
//  Copyright © 2016年 LuYang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^WJSelectPhotoSuccessBlock)(UIImage *image);

@interface UIViewController (SelectPhoto)<UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
- (void)selectPhotoFromAlbumWithSuccess:(WJSelectPhotoSuccessBlock)block;
@end
