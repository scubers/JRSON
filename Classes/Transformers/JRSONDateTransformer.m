//
//  JRSONDateTransformer.m
//  JRSON
//
//  Created by 王俊仁 on 2017/5/15.
//  Copyright © 2017年 J. All rights reserved.
//

#import "JRSONDateTransformer.h"

@implementation JRSONDateTransformer

- (BOOL)jrsn_canHandleWithClass:(Class)aClass {
    return [aClass isSubclassOfClass:[NSDate class]];
}

- (id<JRSONValuable>)jrsn_serializeObj:(id<JRSON>)obj {
    return @([((NSDate *)obj) timeIntervalSince1970] * 1000.0);
}

- (id<JRSON>)jrsn_deserializeJson:(id<JRSONValuable>)json withClass:(Class<JRSON>)aClass {
    return [NSDate dateWithTimeIntervalSince1970:[((NSNumber *)json) doubleValue] / 1000.0];
}

@end
