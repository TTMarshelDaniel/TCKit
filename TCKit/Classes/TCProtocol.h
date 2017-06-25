//
//  Created by T T Marshel Daniel on 05/05/2017.
//
 
#import <Foundation/Foundation.h>

@class TCObject;
@class TCValue;

@protocol TCAllowable <NSObject>@end
@protocol TCObjectable <NSObject>
@required
-(NSDictionary *__nullable)convertToDictionary;
@end

@protocol TCGetterKeyed <NSObject>
@required
-(TCValue *__nullable)objectForKeyedSubscript:(id)key;
@end

@protocol TCGetterIndexed <NSObject>
@required
-(TCValue *__nullable)objectAtIndexedSubscript:(NSUInteger)idx;
@end

@protocol TCSetterKeyed <NSObject>
@required
- (void)setObject:(id<TCAllowable> __nullable)obj forKeyedSubscript:(id <NSCopying>)key;
@end

@protocol TCSetterIndexed <NSObject>
@required
- (void)setObject:(id<TCAllowable> __nullable)obj atIndexedSubscript:(NSUInteger)idx;
@end

@protocol TCLogable <NSObject>
@required
-(void)log;
-(void)logWithTag:(NSString *)tag;
@end

@protocol TCDiskCacheable <NSCoding>

@required
@property (nonatomic, strong, readonly) NSString *objectId;

+(NSString *)rootDirectoryPath;
+(NSArray<TCObject *> *)allObjects;
+(TCObject *)objectWithId:(NSString *)Id;
+(NSArray<NSString *> *)objectIds;
+(BOOL)deleteObjectWithId:(NSString *)objectId;
-(BOOL)save;
-(BOOL)delete;
-(BOOL)saveWithId:(NSString *)objectId;
-(BOOL)saveIntoPath:(NSString *)path withId:(NSString *)objectId;

+(TCObject *)objectWithPath:(NSString *)path;
+(TCObject *)objectWithPath:(NSString *)path andId:(NSString *)Id;

+(NSString *)objectIdKey;

@end

@protocol TCObject <NSObject, NSCopying, NSMutableCopying>
@required
@property (nonatomic, readonly) TCValue *value;
@property (nonatomic, readonly) id rawObject;
@property (nonatomic, readonly) NSDictionary *toDictionary;
@property (nonatomic, readonly) NSString *stringify;
@end

@protocol TCValue <NSObject>

@required

@property (nonatomic, readonly) int intValue;
@property (nonatomic, readonly) BOOL boolValue;
@property (nonatomic, readonly) float floatValue;
@property (nonatomic, readonly) double doubleValue;
@property (nonatomic, readonly, nonnull) id rawObject;
@property (nonatomic, readonly) NSInteger integer;
@property (nonatomic, readonly, nullable) NSNumber *number;
@property (nonatomic, readonly, nullable) NSString *string;
@property (nonatomic, readonly, nullable) NSArray *array;
@property (nonatomic, readonly, nullable) NSDictionary *dictionary;
@property (nonatomic, readonly, nullable) TCValue *value;
@property (nonatomic, readonly, nullable) TCObject *object;
@property (nonatomic, readonly, nullable) NSArray<TCObject *> *arrayObject;
@property (nonatomic, readonly, nullable) NSArray<TCObject *> *objectArray;
@property (nonatomic, readonly, nullable) Class rawObjectClass;
@property (nonatomic, readonly, nullable) NSString *toString;
@property (nonatomic, readonly, nullable) NSString *stringify;

@end

@protocol TCRequeatableParams <NSObject>

-(NSData *)data;
-(NSString *)UTF8String;
@end






