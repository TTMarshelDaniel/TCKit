//
//  Created by T T Marshel Daniel on 05/05/2017.
//

#import "TCProtocol.h"

@class TCObject;
@class TCValue;

extern NSString *TCDataToJSONString(NSData *data);
extern NSDictionary *TCDataToJSONDictionary(NSData *data);
extern NSTimeInterval TCEpochTime();

@interface TCValue :NSObject<TCValue, TCGetterKeyed, TCGetterIndexed>
+(instancetype)valueWith:(id<TCAllowable>)anyObject;
@end

@interface TCObject :NSObject<TCObject, TCGetterKeyed, TCSetterKeyed>

+(instancetype)object;
+(instancetype)objectWith:(id<TCObjectable>)object;
+(BOOL)isValidWith:(id<TCObjectable>)object;

@end
@interface TCObject (TCDiskCacheable)<TCDiskCacheable>

@end

#pragma mark -TCObjectable

@interface TCObject (TCObjectable) <TCObjectable>@end
@interface NSObject (TCObjectable) <TCObjectable>@end
@interface NSDictionary (TCObjectable) <TCObjectable>@end
@interface NSData (TCObjectable) <TCObjectable>@end
@interface NSString (TCObjectable) <TCObjectable>@end

#pragma mark -TCAllowable

@interface TCValue (TCAllowable) <TCAllowable, TCLogable> @end
@interface NSArray (TCAllowable) <TCAllowable, TCLogable> @end
@interface NSNumber (TCAllowable) <TCAllowable, TCLogable> @end
@interface NSString (TCAllowable) <TCAllowable, TCLogable> @end
@interface TCObject (TCAllowable) <TCAllowable, TCLogable> @end
@interface NSDictionary (TCAllowable) <TCAllowable, TCLogable> @end




