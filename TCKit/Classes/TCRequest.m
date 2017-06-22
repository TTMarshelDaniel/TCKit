//
//  Created by T T Marshel Daniel on 05/05/2017.
//
//  Created by T T Marshel Daniel on 07/07/2017.
//

#import "TCRequest.h"

NSInteger const TCErrorCode = 1;

typedef void(^TCRequestCompletion)(__kindof TCObject *Object, NSError *error);

@interface TCRequestBase ()
//
@property (nonatomic, strong, readwrite) NSURL *url;
@property (nonatomic, strong, readwrite) NSMutableDictionary *dictionary;
@property (nonatomic, readwrite, copy) TCRequestCompletion completion;
@property (nonatomic, strong) NSURLSessionDataTask *task;

-(NSURL *)encodedURL;
-(void)_manipulateData:(NSData *)data response:(NSHTTPURLResponse *)response error:(NSError *)error;
-(void)_executeCompletionWithDictionary:(NSDictionary *)dictionary error:(NSError *)error;
-(NSString *)_formattedStringFromNSData:(NSData *)data;
-(NSDictionary *)_parseData:(NSData *)data;

@end

@interface TCNSURLSession : NSObject <NSURLSessionDelegate,NSURLSessionDataDelegate>

@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic)dispatch_queue_t queue;
+(instancetype)sharedSession;

@end
//
//@interface TCRequest ()
//
//@end
//
//@interface TCRequestMultiPart ()
//@property (nonatomic, strong, readwrite) NSURL *url;
//@end

@implementation TCRequestBase

-(void)GET:(void(^__nonnull)(__kindof TCObject *__nullable Object, NSError *__nullable error))completion { return; }
-(void)POST:(void(^__nonnull)(__kindof TCObject *__nullable Object, NSError *__nullable error))completion { return; }

-(NSMutableDictionary *)dictionary {
    //
    if (_dictionary) return _dictionary;
    //
    self.dictionary = [NSMutableDictionary dictionary];
    return _dictionary;
}

- (id)objectForKeyedSubscript:(id)key {
    //
    id obj = self.dictionary[key];
    if ([obj isKindOfClass:[NSNull class]]) return nil;
    //
    return obj;
}

- (void)setObject:(id)obj forKeyedSubscript:(id <NSCopying>)key {
    //
    if (!key) return;
    //
    if (obj) self.dictionary[key] = obj;
    else [self.dictionary removeObjectForKey:key];
}

-(TCObject *__nullable)resultObjectWith:(id<TCObjectable> __nonnull)object {
    //
    return [TCObject objectWith:object];
}

-(void)_manipulateData:(NSData *)data response:(NSHTTPURLResponse *)response error:(NSError *)error  {
    //
    void(^execute)(NSDictionary *, NSError *) = ^(NSDictionary *d, NSError *e) {
        //
        [self _executeCompletionWithDictionary:d error:e];
    };
    //
    if (error) { execute(nil, error); return; }
    if (!data) { execute(nil, [NSError errorWithDomain:@"Null data" code:TCErrorCode userInfo:nil]); return; }
    NSDictionary *dictionary = [self _parseData:data];
    if (!dictionary) { execute(nil, [NSError errorWithDomain:@"Invalid data" code:TCErrorCode userInfo:nil]); return; }
    //
    execute(dictionary, nil);
}

-(void)_executeCompletionWithDictionary:(NSDictionary *)dictionary error:(NSError *)error {
    //
    if (!self.completion) return;
    __typeof(self) weakSelf = self;
    //
    dispatch_async([[TCNSURLSession sharedSession] queue], ^{
        //
        @autoreleasepool {
            //
            if (error || !dictionary) { weakSelf.completion(nil, error); return ; }
            //
            TCObject *obj = [weakSelf resultObjectWith:dictionary];
            //
            if (obj) {
                if (weakSelf.completion) weakSelf.completion(obj, nil);
            } else {
                if (weakSelf.completion) weakSelf.completion(nil, [NSError errorWithDomain:@"Empty Object" code:0 userInfo:nil]);
            }
        }
    });
}

