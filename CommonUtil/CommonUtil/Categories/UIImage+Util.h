//
//  UIImage+Util.h
//  VVM
//
//  Created by shulianyong on 12/03/30.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface UIImage (UIImage_Util)

- (UIImage*)shrinkImage:(CGRect)aRect;

- (UIImage *)generatePhotoThumbnail:(UIImage *)aImage;

+ (CGSize)fitSize:(CGSize)aThisSize inSize:(CGSize)aSize;

//返回调整的缩略图
+ (UIImage *)image:(UIImage *)aImage fitInSize:(CGSize)aViewsize;

//返回居中的缩略图
+ (UIImage *)image:(UIImage *)aImage centerInSize:(CGSize)aViewsize;

//返回填充的缩略图
+ (UIImage *)image:(UIImage *)aImage fillSize:(CGSize)aViewsize;

//让图片变小
+ (UIImage *)rescaleToSize:(UIImage *)aInImage toSize:(CGSize)aSize;

// save as jpeg
+ (BOOL) writeToImage:(UIImage*)aImage toFileAtPath:(NSString *)aFilePath;

@end
