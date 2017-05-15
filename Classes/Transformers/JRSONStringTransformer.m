//
//  JRSONStringTransformer.m
//  JRSON
//
//  Created by 王俊仁 on 2017/5/15.
//  Copyright © 2017年 J. All rights reserved.
//

#import "JRSONStringTransformer.h"

@implementation JRSONStringTransformer

- (BOOL)jrsn_canHandleWithClass:(Class)aClass {
    return [aClass isSubclassOfClass:[NSString class]];
}

- (id<JRSON>)jrsn_deserializeJson:(id<JRSONValuable>)json withClass:(Class<JRSON>)aClass {
    return json;
}

- (id<JRSONValuable>)jrsn_serializeObj:(id<JRSON>)obj {
    return (NSString *)obj;
}

@end
