//
//  JRSON.m
//  JRSON
//
//  Created by 王俊仁 on 2017/3/23.
//  Copyright © 2017年 jrwong. All rights reserved.
//

#import "JRSONUtil.h"
#import <objc/runtime.h>
#import "JRSONDefaultImplementations.h"
#import "JRSONTransformerManager.h"


@interface JRSON ()

@end

@implementation JRSON

+ (void)load {

//    [MCMethodCopyer copyMethods:@[
//                                NSStringFromSelector(@selector(jrsn_jsonString)),
//                                NSStringFromSelector(@selector(jrsn_objectFromJSON:)),
//                                NSStringFromSelector(@selector(jrsn_copy)),
//                                ]
//                 fromProtocol:@protocol(JRSON)
//                    fromClass:[JRSNDefaultImp class]
//                      toClass:[NSObject class]];
}


#pragma mark json format method

+ (NSString *)jsonStringWithObject:(id<JRSON>)object {
    id<JRSONValuable> jsonValue = [[JRSONTransformerManager shared] jsonValueFromObj:object];
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:jsonValue options:0 error:&error];
    if (error) {
        NSLog(@"%@", error);
        return nil;
    }
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

+ (id<JRSON>)objectWithJSONString:(NSString *)jsonString class:(Class<JRSON>)aClass {

    NSError *error;
    id obj = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
    if (error) {
        NSLog(@"%@", error);
        return nil;
    }
    if (
        [((Class)aClass) isSubclassOfClass:[NSDictionary class]]
        ||
        [((Class)aClass) isSubclassOfClass:[NSArray class]]) {
        return obj;
    }
    return [[JRSONTransformerManager shared] objFromJSONValue:obj class:aClass];
}

#pragma mark json valuable method

+ (id<JRSONValuable>)jsonValueWithObject:(id<JRSON>)object {
    return [[JRSONTransformerManager shared] jsonValueFromObj:object];
}

+ (id<JRSON>)objectWithJSONValue:(id<JRSONValuable>)jsonValue class:(Class<JRSON>)aClass {
    return [[JRSONTransformerManager shared] objFromJSONValue:jsonValue class:aClass];
}


#pragma mark json transformer method

+ (void)addTransformer:(id<JRSONTransformer>)transformer {
    [[JRSONTransformerManager shared] addTransformer:transformer];
}


+ (void)removeTransformer:(Class<JRSONTransformer>)transformer {
    [[JRSONTransformerManager shared] removeTransformer:transformer];
}


@end

//////////////////////////////////////////////////////////////////////////////////////////////////