-(NSString *)_formattedStringFromNSData:(NSData *)data {
    //
    return TCDataToJSONString(data);
}


-(NSDictionary *)_parseData:(NSData *)data {
    //
    return TCDataToJSONDictionary(data);
}

-(NSURL *)encodedURL {
    //
    NSDictionary *dictionary = self.dictionary;
    NSArray *allKeys = [dictionary allKeys];
    NSString *querry = @"?";
    //
    for (id key in allKeys) {
        //
        id value = dictionary[key];
        querry = [NSString stringWithFormat:@"%@%@=%@&",querry, key, value];
    }
    //
    querry = [querry substringToIndex:[querry length]-1];
    NSString *urlString = [NSString stringWithFormat:@"%@%@", [self url].absoluteString, querry];
    NSString *encodedString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    //
    return [NSURL URLWithString:encodedString];
}

@end


@implementation TCRequest

+(instancetype)requestWithURL:(NSURL *)url {
    //
    if (!url) return nil;
    //
    TCRequest *request = [[[self class] alloc] init];
    request.url = url;
    return request;
}

-(void)cancel:(void (^)(void))completion {
    //
    self.completion = nil;
    if (completion) completion();
    
    [self.task cancel];
}

-(void)GET:(void(^)(__kindof TCObject *Object, NSError *error))completion {
    //
    self.completion = completion;
    __typeof(self) weakSelf = self;
    self.url = [self encodedURL];
    //
    NSURLSessionDataTask *task = [self _getToURL:self.url completion:^(NSData *data, NSHTTPURLResponse *response, NSError *error) {
        //
        [weakSelf _manipulateData:data response:response error:error];
    }];
    //
    [task resume];
    //
    self.task = task;
}

-(void)POST:(void(^)(__kindof TCObject *Object, NSError *error))completion {
    //
    self.completion = completion;
    NSURL *url = [self url];
    NSData *encodedData = [self encodedData];
    __typeof(self) weakSelf = self;
    //
    NSURLSessionDataTask *task = [self _post:encodedData toURL:url completion:^(NSData *data, NSHTTPURLResponse *response, NSError *error) {
        //
        [weakSelf _manipulateData:data response:response error:error];
    }];
    //
    [task resume];
    self.task = task;
}

-(NSURLSessionDataTask *)_getToURL:(NSURL *)url completion:(void (^)(NSData *data, NSHTTPURLResponse *response, NSError *error))completion {
    //
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    if (_timeOut > 30) { request.timeoutInterval = _timeOut; }
    else { request.timeoutInterval = 85; }
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    request.HTTPMethod = @"GET";
    //
    return [self _dataTaskWithRequest:request completion:completion];
}

-(NSURLSessionDataTask *)_dataTaskWithRequest:(NSURLRequest *)request completion:(void (^)(NSData *data, NSHTTPURLResponse *response, NSError *error))completion {
    //
    NSURLSessionDataTask *dataTask = [[[TCNSURLSession sharedSession] session] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        //
        if (completion) completion(data, (NSHTTPURLResponse *)response, error);
    }];
    //
    return dataTask;
}

-(NSURLSessionDataTask *)_post:(NSData *)data toURL:(NSURL *)url completion:(void (^)(NSData *data, NSHTTPURLResponse *response, NSError *error))completion {
    return [self _post:data toURL:url withContentType:@"application/json" accept:@"application/json" completion:completion ];
}

-(NSURLSessionDataTask *)_post:(NSData *)data toURL:(NSURL *)url withContentType:(NSString*) contentType accept:(NSString*) acceptType completion:(void (^)(NSData *data, NSHTTPURLResponse *response, NSError *error))completion {
    //
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPBody = data;
    if (_timeOut > 30) { request.timeoutInterval = _timeOut; }
    else { request.timeoutInterval = 85; }
    [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
    [request setValue:acceptType forHTTPHeaderField:@"Accept"];
    request.HTTPMethod = @"POST";
    //
    return [self _dataTaskWithRequest:request completion:completion];
}

-(NSData *)encodedData {
    //
    NSDictionary *params = self.dictionary;
    NSString *jsonString = [self _decodedStringFromNSDictionary:params];
    //
    return [jsonString data];
}

-(NSString *)_decodedStringFromNSDictionary:(NSDictionary *)dictionary {
    //
    if (!dictionary) return nil;
    //
    NSString *string = nil;
    @try {
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:&error];
        
        if (jsonData == nil) return nil;
        //
        string = TCDataToJSONString(jsonData);
    } @catch (NSException *exception) {
        //
        
    }
    //
    return string;
}

