//
//  JRSONNumberTransformer.m
//  JRSON
//
//  Created by 王俊仁 on 2017/5/15.
//  Copyright © 2017年 J. All rights reserved.
//

#import "JRSONNumberTransformer.h"

@implementation JRSONNumberTransformer

- (BOOL)jrsn_canHandleWithClass:(Class)aClass {
    return [aClass isSubclassOfClass:[NSNumber class]];
}

- (id<JRSON>)jrsn_deserializeJson:(id<JRSONValuable>)json withClass:(Class<JRSON>)aClass {
    return json;
}

- (id<JRSONValuable>)jrsn_serializeObj:(id<JRSON>)obj {
    return (NSNumber *)obj;
}

@end
