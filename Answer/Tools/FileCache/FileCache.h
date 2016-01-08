//
//  FileCache.h
//
//
//  Created by wuyj on 15/12/03.
//  Copyright (c) 2015年 wuyj. All rights reserved.
//
//  仿SDImageCache编写

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface FileCache : NSObject

/**
 * 内存消耗大小
 */
@property(assign, nonatomic) NSInteger maxMemeryCacheCost;
/**
 * 磁盘缓存生命值
 */
@property(assign, nonatomic) NSInteger maxCacheAge;
/**
 * 磁盘缓存区大小
 */
@property(assign, nonatomic) NSInteger maxCacheSize;

+ (FileCache *)sharedFileCache;
/**
 * 工厂方式：生成一个全局的唯一的fileKey，使用者也可以自己定义生成fileKey
 */
+ (NSString *)fileKey;

/**
 * 向缓存中写数据
 */
- (void)writeData:(NSData *)data forKey:(NSString *)key;

- (void)writeData:(NSData *)data path:(NSString *)path;

/**
 * 从缓存中获取数据
 */
- (NSData *)dataFromCacheForKey:(NSString *)key;

/**
 * 从缓存中获取数据
 */
- (NSData *)dataFromCacheForPath:(NSString *)path;

/**
 * 文件路径
 */
- (NSString *)diskCachePathForKey:(NSString *)key;

/**
 * 清除内存缓存数据
 */
- (void)cleanCacheMemory;

- (void)removeFileForKey:(NSString *)key;
- (void)removeFileForPath:(NSString *)path;

@end