@end
 
@implementation TCRequestLocal

-(void)GET:(void (^)(__kindof TCObject * _Nullable, NSError * _Nullable))completion {
    //
    self.completion = completion;
    //
    dispatch_async([[TCNSURLSession sharedSession] queue], ^{
        //
        @autoreleasepool {
            //
            NSDictionary *dictionary = self.dictionary;
            [self _loadObjectsWithDictionary:dictionary completation:self.completion];
        }
    });
}

-(void)_loadObjectsWithDictionary:(NSDictionary *)dictionary completation:(void (^)(__kindof TCObject * _Nullable, NSError * _Nullable))completion {
    //
    @autoreleasepool {
        //
        NSArray *allKeys = dictionary.allKeys;
        //
        if (allKeys.count < 1) { completion(nil, [NSError errorWithDomain:@"No file names" code:TCErrorCode userInfo:nil]); return ; }
        if (allKeys.count == 1) { [self _objectForFileName:dictionary[allKeys[0]] completion:completion]; return ; }
        //
        if ([self _isAllValuesAreStringInDictionary:dictionary]) {
            [self _objectForFileNamesWithStringDictionary:dictionary completion:completion]; return;
        }
        //
        if ([self _isAllValuesAreArrayInDictionary:dictionary]) {
            [self _objectForFileNamesWithArrayDictionary:dictionary completion:completion]; return;
        }
        //
        if ([self _isAllValuesAreDictionaryInDictionary:dictionary]) {
            [self _objectForFileNamesWithDictionaryDictionary:dictionary completion:completion]; return;
        }
        //
        NSMutableDictionary<NSString *, TCObject *> *objects = [NSMutableDictionary dictionary];
        //
        NSMutableDictionary<NSString *, NSString *> *strings = [NSMutableDictionary dictionary];
        NSMutableDictionary<NSString *, NSDictionary *> *dictionarys = [NSMutableDictionary dictionary];
        NSMutableDictionary<NSString *, NSArray *> *arrays = [NSMutableDictionary dictionary];
        //
        for (NSString *key in allKeys) {
            //
            @autoreleasepool {
                //
                id value = dictionary[key];
                //
                if ([value isKindOfClass:[NSString class]]) [strings setObject:value forKey:key];
                else if ([value isKindOfClass:[NSDictionary class]]) [dictionarys setObject:value forKey:key];
                else if ([value isKindOfClass:[NSArray class]]) [arrays setObject:value forKey:key];
            }
        }
        //
        for (NSString *key in strings.allKeys) {
            //
            @autoreleasepool {
                //
                NSString *string = strings[key];
                [self _objectForFileName:string completion:^(__kindof TCObject * _Nullable object, NSError * _Nullable error) {
                    //
                    if (object) [objects setObject:object forKey:key];
                }];
            }
        }
        //
        for (NSString *key in dictionarys.allKeys) {
            //
            @autoreleasepool {
                //
                NSDictionary<NSString *, NSDictionary *> *dictionary = dictionarys[key];
                [self _objectForFileNamesWithDictionaryDictionary:dictionary completion:^(__kindof TCObject * _Nullable object, NSError * _Nullable error) {
                    //
                    if (object) [objects setObject:object forKey:key];
                }];
            }
        }
        //
        for (NSString *key in arrays.allKeys) {
            //
            @autoreleasepool {
                //
                NSArray *array = arrays[key];
                [self _objectForFileNamesWithArrayDictionary:array completion:^(__kindof TCObject * _Nullable object, NSError * _Nullable error) {
                    //
                    if (object) [objects setObject:object forKey:key];
                }];
            }
        }
        //
        if (objects.allValues.count < 1) completion(nil, [NSError errorWithDomain:@"No file in such names" code:TCErrorCode userInfo:nil]);
        else completion([TCObject objectWith:objects], nil);
    }
}

