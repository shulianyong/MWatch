//
//  DownLoadUtil.m
//  STB
//
//  Created by shulianyong on 13-11-30.
//  Copyright (c) 2013年 Chengdu Sifang Information Technology Co.LTD. All rights reserved.
//

#import "DownLoadUtil.h"

@implementation DownLoadUtil

static NSString *httpString = @"http://122.227.52.54:8088/";

+ (void)downFile:(NSString*)aFileName
 withLocFileName:(NSString*)aLocFileName
withProcessBlock:(DownLoadProcess)processBlock
withDownSuccessBlock:(dispatch_block_t)successBlock
withDownFailBlck:(dispatch_block_t)failBlock
{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSString *fileDownPath = [httpString stringByAppendingString:aFileName];
    NSURL *URL = [NSURL URLWithString:fileDownPath];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    
   
    __block NSProgress *downProgress = nil;
    [manager setDownloadTaskDidWriteDataBlock:^(NSURLSession *session, NSURLSessionDownloadTask *downloadTask, int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
        
        float progressValue = 1.0f*downProgress.completedUnitCount/downProgress.totalUnitCount;
        INFO(@"downProgress.totalUnitCount:%lld  downProgress.completedUnitCount:%lld  progress:%f",downProgress.totalUnitCount,downProgress.completedUnitCount,progressValue);
        processBlock(progressValue);
    }];
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request
                                                                     progress:&downProgress
                                                                  destination:^NSURL *(NSURL *targetPath, NSURLResponse *response)
    {
        NSString *saveFilePath = [NSString cacheFolderPath];
        saveFilePath = [saveFilePath stringByAppendingPathComponent:aLocFileName];
        if ([[NSFileManager defaultManager] fileExistsAtPath:saveFilePath]) {
            NSError *error = nil;
            [[NSFileManager defaultManager] removeItemAtPath:saveFilePath error:&error];
        }
        NSURL *fileSaveURL = [NSURL fileURLWithPath:saveFilePath];
        
        return fileSaveURL;
    }
                                                            completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error)
    {
        if (error)
        {
            failBlock();
        }
        else
        {
            successBlock();
            NSLog(@"File downloaded to: %@", filePath);
        }
    }];
    
    @try {
        [downloadTask resume];
    }
    @catch (NSException *exception) {
        failBlock();
    }
}


@end
