//
//  FileCache.h
//
//
//  Created by wuyj on 15/12/03.
//  Copyright (c) 2015年 wuyj. All rights reserved.
//

#import "FileCache.h"
#import <UIKit/UIKit.h>
#import <CommonCrypto/CommonDigest.h>

#define MEMORY_CACHE_NAME               @"com.weimeitc.Filecache"
#define DISK_CACHE_NAMESPACE            @"com.weimeitc.Filecache"
#define DISPATCH_QUEUE_CAHCE            "com.weimeitc.FileCacheQueue"


static const NSInteger kCacheMaxAge = 60 * 60 * 24 * 7; //每周清除一次
@interface FileCache (){
    NSFileManager *_fileManager;
}

@property(strong, nonatomic) NSCache            *memoryCache;
@property(strong, nonatomic) dispatch_queue_t   rwQueue;
@property(copy, nonatomic) NSString             *diskCachePath;

@end

@implementation FileCache

+ (NSString *)fileKey {
    
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    CFStringRef cfstring = CFUUIDCreateString(kCFAllocatorDefault, uuid);
    const char *cStr = CFStringGetCStringPtr(cfstring,CFStringGetFastestEncoding(cfstring));
    unsigned char result[16];
    CC_MD5( cStr, (unsigned int)strlen(cStr), result );
    CFRelease(uuid);
    
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%08lx",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15],
            (unsigned long)(arc4random() % NSUIntegerMax)];
}


+ (FileCache *)sharedFileCache {
    static dispatch_once_t onceToken;
    static id instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc]init];
        
    });
    return instance;
    
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _memoryCache = [[NSCache alloc]init];
        _memoryCache.name = MEMORY_CACHE_NAME;
        _maxCacheAge = kCacheMaxAge;
        _maxCacheSize = 1024*1024*200;
        _rwQueue = dispatch_queue_create(DISPATCH_QUEUE_CAHCE, DISPATCH_QUEUE_SERIAL);
        _diskCachePath = [self createDiskCachePathWithNamespace:DISK_CACHE_NAMESPACE];
        dispatch_sync(_rwQueue, ^{
            _fileManager = [[NSFileManager alloc]init];
            
            if (![_fileManager fileExistsAtPath:_diskCachePath]) {
                [_fileManager createDirectoryAtPath:_diskCachePath withIntermediateDirectories:YES attributes:nil error:NULL];
            }
        });
        
#if TARGET_OS_IPHONE
        // 系统通知处理
        [[NSNotificationCenter defaultCenter]addObserver:self
                                                selector:@selector(cleanCacheMemory)
                                                    name:UIApplicationDidReceiveMemoryWarningNotification
                                                  object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self
                                                selector:@selector(cleanCacheDisk)
                                                    name:UIApplicationDidEnterBackgroundNotification
                                                  object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(cleanCacheDisk)
                                                     name:UIApplicationWillTerminateNotification
                                                   object:nil];
    }
#endif
    return self;
}

- (void)writeData:(NSData *)data forKey:(NSString *)key {
    if (!data||!key) {
        return;
    }
    
    // 放入内存中
    [self.memoryCache setObject:data forKey:key];
    // 放入磁盘中
    dispatch_async(_rwQueue, ^{
        if (![_fileManager fileExistsAtPath:_diskCachePath]) {
            [_fileManager createDirectoryAtPath:_diskCachePath withIntermediateDirectories:YES attributes:nil error:NULL];
        }
        [_fileManager createFileAtPath:[self diskCachePathForKey:key] contents:data attributes:nil];
    });
}

- (NSData *)dataFromCacheForKey:(NSString *)key {
    // 检查缓存中是否有该二进制数据
    id data = [self.memoryCache objectForKey:key];
    if (data) {
        return data;
    }
    
    
    // 检查硬盘中该二进制数据
    NSData *diskData = [self dataFromDiskForKey:key];
    if (diskData) {
        // 置入缓存数据
        [self.memoryCache setObject:diskData forKey:key];
        return diskData;
    }
    return nil;
}


#pragma mark - private func
- (NSString *)md5FileNameForKey:(NSString *)key {
    const char *str = [key UTF8String];
    if (str == NULL) {
        str = "";
    }
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), r);
    NSString *filename = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x", r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11], r[12], r[13], r[14], r[15]];
    
    return filename;
}