-(void)_objectForFileName:(NSString *)filename completion:(void (^)(__kindof TCObject *_Nullable object, NSError *_Nullable error))completion {
    //
    if (!filename) { completion(nil, [NSError errorWithDomain:@"Invalid file name" code:TCErrorCode userInfo:nil]); return ; }
    //
    NSString *filePath = ([self _isStringIsFilepath:filename]) ? filename : [self _filePathWithFileName:filename andExtension:nil];
    //
    if (!filePath) { completion(nil, [NSError errorWithDomain:@"Invalid file" code:TCErrorCode userInfo:nil]); return ; }
    //
    NSData *data = [self _dataWithContentOfLocalFilePath:filePath];
    //
    if (!data) { completion(nil, [NSError errorWithDomain:@"Null data" code:TCErrorCode userInfo:nil]); return ; }
    //
    NSDictionary *dictionary = [self _parseData:data];
    //
    if (!dictionary) { completion(nil, [NSError errorWithDomain:@"Invalid file contents" code:TCErrorCode userInfo:nil]); return ; }
    //
    TCObject *object = [TCObject objectWith:dictionary];
    //
    if (!object) { completion(nil, [NSError errorWithDomain:@"Invalid file contents" code:TCErrorCode userInfo:nil]); return ; }
    //
    completion(object, nil);
}

-(BOOL)_isStringIsFilepath:(NSString *)string {
    //
    if ([string isEqualToString:@"/"]) return NO;
    return ([string containsString:@"/"]);
}

-(void)_objectForFileNamesWithDictionaryDictionary:(NSDictionary<NSString *, NSDictionary *> *)dictionary completion:(void (^)(__kindof TCObject *_Nullable object, NSError *_Nullable error))completion {
    //
    NSMutableDictionary *objects = [NSMutableDictionary dictionary];
    NSArray *allKeys = dictionary.allKeys;
    //
    for (NSString *key in allKeys) {
        //
        NSDictionary *subDictionary = dictionary[key];
        @autoreleasepool {
            //
            [self _loadObjectsWithDictionary:subDictionary completation:^(__kindof TCObject *object, NSError * error) {
                //
                if (object) [objects setObject:object forKey:key];
            }];
        }
    }
    //
    if (objects.allValues.count < 1) completion(nil, [NSError errorWithDomain:@"No file in such names" code:TCErrorCode userInfo:nil]);
    else completion([TCObject objectWith:objects], nil);
}

-(void)_objectForFileNamesWithStringDictionary:(NSDictionary<NSString *, NSString *> *)dictionary completion:(void (^)(__kindof TCObject *_Nullable object, NSError *_Nullable error))completion {
    //
    NSMutableDictionary *objects = [NSMutableDictionary dictionary];
    NSArray *allKeys = dictionary.allKeys;
    //
    for (NSString *key in allKeys) {
        //
        @autoreleasepool {
            //
            [self _objectForFileName:dictionary[key] completion:^(TCObject *object, NSError *error) {
                //
                if (object) [objects setObject:(object) forKey:key];
            }];
        }
    }
    //
    if (objects.allValues.count < 1) completion(nil, [NSError errorWithDomain:@"No file in such names" code:TCErrorCode userInfo:nil]);
    else completion([TCObject objectWith:objects], nil);
}

-(void)_objectForFileNamesWithArrayDictionary:(NSDictionary<NSString *, NSArray *> *)dictionary completion:(void (^)(__kindof TCObject *_Nullable object, NSError *_Nullable error))completion {
    //
    NSMutableDictionary *root = [NSMutableDictionary dictionary];
    NSArray *allKeys = dictionary.allKeys;
    //
    for (id arrayKey in allKeys) {
        //
        NSArray *array = dictionary[arrayKey];
        //
        [self _objectForFileNamesWithArray:array completion:^(NSArray<__kindof TCObject *> *objects, NSError * _Nullable error) {
            //
            if (objects) [root setObject:objects forKey:arrayKey];
        }];
    }
    //
    if (root.allValues.count < 1) completion(nil, [NSError errorWithDomain:@"No file in such names" code:TCErrorCode userInfo:nil]);
    else completion([TCObject objectWith:root], nil);
}

