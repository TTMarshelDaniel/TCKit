//
//  Created by T T Marshel Daniel on 07/07/2017.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "TCObject.h"

#pragma mark -extern
extern NSInteger const TCErrorCode;

@interface NSData (TCRequeatableParams) <TCRequeatableParams>@end
@interface UIImage (TCRequeatableParams) <TCRequeatableParams>@end
@interface NSString (TCRequeatableParams) <TCRequeatableParams>@end
@interface NSNumber (TCRequeatableParams) <TCRequeatableParams>@end
@interface NSDictionary (TCRequeatableParams) <TCRequeatableParams>@end
@interface NSArray (TCRequeatableParams) <TCRequeatableParams>@end
@interface TCObject (TCRequeatableParams) <TCRequeatableParams>@end


#pragma mark -TCRequestBase
@interface TCRequestBase : NSObject

-(void)GET:(void(^__nonnull)(__kindof TCObject *__nullable Object, NSError *__nullable error))completion;
-(void)POST:(void(^__nonnull)(__kindof TCObject *__nullable Object, NSError *__nullable error))completion;
//
- (__nullable id<TCRequeatableParams>)objectForKeyedSubscript:(id __nonnull)key;
- (void)setObject:(id<TCRequeatableParams> __nullable)obj forKeyedSubscript:(id<NSCopying> __nonnull )key;

-(TCObject *__nullable)resultObjectWith:(id<TCObjectable>__nonnull)object ;

@end

#pragma mark -TCRequest
@interface TCRequest : TCRequestBase

@property (nonatomic, strong, readonly) NSURL *__nullable url;
@property (nonatomic, assign) NSTimeInterval timeOut;

+(instancetype __nullable)requestWithURL:(NSURL *__nonnull)url;
-(void)cancel:(void (^__nonnull)(void))completion;

@end

#pragma mark -TCRequestLocal
 
@interface TCRequestLocal :TCRequestBase

@end

#pragma mark -TCRequestMultiPart
@interface TCRequestMultiPart :TCRequestBase

@property (nonatomic, strong, readonly) NSURL *__nullable url;
@property (nonatomic, assign) NSTimeInterval timeOut;

+(instancetype __nullable)requestWithURL:(NSURL *__nonnull)url;

-(void)POST:(NSDictionary<NSString *, UIImage *> *__nullable)images andParams:(NSDictionary<NSString *, id<TCRequeatableParams>> *__nullable)params completion:(void(^__nonnull)(__kindof TCObject *__nullable Object, NSError *__nullable error))completion;
-(void)cancel:(void (^__nonnull)(void))completion;

@end
