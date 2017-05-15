//
//  JRSONURLTransformer.m
//  JRSON
//
//  Created by 王俊仁 on 2017/5/15.
//  Copyright © 2017年 J. All rights reserved.
//

#import "JRSONURLTransformer.h"

@implementation JRSONURLTransformer

- (BOOL)jrsn_canHandleWithClass:(Class)aClass {
    return [aClass isSubclassOfClass:[NSURL class]];
}

- (id<JRSONValuable>)jrsn_serializeObj:(id<JRSON>)obj {
    return ((NSURL *)obj).absoluteString;
}

- (id<JRSON>)jrsn_deserializeJson:(id<JRSONValuable>)json withClass:(Class<JRSON>)aClass {
    return [NSURL URLWithString:(NSString *)json];
}

@end