- (NSString *)diskCachePathForKey:(NSString *)key {
    NSString *filename = [self md5FileNameForKey:key];
    NSString *filepath = [self.diskCachePath stringByAppendingPathComponent:filename];
    return filepath;
}

- (NSData *)dataFromDiskForKey:(NSString *)key {

    NSString *filepath = [self diskCachePathForKey:key];
    NSData *data = [NSData dataWithContentsOfFile:filepath];
    if (data) {
        return data;
    }
    return nil;
}

- (void)removeFileForKey:(NSString *)key {
    
    if (key == nil) {
        return;
    }
    
    [self.memoryCache removeObjectForKey:key];
    
    dispatch_async(self.rwQueue, ^{
        [_fileManager removeItemAtPath:[self diskCachePathForKey:key] error:nil];
    });
}

#pragma mark - notification func
/**
 * 虽然NSCache会在内存吃紧的时候进行清空，但是不确定时机，在这里额外加上内存清空处理
 */
- (void)cleanCacheMemory {
    [self.memoryCache removeAllObjects];
}

/**
 * 对于磁盘缓存数据进行清理，此函数的调用时机有待考虑
 */
- (void)cleanCacheDisk {
    dispatch_async(self.rwQueue, ^{
        NSURL *diskCacheURL = [NSURL fileURLWithPath:self.diskCachePath isDirectory:YES];
        NSArray *resourceKeys = @[NSURLIsDirectoryKey, NSURLContentModificationDateKey, NSURLTotalFileAllocatedSizeKey];
        NSDirectoryEnumerator *fileEnumerator = [_fileManager enumeratorAtURL:diskCacheURL
                                                   includingPropertiesForKeys:resourceKeys
                                                                      options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                 errorHandler:NULL];
        
        NSDate *expirationDate = [NSDate dateWithTimeIntervalSinceNow:-self.maxCacheAge];
        NSMutableDictionary *cacheFiles = [NSMutableDictionary dictionary];
        NSUInteger currentCacheSize = 0;
        NSMutableArray *urlsToDelete = [[NSMutableArray alloc] init];
        for (NSURL *fileURL in fileEnumerator) {
            NSDictionary *resourceValues = [fileURL resourceValuesForKeys:resourceKeys error:NULL];
            // 跳过
            if ([resourceValues[NSURLIsDirectoryKey] boolValue]) {
                continue;
            }
            // 删除过期文件
            NSDate *modificationDate = resourceValues[NSURLContentModificationDateKey];
            if ([[modificationDate laterDate:expirationDate] isEqualToDate:expirationDate]) {
                [urlsToDelete addObject:fileURL];
                continue;
            }
            NSNumber *totalAllocatedSize = resourceValues[NSURLTotalFileAllocatedSizeKey];
            currentCacheSize += [totalAllocatedSize unsignedIntegerValue];
            [cacheFiles setObject:resourceValues forKey:fileURL];
        }
        for (NSURL *fileURL in urlsToDelete) {
            [_fileManager removeItemAtURL:fileURL error:nil];
        }
        if (self.maxCacheSize > 0 && currentCacheSize > self.maxCacheSize) {
            const NSUInteger desiredCacheSize = self.maxCacheSize / 2;
            NSArray *sortedFiles = [cacheFiles keysSortedByValueWithOptions:NSSortConcurrent
                                                            usingComparator:^NSComparisonResult(id obj1, id obj2) {
                                                                return [obj1[NSURLContentModificationDateKey] compare:obj2[NSURLContentModificationDateKey]];
                                                            }];
            for (NSURL *fileURL in sortedFiles) {
                if ([_fileManager removeItemAtURL:fileURL error:nil]) {
                    NSDictionary *resourceValues = cacheFiles[fileURL];
                    NSNumber *totalAllocatedSize = resourceValues[NSURLTotalFileAllocatedSizeKey];
                    currentCacheSize -= [totalAllocatedSize unsignedIntegerValue];
                    
                    if (currentCacheSize < desiredCacheSize) {
                        break;
                    }
                }
            }
        }
    });
}


-(NSString *)createDiskCachePathWithNamespace:(NSString *)namespace {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    return [paths[0] stringByAppendingPathComponent:namespace];
}
@end
