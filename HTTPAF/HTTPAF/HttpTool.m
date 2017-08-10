//
//  HttpTool.m
//  HTTPAF
//
//  Created by cguo on 2017/5/27.
//  Copyright © 2017年 zjq. All rights reserved.
//

#import "HttpTool.h"
#import "HTTPCache.h"
#import "AFNetworking.h"
#import "AFNetworkActivityIndicatorManager.h"


#ifdef DEBUG
#define PPLog(...) NSLog(@"%s 第%d行 \n %@\n\n",__func__,__LINE__,[NSString stringWithFormat:__VA_ARGS__])
#else
#define PPLog(...)
#endif


@implementation HttpTool

static NetworkStatus _status;
static BOOL _isNetwork;

#pragma mark - 开始监听网络
+ (void)startMonitoringNetwork
{
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status)
        {
            case AFNetworkReachabilityStatusUnknown:
                _status ? _status(PPNetworkStatusUnknown) : nil;
                _isNetwork = NO;
                PPLog(@"未知网络");
                break;
            case AFNetworkReachabilityStatusNotReachable:
                _status ? _status(PPNetworkStatusNotReachable) : nil;
                _isNetwork = NO;
                PPLog(@"无网络");
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
                _status ? _status(PPNetworkStatusReachableViaWWAN) : nil;
                _isNetwork = YES;
                PPLog(@"手机自带网络");
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
                _status ? _status(PPNetworkStatusReachableViaWiFi) : nil;
                _isNetwork = YES;
                PPLog(@"WIFI");
                break;
        }
    }];
    [manager startMonitoring];
    
}

+ (void)checkNetworkStatusWithBlock:(NetworkStatus)status
{
    status ? _status = status : nil;
}

+ (BOOL)currentNetworkStatus
{
    return _isNetwork;
}

#pragma mark - GET请求无缓存

+ (NSURLSessionTask *)GET:(NSString *)URL
               parameters:(NSDictionary *)parameters
                  success:(HttpRequestSuccess)success
                  failure:(HttpRequestFailed)failure
{
    return [self GET:URL parameters:parameters responseCache:nil success:success failure:failure];
}


#pragma mark - POST请求无缓存

+ (NSURLSessionTask *)POST:(NSString *)URL
                parameters:(NSDictionary *)parameters
                   success:(HttpRequestSuccess)success
                   failure:(HttpRequestFailed)failure
{
    return [self POST:URL parameters:parameters responseCache:nil success:success failure:failure];
}


#pragma mark - GET请求自动缓存

+ (NSURLSessionTask *)GET:(NSString *)URL
               parameters:(NSDictionary *)parameters
            responseCache:(HttpRequestCache)responseCache
                  success:(HttpRequestSuccess)success
                  failure:(HttpRequestFailed)failure
{
    //读取缓存
    responseCache ? responseCache([HTTPCache getHttpCacheForKey:URL]) : nil;
    
    AFHTTPSessionManager *manager = [self createAFHTTPSessionManager];
    return [manager GET:URL parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        success ? success(responseObject) : nil;
        //对数据进行异步缓存
        responseCache ? [HTTPCache saveHttpCache:responseObject forKey:URL] : nil;
        
        PPLog(@"responseObject = %@",responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        failure ? failure(error) : nil;
        PPLog(@"error = %@",error);
        
    }];
}


#pragma mark - POST请求自动缓存

+ (NSURLSessionTask *)POST:(NSString *)URL
                parameters:(NSDictionary *)parameters
             responseCache:(HttpRequestCache)responseCache
                   success:(HttpRequestSuccess)success
                   failure:(HttpRequestFailed)failure
{
    //读取缓存
    responseCache ? responseCache([HTTPCache getHttpCacheForKey:URL]) : nil;
    
    AFHTTPSessionManager *manager = [self createAFHTTPSessionManager];
    return [manager POST:URL parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        success ? success(responseObject) : nil;
        //对数据进行异步缓存
        responseCache ? [HTTPCache saveHttpCache:responseObject forKey:URL] : nil;
        
        PPLog(@"responseObject = %@",responseObject);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        failure ? failure(error) : nil;
        PPLog(@"error = %@",error);
    }];
    
}

#pragma mark - 上传图片文件