-(void)_objectForFileNamesWithArray:(NSArray *)array completion:(void (^ __nonnull)(NSArray< __kindof TCObject *> * _Nullable objects, NSError *_Nullable error))completion {
    //
    NSMutableArray *objects = [NSMutableArray array];
    //
    for (id obj in array) {
        //
        @autoreleasepool {
            //
            if ([obj isKindOfClass:[NSDictionary class]]) {
                //
                [self _loadObjectsWithDictionary:obj completation:^(TCObject *object, NSError *error) {
                    //
                    if (object) [objects addObject:object];
                }];
            } else if ([obj isKindOfClass:[NSString class]]) {
                //
                [self _objectForFileName:obj completion:^(TCObject *object, NSError *error) {
                    //
                    if (object) [objects addObject:object];
                }];
            } else if ([obj isKindOfClass:[NSArray class]]) {
                //
//                [self _objectForFileNamesWithArray:obj completion:^(NSArray<__kindof TCObject *> * _Nullable objects, NSError * _Nullable error) {
//                    //
//                    if (objects) [objects addObject:object];
//                }];
            }
        }
        //
        if (objects.count < 1) completion(nil, [NSError errorWithDomain:@"No file in such names" code:TCErrorCode userInfo:nil]);
        else completion(objects, nil);
    }
}

-(NSString *)_filePathWithFileName:(NSString *)fileName andExtension:(NSString *)fileExtension  {
    //
    if (!fileName) return nil;
    return [[NSBundle mainBundle] pathForResource:fileName ofType:fileExtension];
}

-(NSData *)_dataWithContentOfLocalFilePath:(NSString *)filePath {
    //
    NSError *error_ = nil;
    NSString *jsonString = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error_];
    //
    if (error_) { return nil; }
    //
    return [jsonString dataUsingEncoding:NSUTF8StringEncoding];
}

-(BOOL)_isAllValuesAreStringInDictionary:(NSDictionary *)dictionary {
    //
    NSArray *allKeys = dictionary.allKeys;
    //
    for (id key in allKeys) {
        if (![dictionary[key] isKindOfClass:[NSString class]]) return NO;
    }
    //
    return YES;
}

-(BOOL)_isAllValuesAreArrayInDictionary:(NSDictionary *)dictionary {
    //
    NSArray *allKeys = dictionary.allKeys;
    //
    for (id key in allKeys) {
        if (![dictionary[key] isKindOfClass:[NSArray class]]) return NO;
    }
    //
    return YES;
}

-(BOOL)_isAllValuesAreDictionaryInDictionary:(NSDictionary *)dictionary {
    //
    NSArray *allKeys = dictionary.allKeys;
    //
    for (id key in allKeys) {
        if (![dictionary[key] isKindOfClass:[NSDictionary class]]) return NO;
    }
    //
    return YES;
}

@end

@implementation TCRequestMultiPart

+(instancetype)requestWithURL:(NSURL *)url {
    //
    if (!url) return nil;
    //
    TCRequestMultiPart *request = [[[self class] alloc] init];
    request.url = url;
    return request;
}

-(void)cancel:(void (^)(void))completion {
    //
    self.completion = nil;
    if (completion) completion();
    
    [self.task cancel];
}

-(void)POST:(void (^)(__kindof TCObject * _Nullable, NSError * _Nullable))completion {
    //
    NSDictionary *dictionary = self.dictionary;
    NSMutableDictionary<NSString *, UIImage *> *images = [NSMutableDictionary dictionary];
    NSMutableDictionary<NSString *, id> *params = [NSMutableDictionary dictionary];
    //
    NSArray *allkeys = dictionary.allKeys;
    //
    for (NSString *key in allkeys) {
        //
        @autoreleasepool {
            //
            id object = dictionary[key];
            //
            if ([object isKindOfClass:[UIImage class]]) [images setObject:object forKey:key];
            else if ([object isKindOfClass:[NSString class]]) [params setObject:object forKey:key];
            else if ([object isKindOfClass:[NSNumber class]]) [params setObject:[object stringValue] forKey:key];
            else [params setObject:object forKey:key];
        }
    }
    //
    if (images.allKeys.count < 1) images = nil;
    if (params.allKeys.count < 1) params = nil;
    //
    [self POST:images andParams:params completion:completion];
}

