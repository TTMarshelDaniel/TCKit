//
//  Created by T T Marshel Daniel on 05/05/2017.
//

#include <objc/runtime.h>
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

+(instancetype)objectWithId:(NSString *)Id;
+(instancetype)objectWithPath:(NSString *)path;
+(instancetype)objectWithPath:(NSString *)path andId:(NSString *)Id;

+(NSString *)rootDirectoryPath;
+(NSArray<__kindof TCObject *> *)allObjects;

+(NSArray<NSString *> *)objectIds;
+(BOOL)deleteObjectWithId:(NSString *)objectId;
-(BOOL)save;
-(BOOL)delete;
-(NSString *)saveAndgetObjectId;
-(NSString *)deleteAndgetObjectId;
-(BOOL)saveWithId:(NSString *)objectId;
-(BOOL)saveIntoPath:(NSString *)path withId:(NSString *)objectId;


+(NSString *)keyForObjectId;

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
@property (nonatomic, readonly) __kindof TCValue *value;
@property (nonatomic, readonly) __kindof TCObject *object;
@property (nonatomic, readonly) NSArray<__kindof TCObject *> *arrayObject;
@property (nonatomic, readonly) NSArray<__kindof TCObject *> *objectArray;
@property (nonatomic, readonly) Class rawObjectClass;
@property (nonatomic, readonly) NSString *toString;
@property (nonatomic, readonly) NSString *stringify;

@end