+ (NSURLSessionTask *)uploadWithURL:(NSString *)URL
                         parameters:(NSDictionary *)parameters
                             images:(NSArray<UIImage *> *)images
                               name:(NSString *)name
                           fileName:(NSString *)fileName
                           mimeType:(NSString *)mimeType
                           progress:(HttpProgress)progress
                            success:(HttpRequestSuccess)success
                            failure:(HttpRequestFailed)failure
{
    
    AFHTTPSessionManager *manager = [self createAFHTTPSessionManager];
    return [manager POST:URL parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        //压缩-添加-上传图片
        [images enumerateObjectsUsingBlock:^(UIImage * _Nonnull image, NSUInteger idx, BOOL * _Nonnull stop) {
            
            NSData *imageData = UIImageJPEGRepresentation(image, 0.5);
            [formData appendPartWithFileData:imageData name:name fileName:[NSString stringWithFormat:@"%@%lu.%@",fileName,(unsigned long)idx,mimeType?mimeType:@"jpeg"] mimeType:[NSString stringWithFormat:@"image/%@",mimeType?mimeType:@"jpeg"]];
        }];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        //上传进度
        progress ? progress(uploadProgress) : nil;
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        success ? success(responseObject) : nil;
        PPLog(@"responseObject = %@",responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        failure ? failure(error) : nil;
        PPLog(@"error = %@",error);
    }];
}

#pragma mark - 下载文件
+ (NSURLSessionTask *)downloadWithURL:(NSString *)URL
                              fileDir:(NSString *)fileDir
                             progress:(HttpProgress)progress
                              success:(void(^)(NSString *))success
                              failure:(HttpRequestFailed)failure
{
    AFHTTPSessionManager *manager = [self createAFHTTPSessionManager];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:URL]];
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        //下载进度
        progress ? progress(downloadProgress) : nil;
        PPLog(@"下载进度:%.2f%%",100.0*downloadProgress.completedUnitCount/downloadProgress.totalUnitCount);
        
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        
        //拼接缓存目录
        NSString *downloadDir = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:fileDir ? fileDir : @"Download"];
        //打开文件管理器
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        //创建Download目录
        [fileManager createDirectoryAtPath:downloadDir withIntermediateDirectories:YES attributes:nil error:nil];
        
        //拼接文件路径
        NSString *filePath = [downloadDir stringByAppendingPathComponent:response.suggestedFilename];
        
        PPLog(@"downloadDir = %@",downloadDir);
        
        //返回文件位置的URL路径
        return [NSURL fileURLWithPath:filePath];
        
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        
        success ? success(filePath.absoluteString /** NSURL->NSString*/) : nil;
        failure && error ? failure(error) : nil;
        
    }];
    
    //开始下载
    [downloadTask resume];
    
    return downloadTask;
    
}


#pragma mark - 设置AFHTTPSessionManager相关属性

+ (AFHTTPSessionManager *)createAFHTTPSessionManager
{
    //打开状态栏的等待菊花
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //设置请求参数的类型:HTTP (AFJSONRequestSerializer,AFHTTPRequestSerializer)
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    //设置请求的超时时间
    manager.requestSerializer.timeoutInterval = 30.f;
    //设置服务器返回结果的类型:JSON (AFJSONResponseSerializer,AFHTTPResponseSerializer)
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithArray:@[@"application/json",
                                                                              @"text/html",
                                                                              @"text/json",
                                                                              @"text/plain",
                                                                              @"text/javascript",
                                                                              @"text/xml",
                                                                              @"image/*"]];
    
    //HTTPS证书验证
   // manager.securityPolicy=[self policy];
    //如果是双向认证则重写NSURLSesson的代理方法(取消下面的注释就可以)
    //    [self setSessionDidReceiveAuthenticationChallengeWithManager:manager];
    return manager;
}

/*
 *afnetworking 使用字签证证书访问HTTPS
 * 把服务器给你的自签证的证书放入bundle一般是.cer文件
 * 创建afnnetworking 安全策略对象,并设置发起请求manager的安全策略属性.设置了安全策略属性,afnnetworking会自动扫描bundl里的证书.
 */

