//
//  LXServiceManager.h
//  LXIntercom
//
//  Created by 余志杰 on 17/4/20.
//  Copyright © 2017年 LX. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^LXServiceResult)(id succeed,NSError *error);

typedef enum : NSUInteger {
    LXHttpMethodPOST,
    LXHttpMethodGET,
} LXHttpMethod;

static NSString  *kStateKey =  @"state";
static NSString  *kMsgKey = @"msg";
static NSString  *kDataKey = @"info";


@interface LXServiceManager : NSObject



/**
 * AF数据请求
 */
+(void)requestAFURL:(NSString *)URLString
         httpMethod:(LXHttpMethod)method
         parameters:(id)parameters
            succeed:(void (^)(id))succeed
            failure:(void (^)(NSError *))failure;


/**
 * 上传单张图片
 */
+(void)requestAFURL:(NSString *)URLString
         parameters:(id)parameters
          imageData:(NSData *)imageData
            succeed:(void (^)(id))succeed
            failure:(void (^)(NSError *))failure;


/**
 * 上传多张图片
 */
+(void)requestAFURL:(NSString *)URLString
         parameters:(id)parameters
     imageDataArray:(NSArray *)imageDataArray
            succeed:(void (^)(id))succeed
            failure:(void (^)(NSError *))failure;

/**
 * 上传文件
 */
+(void)requestAFURL:(NSString *)URLString
         parameters:(id)parameters
           fileData:(NSData *)fileData
            succeed:(void (^)(id))succeed
            failure:(void (^)(NSError *))failure;

/*json
 * @brief 把格式化的JSON格式的字符串转换成字典
 * @param jsonString JSON格式的字符串
 * @return 返回字典
 */
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;


/*json
 * @brief 把字典转换成字符串
 * @param jsonString JSON格式的字符串
 * @return 返回字符串
 */
+(NSString*)URLEncryOrDecryString:(NSDictionary *)paramDict IsHead:(BOOL)_type;

+ (void)getUrl:(NSString *)url result:(LXServiceResult)result;
+ (void)postUrl:(NSString *)url  result:(LXServiceResult)result;

+ (void)getUrl:(NSString *)url params:(id)params  result:(LXServiceResult)result;
+ (void)postUrl:(NSString *)url params:(id)params  result:(LXServiceResult)result;
+ (void)callResult:(LXServiceResult)serviceResult withSucceed:(id)succeed failure:(NSError *)error;

@end