-(void)POST:(NSDictionary<NSString *, UIImage *> *)images andParams:(NSDictionary<NSString *, id<TCRequeatableParams>> *)params completion:(void (^)(__kindof TCObject * _Nullable, NSError * _Nullable))completion {
    //
    if (!images && !params) { completion(nil, [NSError errorWithDomain:@"Nothing to post" code:TCErrorCode userInfo:nil]); return; }
    //
    self.completion = completion;
    NSURL *url = [self url];
    //
    if (!url) { completion(nil, [NSError errorWithDomain:@"NULL url" code:TCErrorCode userInfo:nil]); return; }
    __typeof(self) weakSelf = self;
    //
    dispatch_async([[TCNSURLSession sharedSession] queue], ^{
        //
        @autoreleasepool {
            //
            NSMutableData *bodyData = [NSMutableData data];
            NSString *boundary = [NSString stringWithFormat:@"Boundary-%@", [[NSUUID UUID] UUIDString]];
            NSData *paramsData = [weakSelf _dataFromParams:params boundary:boundary];
            NSData *imagesData = [weakSelf _dataFromImages:images boundary:boundary];
            //
            if (paramsData) [bodyData appendData:paramsData];
            if (imagesData) [bodyData appendData:imagesData];
            //
            NSMutableURLRequest *request = [weakSelf _multipartPOSTRequestWithURL:url withBodyData:bodyData andBoundary:boundary];
            
            if (_timeOut > 30) { request.timeoutInterval = _timeOut; }
            else { request.timeoutInterval = 85; }
            //
            __weak __typeof(weakSelf) weakOfWeakSelf = weakSelf;
            NSURLSessionDataTask *task = [weakSelf _dataTaskWithRequest:request completion:^(NSData *data, NSHTTPURLResponse *response, NSError *error) {
                //
                [weakOfWeakSelf _manipulateData:data response:response error:error];
            }];
            //
            [task resume];
            weakSelf.task = task;
        }
    });
}

-(NSURLSessionDataTask *)_dataTaskWithRequest:(NSURLRequest *)request completion:(void (^)(NSData *data, NSHTTPURLResponse *response, NSError *error))completion {
    //
    NSURLSessionDataTask *dataTask = [[[TCNSURLSession sharedSession] session] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        //
        if (completion) completion(data, (NSHTTPURLResponse *)response, error);
    }];
    //
    return dataTask;
}