+ (AFSecurityPolicy *)policy{
    //根证书路径
    NSString * path = [[NSBundle mainBundle] pathForResource:@"xiaoxun" ofType:@"cer"];
    NSLog(@"%@",path);
    //
    NSData * cerData = [NSData dataWithContentsOfFile:path];
    //
    NSSet * dataSet = [NSSet setWithObject:cerData];
    //AFNetworking验证证书的object
    AFSecurityPolicy * policy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate withPinnedCertificates:dataSet];
    //是否可以使用自建证书（不花钱的）
    policy.allowInvalidCertificates=YES;
    //是否验证域名（一般不验证）
    policy.validatesDomainName=NO;
    policy.pinnedCertificates = @[cerData];
    return policy;
    
}
+ (void)setSessionDidReceiveAuthenticationChallengeWithManager:(AFHTTPSessionManager *)manager{
    
    __weak typeof(manager)weakManager = manager;
    __weak typeof(self)weakSelf = self;
    
    
    [manager setSessionDidReceiveAuthenticationChallengeBlock:^NSURLSessionAuthChallengeDisposition(NSURLSession*session, NSURLAuthenticationChallenge *challenge, NSURLCredential *__autoreleasing*_credential) {
        NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengePerformDefaultHandling;
        __autoreleasing NSURLCredential *credential =nil;
        
        
        if([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
            NSLog(@"验证服务器1");
            if([weakManager.securityPolicy evaluateServerTrust:challenge.protectionSpace.serverTrust forDomain:challenge.protectionSpace.host]) {
                NSLog(@"验证服务器2");
                
                credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
                if(credential) {
                    NSLog(@"验证服务器3");
                    disposition =NSURLSessionAuthChallengeUseCredential;
                } else {
                    NSLog(@"验证服务器4");
                    
                    disposition =NSURLSessionAuthChallengePerformDefaultHandling;
                }
            } else {
                NSLog(@"验证服务器5");
                
                disposition = NSURLSessionAuthChallengeCancelAuthenticationChallenge;
            }
        } else {
            NSLog(@"验证客户端1");
            
            // client authentication
            SecIdentityRef identity = NULL;
            SecTrustRef trust = NULL;
            NSString *p12 = [[NSBundle mainBundle] pathForResource:@"client"ofType:@"p12"];
            NSFileManager *fileManager =[NSFileManager defaultManager];
            
            if(![fileManager fileExistsAtPath:p12])
            {
                NSLog(@"client.p12:not exist");
            }
            else
            {
                NSLog(@"验证客户端2");
                
                NSData *PKCS12Data = [NSData dataWithContentsOfFile:p12];
                
                if ([[weakSelf class]extractIdentity:&identity andTrust:&trust fromPKCS12Data:PKCS12Data])
                {
                    NSLog(@"验证客户端3");
                    
                    SecCertificateRef certificate = NULL;
                    SecIdentityCopyCertificate(identity, &certificate);
                    const void*certs[] = {certificate};
                    CFArrayRef certArray =CFArrayCreate(kCFAllocatorDefault, certs,1,NULL);
                    credential =[NSURLCredential credentialWithIdentity:identity certificates:(__bridge  NSArray*)certArray persistence:NSURLCredentialPersistencePermanent];
                    disposition =NSURLSessionAuthChallengeUseCredential;
                }
                
            }
        }
        *_credential = credential;
        return disposition;
    }];
}

+ (BOOL)extractIdentity:(SecIdentityRef*)outIdentity andTrust:(SecTrustRef *)outTrust fromPKCS12Data:(NSData *)inPKCS12Data {
    OSStatus securityError = errSecSuccess;
    //客户端证书密码
    NSDictionary*optionsDictionary = [NSDictionary dictionaryWithObject:@"123456" forKey:(__bridge id)kSecImportExportPassphrase];
    
    CFArrayRef items = CFArrayCreate(NULL, 0, 0, NULL);
    securityError = SecPKCS12Import((__bridge CFDataRef)inPKCS12Data,(__bridge CFDictionaryRef)optionsDictionary,&items);
    
    if(securityError == 0) {
        CFDictionaryRef myIdentityAndTrust =CFArrayGetValueAtIndex(items,0);
        const void*tempIdentity =NULL;
        tempIdentity= CFDictionaryGetValue (myIdentityAndTrust,kSecImportItemIdentity);
        *outIdentity = (SecIdentityRef)tempIdentity;
        const void*tempTrust =NULL;
        tempTrust = CFDictionaryGetValue(myIdentityAndTrust,kSecImportItemTrust);
        *outTrust = (SecTrustRef)tempTrust;
    } else {
        NSLog(@"Failedwith error code %d",(int)securityError);
        return NO;
    }
    return YES;
}


@end
