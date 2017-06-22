//
//  Created by T T Marshel Daniel on 05/05/2017.
//

#import "TCObject.h"


static NSString *_TCformattedStringFromNSData(NSData *data) {
    //
    if (!data) return nil;
    //
    NSString *jsonString = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    if (!jsonString) return nil;
    //
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@":\"\"" withString:@":\"\""];
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@":null" withString:@":\"\""];
    //
    return jsonString;
}

static NSDictionary *_TCdataToDictionary(NSData *data) {
    //
    NSError *error = nil;
    NSString *jsonString = _TCformattedStringFromNSData(data);
    //
    if (!jsonString) return nil;
    //
    id jsonObjects = nil;
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    
    if(jsonData) {
        //
        jsonObjects = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
        if(error) {
            //Eror catch
            NSLog(@"TCError : %@", [error localizedDescription]);
            NSLog(@"TCJON String : %@", jsonString);
        }
    }
    //
    return jsonObjects;
}

NSString *TCDataToJSONString(NSData *data) {
    return _TCformattedStringFromNSData(data);
}


NSDictionary *TCDataToJSONDictionary(NSData *data) {
    return _TCdataToDictionary(data);
}

NSTimeInterval TCEpochTime() {
    //
    return [[NSDate date] timeIntervalSince1970] * 1000;
}

static inline NSString *_getTimeStamp() {
    return [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970] * 1000];
}



@interface TCObject ()

@property (nonatomic, strong) NSString *_objectId;
@property (nonatomic, strong) NSMutableDictionary *_internalObject;

@end

@interface TCValue ()
@property (nonatomic, strong) id _internalObject;

+(instancetype)valueWithObject:(id)object;
@end

@implementation TCObject

+(instancetype)object {
    //
    TCObject *obj = [[[self class] alloc] init];
    obj._internalObject = [@{} mutableCopy];
    //
    return obj;
}


+(instancetype)objectWith:(id<TCObjectable>)object {
    //
    if (!object) return nil;
    if ([object isKindOfClass:[TCObject class]]) return (TCObject *)object;
    //
    if (![object respondsToSelector:@selector(convertToDictionary)]) {
        //
        NSString *logMessage = [NSString stringWithFormat:@"%@ Not Confirms TCObjectable protocol", NSStringFromClass([object class])];
        assert(logMessage);
    }
    //
    NSDictionary *dictionary = [object convertToDictionary];
    if (!dictionary) return nil;
    if (![dictionary isKindOfClass:[NSDictionary class]]) return nil;
    //
    TCObject *obj = [[[self class] alloc] init];
    obj._internalObject = [dictionary mutableCopy];
    //
    return obj;
}

+(BOOL)isValidWith:(id<TCObjectable>)object {
    //
    if (!object) return NO;
    if ([object isKindOfClass:[TCObject class]]) return YES;
    //
    if (![object respondsToSelector:@selector(convertToDictionary)]) return NO;
    
    id obj = [object convertToDictionary];
    if (!obj) return NO;
    //
    if (![obj isKindOfClass:[NSDictionary class]]) return NO;
    //
    return YES;
}

-(void)setObjectId:(NSString *)Id {
    self._objectId = Id;
}

-(NSString *)objectId {
    //
    NSString *key = [[self class] objectIdKey];
    //
    if (key) {
        //
        NSString *value = self._internalObject[key];
        if (value) {
            //
            if ([value isKindOfClass:[NSNumber class]]) return [(NSNumber *)value stringValue];
            return value;
        }
        
        if (value) return value;
    }
    //
    if (__objectId) {
        //
        if ([__objectId isKindOfClass:[NSNumber class]]) return [(NSNumber *)__objectId stringValue];
        return __objectId;
    }
    self._objectId = _getTimeStamp();
    //
    return __objectId;
}

- (id)copyWithZone:(NSZone *)zone {
    //
    NSDictionary *copy = [NSDictionary dictionaryWithDictionary:__internalObject];
    return [TCObject objectWith:copy];
}

-(id)mutableCopyWithZone:(NSZone *)zone {
    //
    NSDictionary *copy = [NSDictionary dictionaryWithDictionary:__internalObject];
    return [TCObject objectWith:copy];
}

