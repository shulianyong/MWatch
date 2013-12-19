//
//  UIImage+Util.m
//  VVM
//
//  Created by shulianyong on 12/03/30.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "UIImage+Util.h"


@implementation UIImage (UIImage_Util)

- (UIImage*)shrinkImage:(CGRect)aRect {
	UIGraphicsBeginImageContextWithOptions(aRect.size, NO, 0.0);
	
	[self drawInRect:aRect];
	
	UIImage* shrinkedImage = UIGraphicsGetImageFromCurrentImageContext();
	
	UIGraphicsEndImageContext();
	
	return shrinkedImage;
}

- (UIImage *)generatePhotoThumbnail:(UIImage *)aImage {
	// Create a thumbnail version of the image for the event object.
	CGSize size = aImage.size;
	CGSize croppedSize;
//	CGFloat ratio = 64.0;
	CGFloat offsetX = 0.0;
	CGFloat offsetY = 0.0;
    
	// check the size of the image, we want to make it
	// a square with sides the size of the smallest dimension
	if (size.width > size.height) {
		offsetX = (size.height - size.width) / 2;
		croppedSize = CGSizeMake(size.height, size.height);
	} else {
		offsetY = (size.width - size.height) / 2;
		croppedSize = CGSizeMake(size.width, size.width);
	}
    
	// Crop the image before resize
	CGRect clippedRect = CGRectMake(offsetX * -1, offsetY * -1, croppedSize.width, croppedSize.height);
	CGImageRef imageRef = CGImageCreateWithImageInRect([aImage CGImage], clippedRect);
	// Done cropping
    
	// Resize the image
	CGRect rect = CGRectMake(0.0, 0.0, croppedSize.width, croppedSize.height);
    
	UIGraphicsBeginImageContext(rect.size);
	[[UIImage imageWithCGImage:imageRef] drawInRect:rect];
	UIImage *thumbnail = UIGraphicsGetImageFromCurrentImageContext();
    CGImageRelease(imageRef);
	UIGraphicsEndImageContext();
	// Done Resizing
    
	return thumbnail;
}

//计算适合的大小。并保留其原始图片大小
+ (CGSize)fitSize:(CGSize)aThisSize inSize:(CGSize)aSize
{
    CGFloat scale;
    CGSize newsize = aThisSize;
    
    if (newsize.height && (newsize.height > aSize.height))
    {
        scale = aSize.height / newsize.height;
        newsize.width *= scale;
        newsize.height *= scale;
    }
    
    if (newsize.width && (newsize.width >= aSize.width))
    {
        scale = aSize.width / newsize.width;
        newsize.width *= scale;
        newsize.height *= scale;
    }
    
    return newsize;
}

//返回调整的缩略图
+ (UIImage *)image:(UIImage *)aImage fitInSize:(CGSize)aViewsize
{
    // calculate the fitted size
    CGSize size = [self fitSize:aImage.size inSize:aViewsize];
    
    UIGraphicsBeginImageContext(aViewsize);
    
    float dwidth = (aViewsize.width - size.width) / 2.0f;
    float dheight = (aViewsize.height - size.height) / 2.0f;
    
    CGRect rect = CGRectMake(dwidth, dheight, size.width, size.height);
    [aImage drawInRect:rect];
    
    UIImage *newimg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newimg;
}

//返回居中的缩略图
+ (UIImage *)image:(UIImage *)aImage centerInSize:(CGSize)aViewsize
{
    CGSize size = aImage.size;
    
    UIGraphicsBeginImageContext(aViewsize);
    float dwidth = (aViewsize.width - size.width) / 2.0f;
    float dheight = (aViewsize.height - size.height) / 2.0f;
    
    CGRect rect = CGRectMake(dwidth, dheight, size.width, size.height);
    [aImage drawInRect:rect];
    
    UIImage *newimg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newimg;
}


//返回填充的缩略图
+ (UIImage *)image:(UIImage *)aImage fillSize:(CGSize)aViewsize
{
    CGSize size = aImage.size;
    
    CGFloat scalex = aViewsize.width / size.width;
    CGFloat scaley = aViewsize.height / size.height;
    CGFloat scale = MAX(scalex, scaley);
    
    UIGraphicsBeginImageContext(aViewsize);
    
    CGFloat width = size.width * scale;
    CGFloat height = size.height * scale;
    
    float dwidth = ((aViewsize.width - width) / 2.0f);
    float dheight = ((aViewsize.height - height) / 2.0f);
    
    CGRect rect = CGRectMake(dwidth, dheight, size.width * scale, size.height * scale);
    [aImage drawInRect:rect];
    
    UIImage *newimg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newimg;
}

//让图片变小
+ (UIImage *)rescaleToSize:(UIImage *)aInImage toSize:(CGSize)aSize {
	CGRect rect = CGRectMake(0.0, 0.0, aSize.width, aSize.height);
	UIGraphicsBeginImageContext(rect.size);
	[aInImage drawInRect:rect];
	UIImage *resImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return resImage;
}

+ (BOOL) writeToImage:(UIImage*)aImage toFileAtPath:(NSString *)aFilePath
{
    if ( (aImage == nil) || (aFilePath == nil) ) {
        return NO;
    }
    
    @try {
        NSData *imageData = nil;
        NSString *ext = [aFilePath pathExtension];
        if ([ext isEqualToString:@"jpeg"]) {
            // 0. best  1. lost 
            imageData = UIImageJPEGRepresentation(aImage, 0);
        }
        
        if ( (imageData == nil) || ([imageData length] <= 0)) {
            return NO;
        }
        
        [imageData writeToFile:aFilePath atomically:YES];
        
        return YES;
    }
    @catch (NSException *exception) {
        NSLog(@"create file exception.");
    }

    return NO;
}

@end
