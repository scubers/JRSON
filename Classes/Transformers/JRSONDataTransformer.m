//
//  JRSONDataTransformer.m
//  JRSON
//
//  Created by 王俊仁 on 2017/5/5.
//  Copyright © 2017年 J. All rights reserved.
//

#import "JRSONDataTransformer.h"
#import "JRSONPropertyAnalyzing.h"

@implementation JRSONDataTransformer

- (BOOL)jrsn_canHandleWithClass:(Class)aClass {
    return [aClass isSubclassOfClass:[NSData class]];
}

- (NSString *)jrsn_serializeObj:(id)obj {
    if ([obj length] > 1024 * 1024) {
        NSLog(@"序列化Data已经超过 1M；建议减少体积，或者忽略该字段 @see +[jrsn_ignoreProperties]");
    }
    return [obj base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
}

- (id)jrsn_deserializeJson:(id<JRSONValuable>)json withClass:(Class<JRSON>)aClass {
    return [[NSData alloc] initWithBase64EncodedString:(NSString *)json
                                               options:NSDataBase64DecodingIgnoreUnknownCharacters];
}

@end


@implementation NSData (JRSONDataTransformer)

@end
