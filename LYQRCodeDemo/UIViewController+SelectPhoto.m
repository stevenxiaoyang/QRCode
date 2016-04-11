//
//  UIViewController+SelectPhoto.m
//  LYQRCodeDemo
//
//  Created by LuYang on 16/4/11.
//  Copyright © 2016年 LuYang. All rights reserved.
//

#import "UIViewController+SelectPhoto.h"

@implementation UIViewController (SelectPhoto)
static WJSelectPhotoSuccessBlock _block;
static BOOL needEdit;
- (void)selectPhotoFromAlbumWithSuccess:(WJSelectPhotoSuccessBlock)block{
    _block = [block copy];
    [self localPhoto];
}

//打开本地相册
- (void)localPhoto {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    picker.allowsEditing = needEdit;
    [self presentViewController:picker animated:YES completion:nil];
}

//当选择一张图片后进入这里

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(nullable NSDictionary<NSString *,id> *)editingInfo {
    
}
- (void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    
    //当选择的类型是图片
    if ([type isEqualToString:@"public.image"]) {
        UIImage *image;
        if (needEdit) {
            image = [info objectForKey:UIImagePickerControllerEditedImage];
        } else {
            image = [info objectForKey:UIImagePickerControllerOriginalImage];
        }
        
        if (_block) {
            _block(image);
        }
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
