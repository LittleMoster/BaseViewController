//
//  HTTPCache.h
//  HTTPAF
//
//  Created by cguo on 2017/6/7.
//  Copyright © 2017年 zjq. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *网络数据缓存工具类
 */

@interface HTTPCache : NSObject

/**
 *  缓存网络数据
 *
 *  @param httpCache 服务器返回的数据
 *  @param key           缓存数据对应的key值,推荐填入请求的URL
 */
+ (void)saveHttpCache:(id)httpCache forKey:(NSString *)key;

/**
 *  取出缓存的数据
 *
 *  @param key 根据存入时候填入的key值来取出对应的数据
 *
 *  @return 缓存的数据
 */
+ (id)getHttpCacheForKey:(NSString *)key;

/**
 *  获取网络缓存的总大小 bytes(字节)
 */
+ (NSInteger)getAllHttpCacheSize;


/**
 *  删除所有网络缓存,
 */
+ (void)removeAllHttpCache;

@end
