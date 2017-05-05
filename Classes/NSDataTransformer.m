//
//  NSDataTransformer.m
//  JRSON
//
//  Created by 王俊仁 on 2017/5/5.
//  Copyright © 2017年 J. All rights reserved.
//

#import "NSDataTransformer.h"
#import "JRSONPropertyAnalyzing.h"

@implementation NSDataTransformer

- (BOOL)jrsn_canHandleWithClass:(Class)aClass {
    return jrsn__checkSubInherit(aClass, [NSData class]);
}

- (NSString *)jrsn_serializeObj:(id)obj {
    NSAssert([obj isKindOfClass:[NSData class]], @"本处理器只处理【NSData】");
    if ([obj length] > 1024 * 1024) {
        NSLog(@"序列化Data已经超过 1M；建议减少体积，或者忽略该字段 @see +[jrsn_ignoreProperties]");
    }
    return [obj base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
}

- (id)jrsn_deserializeJson:(id<JRSONValuable>)json withClass:(Class<JRSON>)aClass {
    NSAssert([json isKindOfClass:[NSString class]], @"%@ 不是字符串", json);
    return [[NSData alloc] initWithBase64EncodedString:(NSString *)json
                                               options:NSDataBase64DecodingIgnoreUnknownCharacters];
}

@end
