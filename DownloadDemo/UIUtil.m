//
//  UIUtil.m
//  DownloadDemo
//
//  Created by weiyun on 2018/1/12.
//  Copyright © 2018年 wy. All rights reserved.
//

#import "UIUtil.h"

@implementation UIUtil

+ (NSString *)getCachesPath
{
    return [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"FileCache"];
}

+ (void)creatCachesPath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:[self getCachesPath]]) {
        [fileManager createDirectoryAtPath:[self getCachesPath] withIntermediateDirectories:YES attributes:nil error:NULL];
    }
}

+ (NSString *)getFileDataPathWithUrl:(NSString *)url
{
    return [[self getCachesPath] stringByAppendingPathComponent:url];
}

+ (NSInteger)getDownloadFileLengthPathWithUrl:(NSString *)url
{
    return [[[NSFileManager defaultManager] attributesOfItemAtPath:[self getFileDataPathWithUrl:url] error:nil][NSFileSize] integerValue];
}

+ (NSString *)getDownloadFileTotalLength
{
    return [[self getCachesPath] stringByAppendingPathComponent:@"totalLength.plist"];
}

@end
