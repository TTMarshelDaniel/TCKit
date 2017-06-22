//
//  TCProtocol.h
//  Woolah
//
//  Created by Admin on 22/03/1939 Saka.
//  Copyright © 1939 Saka Luecas Aspera Technologies Pvt Ltd. All rights reserved.
//
 
#import <Foundation/Foundation.h>

@class TCObject;
@class TCValue;

@protocol TCAllowable <NSObject>@end
@protocol TCObjectable <NSObject>
@required
-(NSDictionary *)convertToDictionary;
@end

@protocol TCGetterKeyed <NSObject>
@required
-(TCValue *)objectForKeyedSubscript:(id)key;
@end

@protocol TCGetterIndexed <NSObject>
@required
-(TCValue *)objectAtIndexedSubscript:(NSUInteger)idx;
@end

@protocol TCSetterKeyed <NSObject>
@required
- (void)setObject:(id<TCAllowable>)obj forKeyedSubscript:(id <NSCopying>)key;
@end

@protocol TCSetterIndexed <NSObject>
@required
- (void)setObject:(id<TCAllowable>)obj atIndexedSubscript:(NSUInteger)idx;
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
@property (nonatomic, readonly) id rawObject;
@property (nonatomic, readonly) int intValue;
@property (nonatomic, readonly) BOOL boolValue;
@property (nonatomic, readonly) float floatValue;
@property (nonatomic, readonly) double doubleValue;
@property (nonatomic, readonly) NSInteger integer;
@property (nonatomic, readonly) NSNumber *number;
@property (nonatomic, readonly) NSString *string;
@property (nonatomic, readonly) NSArray *array;
@property (nonatomic, readonly) NSDictionary *dictionary;
@property (nonatomic, readonly) TCValue *value;
@property (nonatomic, readonly) TCObject *object;
@property (nonatomic, readonly) NSArray<TCObject *> *arrayObject;
@property (nonatomic, readonly) NSArray<TCObject *> *objectArray;
@property (nonatomic, readonly) Class rawObjectClass;
@property (nonatomic, readonly) NSString *toString;
@property (nonatomic, readonly) NSString *stringify;

@end

@protocol TCRequeatableParams <NSObject>

-(NSData *)data;
-(NSString *)UTF8String;
@end