-(NSMutableURLRequest *)_multipartPOSTRequestWithURL:(NSURL *)url withBodyData:(NSData *)bodyData andBoundary:(NSString *)boundary{
    //
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    //
    request.HTTPMethod = @"POST";
    [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
    request.HTTPBody = bodyData;
    //
    return request;
}

-(NSData *)_dataFromImages:(NSDictionary<NSString *,UIImage *> *)images boundary:(NSString *)boundary {
    //
    if (!images) return nil;
    //
    NSData *tempData = nil;
    NSMutableData *body = [NSMutableData data];
    NSArray *allKeys = images.allKeys;
    NSString *mimetype = @"image/jpeg";
    //
    for (NSString *filename in allKeys) {
        //
        @autoreleasepool {
            //
            UIImage *image = images[filename];
            NSData *imageData = [image data];
            if (!imageData) continue;
            //
            tempData = [[NSString stringWithFormat:@"--%@\r\n", boundary] data];
            [body appendData:tempData];
            //
            tempData = [[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", filename, filename] dataUsingEncoding:NSUTF8StringEncoding];
            [body appendData:tempData];
            //
            tempData = [[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", mimetype] data];
            [body appendData:tempData];
            //
            [body appendData:imageData];
            //
            tempData = [[NSString stringWithFormat:@"\r\n"] data];
            [body appendData:tempData];
            //
            tempData = [[NSString stringWithFormat:@"--%@\r\n", boundary] data];
            [body appendData:tempData];
            //
            tempData = [[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", filename, filename] data];
            [body appendData:tempData];
            //
            tempData = [[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", mimetype] data];
            [body appendData:tempData];
            //
            tempData = [[NSString stringWithFormat:@"\r\n"] data];
            [body appendData:tempData];
        }
    }
    //
    tempData = [[NSString stringWithFormat:@"--%@--\r\n", boundary] data];
    [body appendData:tempData];
    //
    return body;
}

-(NSData *)_dataFromParams:(NSDictionary<NSString *, id<TCRequeatableParams>> *)params boundary:(NSString *)boundary {
    //
    if (!params) return nil;
    //
    NSMutableData *body = [NSMutableData data];
    NSArray *allKeys = params.allKeys;
    //
    for (NSString *key in allKeys) {
        //
        @autoreleasepool {
            //
            id<TCRequeatableParams> object = params[key];
            NSString *value = [object UTF8String];
            //
            if (value) {
                //
                [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] data]];
                [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", key] data]];
                [body appendData:[[NSString stringWithFormat:@"%@\r\n", value] data]];
            }
        }
    }
    //
    return body;
}

@end

@implementation TCNSURLSession

-(NSURLSession *)session {
    //
    if (_session) return _session;
    //
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    sessionConfiguration.HTTPMaximumConnectionsPerHost = 10;
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    self.session = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:queue];
    //
    return _session;
}

-(dispatch_queue_t)queue {
    //
    if (_queue) return _queue;
    //
    self.queue = dispatch_queue_create("TCRequest.queue", DISPATCH_QUEUE_CONCURRENT);
    return _queue;
}

+ (instancetype)sharedSession {
    //
    static dispatch_once_t p = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&p, ^{
        _sharedObject = [[self alloc] init];
    });
    //
    return _sharedObject;
}

@end

@implementation NSData (TCRequeatableParams)

-(NSData *)data {
    return self;
}

-(NSString *)UTF8String {
    //
    NSData *data = [self data];
    if (!data) return nil;
    //
    return [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
}

@end

@implementation UIImage (TCRequeatableParams)

-(NSData *)data {
    return UIImageJPEGRepresentation(self, 1);
}

-(NSString *)UTF8String {
    //
    NSData *data = [self data];
    if (!data) return nil;
    //
    return [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
}

@end

@implementation NSString (TCRequeatableParams)

-(NSData *)data {
    return [self dataUsingEncoding:NSUTF8StringEncoding];
}

-(NSString *)UTF8String {
    //
    NSData *data = [self data];
    if (!data) return nil;
    //
    return [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
}

@end

@implementation NSNumber (TCRequeatableParams)

-(NSData *)data {
    return [[self stringValue] dataUsingEncoding:NSUTF8StringEncoding];
}

-(NSString *)UTF8String {
    //
    NSData *data = [self data];
    if (!data) return nil;
    //
    return [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
}

@end

@implementation NSDictionary (TCRequeatableParams)

-(NSData *)data {
    //
    NSData *data = nil;
    @try {
        //
        data = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:nil];
    } @catch (NSException *exception) {
        //
        
    }
    //
    return data;
}

-(NSString *)UTF8String {
    //
    NSData *data = [self data];
    if (!data) return nil;
    //
    return [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
}

@end

@implementation NSArray (TCRequeatableParams)

-(NSData *)data {
    //
    NSData *data = nil;
    @try {
        //
        data = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:nil];
    } @catch (NSException *exception) {
        //
        
    }
    //
    return data;
}

-(NSString *)UTF8String {
    //
    NSData *data = [self data];
    if (!data) return nil;
    //
    return [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
}

@end

@implementation TCObject (TCRequeatableParams)

-(NSData *)data {
    //
    NSData *data = nil;
    @try {
        //
        data = [NSJSONSerialization dataWithJSONObject:self.toDictionary options:NSJSONWritingPrettyPrinted error:nil];
    } @catch (NSException *exception) {
        //
        
    }
    //
    return data;
}

-(NSString *)UTF8String {
    //
    NSData *data = [self data];
    if (!data) return nil;
    //
    return [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
}

@end

