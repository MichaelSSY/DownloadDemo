//
//  UIUtil.h
//  DownloadDemo
//
//  Created by weiyun on 2018/1/12.
//  Copyright © 2018年 wy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define SCREEN_WIDTH  [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface UIUtil : NSObject

// 获取缓存文件夹路径
+ (NSString *)getCachesPath;

// 创建文件夹
+ (void)creatCachesPath;

// 下载文件存储路径
+ (NSString *)getFileDataPathWithUrl:(NSString *)url;

// 获取已下载长度
+ (NSInteger)getDownloadFileLengthPathWithUrl:(NSString *)url;

// 存储文件总长度的文件路径.plist
+ (NSString *)getDownloadFileTotalLength;

@end
