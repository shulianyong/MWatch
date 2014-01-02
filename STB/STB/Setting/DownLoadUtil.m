//
//  DownLoadUtil.m
//  STB
//
//  Created by shulianyong on 13-11-30.
//  Copyright (c) 2013年 Chengdu Sifang Information Technology Co.LTD. All rights reserved.
//

#import "DownLoadUtil.h"
#import "../../../ASIHTTP/ASIHTTP/ASIHTTPRequest.h"

@implementation DownLoadUtil

static NSString *httpString = @"http://122.227.52.54:8088/";

+ (void)downFile7:(NSString*)aFileName
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


static ASIHTTPRequest *request = nil;
+ (void)downFile:(NSString*)aFileName
 withLocFileName:(NSString*)aLocFileName
withProcessBlock:(DownLoadProcess)processBlock
withDownSuccessBlock:(dispatch_block_t)successBlock
withDownFailBlck:(dispatch_block_t)failBlock
{
    INFO(@"current version:%f",[UIDevice currentDevice].systemVersion.doubleValue);
    if ([UIDevice currentDevice].systemVersion.doubleValue>6.1) {
        [self downFile7:aFileName
       withLocFileName:aLocFileName
      withProcessBlock:processBlock
  withDownSuccessBlock:successBlock
      withDownFailBlck:failBlock];
        return;
    }
    
    NSString *fileDownPath = [httpString stringByAppendingString:aFileName];
    NSURL *URL = [NSURL URLWithString:fileDownPath];
    request = [ASIHTTPRequest requestWithURL:URL];
    request.timeOutSeconds = 5*60;
    
    static unsigned long long progressSize = 0;
    progressSize = 0;
    [request setBytesReceivedBlock:^(unsigned long long size, unsigned long long total) {
        progressSize+=size;
        float progressValue = 1.0f*progressSize/total;
        INFO(@"downProgress   size:%llu  progressSize:%llu   total:%llu  progressValue:%f",size,progressSize,total,progressValue);
        processBlock(progressValue);
    }];
    
    [request setCompletionBlock:^{
        INFO(@"CompletionBlock");
        successBlock();
    }];
    
    [request setFailedBlock:^{
        INFO(@"FailedBlock:%@",request.error);
        
        failBlock();
    }];
    //当request完成时，整个文件会被移动到这里
    NSString *saveFilePath = [NSString cacheFolderPath];
    saveFilePath = [saveFilePath stringByAppendingPathComponent:aLocFileName];
    [request setDownloadDestinationPath:saveFilePath];
    
    NSString *tempFilePath = NSTemporaryDirectory();
    tempFilePath = [tempFilePath stringByAppendingPathComponent:aLocFileName];
    [request setTemporaryFileDownloadPath:tempFilePath];
    [request startAsynchronous];
}

@end