-(TCValue *)objectForKeyedSubscript:(id)key {
    //
    if (!key) return nil;
    //
    id obj = self._internalObject[key];
    if (!obj) return nil;
    if ([obj isKindOfClass:[NSNull class]]) return nil;
    //
    return [TCValue valueWithObject:obj];
}

-(void)setObject:(id<TCAllowable>)obj forKeyedSubscript:(id<NSCopying>)key {
    //
    if (!key) return;
    //
    if (obj) self._internalObject[key] = obj;
    else [self._internalObject removeObjectForKey:key];
}

-(id)rawObject {
    return self._internalObject;
}

-(TCValue *)value {
    //
    id obj = self._internalObject;
    return [TCValue valueWithObject:obj];
}

-(NSDictionary *)toDictionary {
    //
    id obj = self._internalObject;
    if (![obj isKindOfClass:[NSDictionary class]]) return nil;
    //
    return obj;
}

-(NSString *)stringify {
    return [NSString stringWithFormat:@"%@", __internalObject];
}

-(NSString *)description {
    return [NSString stringWithFormat:@"%@", __internalObject];
}

@end

#pragma mark -TCDiskCacheable

@implementation TCObject (TCDiskCacheable)

- (id)initWithCoder:(NSCoder *)aDecoder {
    //
    if (self = [super init]) {
        //
        self._internalObject = [aDecoder decodeObjectForKey:@"_internalObject"];
        self.objectId = [aDecoder decodeObjectForKey:@"objectId"];
    }
    //
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder {
    //
    [aCoder encodeObject:self._internalObject forKey:@"_internalObject"];
    [aCoder encodeObject:self.objectId forKey:@"objectId"];
}

+(NSString *)_basePath {
    //
    NSString *path = [[self rootDirectoryPath] stringByAppendingPathComponent:[self _directoryName]];
    if ([self _isFileExistsAtPath:path]) return path;
    //
    if ([self _createADicrectoryAtPath:path]) return path;
    //
    return Nil;
}

+(BOOL)_createADicrectoryAtPath:(NSString *)path {
    //
    return [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
}

+(NSString *)_fullPathWithFileName:(NSString *)fileName {
    //
    NSString *basePath = [self _basePath];
    NSString *extension = [self _fileExtension];
    NSString *filePath = [basePath stringByAppendingPathComponent:fileName];
    //
    return [filePath stringByAppendingPathExtension:extension];
}

+(NSString *)_fileExtension {
    //
    return @"tc";
}

+(NSArray<NSString *> *)_fileNamesInDirectoryPath:(NSString *)directoryPath withExtension:(NSString *)extension {
    //
    NSString *fileName = nil;
    NSMutableArray<NSString *> *fileNames = [NSMutableArray array];
    NSDirectoryEnumerator *dRum = [[NSFileManager defaultManager] enumeratorAtPath:directoryPath];
    [dRum skipDescendents];
    //
    while (fileName = [dRum nextObject]) {
        //
        @autoreleasepool {
            //
            if ([[fileName pathExtension] isEqualToString:extension]) {
                //
                NSString *obj = [fileName stringByDeletingPathExtension];
                [fileNames addObject:obj];
            }
            NSLog(@"%@",directoryPath);
        }
    }
    //
    return fileNames;
}

+(BOOL)_isFileExistsAtPath:(NSString *)filePath {
    //
    return [[NSFileManager defaultManager] fileExistsAtPath:filePath];
}


+(NSData *)_dataWithFilePath:(NSString *)filePath {
    //
    if (!filePath) return nil;
    return [[NSFileManager defaultManager] contentsAtPath:filePath];
}

+(BOOL)_saveData:(NSData *)data toFilePath:(NSString *)filePath {
    //
    if (!filePath) return nil;
    return [[NSFileManager defaultManager] createFileAtPath:filePath contents:data attributes:nil];
}

+(BOOL)_deleteFileAtPath:(NSString *)filePath {
    //
    return [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
}

+(TCObject *)TCObjectFromNSData:(NSData *)data {
    return [NSKeyedUnarchiver unarchiveObjectWithData:data];
}

+(NSData *)NSDataFromTCObject:(TCObject *)object {
    return [NSKeyedArchiver archivedDataWithRootObject:object];
}

+(NSData *)_objectToData:(NSData *)data {
    //
    return nil;
}

+(NSString *)_directoryName {
    //
    return NSStringFromClass([self class]);
}

+(NSString *)rootDirectoryPath {
    //
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cacheDirectory = [paths objectAtIndex:0];
    return cacheDirectory;
}


+(NSArray<TCObject *> *)allObjects {
    //
    NSMutableArray<TCObject *> *collection = [NSMutableArray array];
    NSArray<NSString *> *fileNames = [self objectIds];
    //
    for (NSString *fileName in fileNames) {
        //
        @autoreleasepool {
            //
            TCObject *object = [self objectWithId:fileName];
            if (object) [collection addObject:object];
        }
    }
    //
    if (collection.count < 1) return nil;
    return collection;
}



+(TCObject *)objectWithId:(NSString *)Id {
    //
    if (!Id) return nil;
    NSString *filePath = [self _fullPathWithFileName:Id];
    if (!filePath) return nil;
    if (![self _isFileExistsAtPath:filePath]) return nil;
    //
    NSData *data = [self _dataWithFilePath:filePath];
    if (!data) return nil;
    //
    id obj = nil;
    //
    return obj;
}


+(NSArray<NSString *> *)objectIds {
    //
    NSString *basePath = [self _basePath];
    NSString *extension = [self _fileExtension];
    NSMutableArray<NSString *> *collection = [NSMutableArray array];
    //
    NSArray<NSString *> *fileNames = [[self class] _fileNamesInDirectoryPath:basePath withExtension:extension];
    //
    for (NSString *fileName in fileNames) {
        //
        @autoreleasepool {
            //
            [collection addObject:fileName];
        }
    }
    //
    if (collection.count < 1) return nil;
    return collection;
}

+(BOOL)deleteObjectWithId:(NSString *)objectId {
    //
    if (!objectId) return NO;
    NSString *filePath = [self _fullPathWithFileName:objectId];
    if (!filePath) return NO;
    if (![self _isFileExistsAtPath:filePath]) return YES;
    //
    return [self _deleteFileAtPath:filePath];
}

-(BOOL)save {
    return [self saveWithId:self.objectId];
}

-(BOOL)delete {
    return [[self class] deleteObjectWithId:self.objectId];
}

-(BOOL)saveWithId:(NSString *)objectId {
    //
    NSData *data = [[self class] NSDataFromTCObject:self];
    if (!data) return NO;
    //
    NSString *fullPath = [[self class] _fullPathWithFileName:objectId];
    if (!fullPath) return NO;
    //
    return [[self class] _saveData:data toFilePath:fullPath];
}

-(BOOL)saveIntoPath:(NSString *)path withId:(NSString *)objectId {
    //
    NSString *extension = [[self class] _fileExtension];
    NSString *filePath = [path stringByAppendingPathComponent:objectId];
    NSString *fullpath = [filePath stringByAppendingPathExtension:extension];
    //
    NSData *data = [[self class] NSDataFromTCObject:self];
    if (!data) return NO;
    //
    return [[self class] _saveData:data toFilePath:fullpath];
}

+(TCObject *)objectWithPath:(NSString *)path {
    //
    if (!path)  return nil;
    NSData *data = [self _dataWithFilePath:path];
    //
    return [self TCObjectFromNSData:data];
}

+(TCObject *)objectWithPath:(NSString *)path andId:(NSString *)Id {
    //
    NSString *extension = [[self class] _fileExtension];
    NSString *filePath = [path stringByAppendingPathComponent:Id];
    NSString *fullpath = [filePath stringByAppendingPathExtension:extension];
    //
    NSData *data = [self _dataWithFilePath:fullpath];
    if (!data) return nil;
    //
    return [self TCObjectFromNSData:data];
}

+(NSString *)objectIdKey {
    return nil;
}

@end


@implementation TCValue

+(instancetype)valueWith:(id<TCAllowable>)anyObject {
    //
    if (!anyObject) return nil;
    if ([anyObject isKindOfClass:[NSNull class]]) return nil;
    if ([anyObject isKindOfClass:[TCValue class]]) return (TCValue *)anyObject;
    //
    TCValue *obj = [[[self class] alloc] init];
    obj._internalObject = anyObject;
    //
    return obj;
}
//

+(instancetype)valueWithObject:(id)object {
    //
    return [self valueWith:object];
}

-(TCValue *)objectForKeyedSubscript:(id)key {
    //
    if (!key) return nil;
    NSDictionary *dictionary = [self _dictionaryWithDictionary:__internalObject];
    if (!dictionary) return nil;
    //
    return [TCValue valueWithObject:dictionary[key]];
}

-(TCValue *)objectAtIndexedSubscript:(NSUInteger)idx {
    //
    if (idx <= -1) return nil;
    //
    NSArray *array = [self _arrayWithArray:__internalObject];
    if (!array) return nil;
    if (array.count <= idx) return nil;
    //
    return [TCValue valueWithObject:array[idx]];
}

-(NSString *)string {
    //
    id obj = __internalObject;
    NSString *string = nil;
    //
    if (obj) {
        //
        if ([obj isKindOfClass:[NSString class]]) string = obj;
        else if ([obj isKindOfClass:[NSNumber class]]) string = [((NSNumber *)obj) stringValue];
    } else {
        //
        return nil;
    }
    //
    if ([string isEqualToString:@"0"] || [string isEqualToString:@""] || [string isEqualToString:@" "]) return nil;
    if ([string isEqualToString:@"NULL"] || [string isEqualToString:@"null"] || [string isEqualToString:@"Null"]) return nil;
    //
    return string;
}

-(NSString *)stringValue {
    return self.string;
}

-(NSNumber *)number {
    //
    id obj = __internalObject;
    //
    if (obj) {
        //
        if ([obj isKindOfClass:[NSNumber class]]) return obj;
        else if ([obj isKindOfClass:[NSString class]]) return @([((NSString *)obj) doubleValue]);
    }
    //
    return nil;
}

-(NSArray *)array {
    return [self _arrayWithArray:__internalObject];
}

-(NSDictionary *)dictionary {
    return [self _dictionaryWithDictionary:__internalObject];
}

-(TCObject *)object {
    return [self _objectDictionary:__internalObject];
}

-(NSArray<TCObject *> *)objectArray {
    return [self _objectsFromArray:__internalObject];
}

-(NSArray<TCObject *> *)arrayObject {
    return [self _objectsFromArray:__internalObject];
}

-(TCValue *)value {
    return self;
}

-(id)rawObject {
    return __internalObject;
}

-(Class)rawObjectClass {
    return [__internalObject class];
}

-(NSInteger)integer {
    return [[self number] integerValue];
}

-(int)intValue {
    return [[self number] intValue];
}

-(double)doubleValue {
    return [[self number] doubleValue];
}

-(float)floatValue {
    return [[self number] floatValue];
}

-(BOOL)boolValue {
    //
    id obj = __internalObject;
    
    if (!obj) return NO;
    //
    BOOL flag = NO;
    if ([obj isKindOfClass:[NSString class]]) {
        //
        flag = ([obj isEqualToString:@"1"] || [obj isEqualToString:@"true"] || [obj isEqualToString:@"True"] || [obj isEqualToString:@"TRUE"] || [obj isEqualToString:@"yes"] || [obj isEqualToString:@"Yes"] || [obj isEqualToString:@"YES"]);
    } else if ([obj isKindOfClass:[NSNumber class]]) {
        //
        flag = ([obj integerValue] > 0);
    }
    //
    return flag;
}

-(NSString *)stringify {
    //
    id obj = __internalObject;
    //
    if (!obj) return nil;
    id string = nil;
    //
    string = ([obj isKindOfClass:[NSString class]]) ? obj : nil;
    if (string) return string;
    //
    string = ([obj isKindOfClass:[NSNumber class]]) ? [(NSNumber *)obj stringValue] : nil;
    if (string) return string;
    //
    string = ([obj isKindOfClass:[NSDictionary class]]) ? [NSString stringWithFormat:@"%@", obj] : nil;
    if (string) return string;
    //
    string = ([obj isKindOfClass:[NSArray class]]) ? [NSString stringWithFormat:@"%@", obj] : nil;
    if (string) return string;
    //
    string = ([obj isKindOfClass:[TCObject class]]) ? [NSString stringWithFormat:@"%@", ((TCObject *)obj)._internalObject] : nil;
    if (string) return string;
    //
    return [NSString stringWithFormat:@"%@", obj];
}

-(NSString *)toString {
    return [NSString stringWithFormat:@"%@", __internalObject];
}

-(NSString *)description {
    return [NSString stringWithFormat:@"%@", __internalObject];
}

-(NSArray *)_arrayWithArray:(NSArray *)array {
    //
    if (!array) return nil;
    if (![array isKindOfClass:[NSArray class]]) return nil;
    if (array.count < 1) return nil;
    //
    return array;
}


-(NSDictionary *)_dictionaryWithDictionary:(NSDictionary *)dictionary {
    //
    if (!dictionary) return nil;
    //
    if ([dictionary isKindOfClass:[NSDictionary class]]) {
        if (dictionary.allKeys.count > 0) return dictionary;
        //
    }
    if ([dictionary isKindOfClass:[TCObject class]]) {
        //
        TCObject *obj = (TCObject *)dictionary;
        if (obj._internalObject.allKeys.count > 0) return obj._internalObject;
    }
    //
    return nil;
}

-(TCObject *)_objectDictionary:(NSDictionary *)dictionary {
    //
    if (![self _dictionaryWithDictionary:dictionary]) return nil;
    //
    return [TCObject objectWith:dictionary];
}


-(NSArray<TCObject *> *)_objectsFromArray:(NSArray *)array {
    //
    if (![self _arrayWithArray:array]) return nil;
    //
    NSMutableArray<TCObject *> *collection = [NSMutableArray array];
    //
    for (NSDictionary *obj in array) {
        //
        id newItem = [TCObject objectWith:obj];
        if (newItem) [collection addObject:newItem];
    }
    //
    if (collection.count < 1) return nil;
    return collection;
}

@end


#pragma mark -TCAllowable

@implementation NSString (TCAllowable)
-(void)log { NSLog(@"%@ = %@", NSStringFromClass([self class]), self); }
-(void)logWithTag:(NSString *)tag { NSLog(@"%@ : %@ = %@", tag, NSStringFromClass([self class]), self); }
@end

@implementation NSNumber (TCAllowable)
-(void)log { NSLog(@"%@ = %@", NSStringFromClass([self class]), self); }
-(void)logWithTag:(NSString *)tag { NSLog(@"%@ : %@ = %@", tag, NSStringFromClass([self class]), self); }
@end

@implementation NSArray (TCAllowable)
-(void)log { NSLog(@"%@ = %@", NSStringFromClass([self class]), self); }
-(void)logWithTag:(NSString *)tag { NSLog(@"%@ : %@ = %@", tag, NSStringFromClass([self class]), self); }
@end

@implementation NSDictionary (TCAllowable)
-(void)log { NSLog(@"%@ = %@", NSStringFromClass([self class]), self); }
-(void)logWithTag:(NSString *)tag { NSLog(@"%@ : %@ = %@", tag, NSStringFromClass([self class]), self); }
@end

@implementation TCObject (TCAllowable)
-(void)log { NSLog(@"%@ = %@", NSStringFromClass([__internalObject class]), self._internalObject); }
-(void)logWithTag:(NSString *)tag { NSLog(@"%@ : %@ = %@", tag, NSStringFromClass([__internalObject class]), self._internalObject); }
@end

@implementation TCValue (TCAllowable)
-(void)log { NSLog(@"%@ = %@", NSStringFromClass([__internalObject class]), self._internalObject); }
-(void)logWithTag:(NSString *)tag { NSLog(@"%@ : %@ = %@", tag, NSStringFromClass([__internalObject class]), self._internalObject); }
@end


@implementation TCObject (TCObjectable)

-(NSDictionary *)convertToDictionary {
    //
    return __internalObject;
}

@end

@implementation NSDictionary (TCObjectable)

-(NSDictionary *)convertToDictionary {
    //
    if ([self isKindOfClass:[NSDictionary class]]) return self;
    //
    return nil;
}

@end


@implementation NSData (TCObjectable)

-(NSDictionary *)convertToDictionary {
    return _TCdataToDictionary(self);
}

@end

@implementation NSString (TCObjectable)

-(NSDictionary *)convertToDictionary {
    //
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    if (!data) return nil;
    //
    return _TCdataToDictionary(data);
}

@end
