//
//  JRSON.m
//  JRSON
//
//  Created by 王俊仁 on 2017/3/23.
//  Copyright © 2017年 jrwong. All rights reserved.
//

#import "JRSON.h"
#import <objc/runtime.h>
#import "JRSONDefaultImplementations.h"
#import "JRSONNewTransformer.h"
#import "JRSONTransformerManager.h"
@import MethodCopyer;


@interface JRSON ()

@end

@implementation JRSON

+ (void)load {

    [MethodCopyer copyMethods:@[
                                NSStringFromSelector(@selector(jrsn_jsonString)),
                                NSStringFromSelector(@selector(jrsn_objectFromJSON:)),
                                NSStringFromSelector(@selector(jrsn_copy)),
                                ]
                 fromProtocol:@protocol(JRSON)
                    fromClass:[JRSNDefaultImp class]
                      toClass:[NSObject class]];
}



+ (NSString *)objectToJSON:(id<JRSON>)object {
    id<JRSONValuable> jsonValue = [[JRSONTransformerManager shared] jsonValueFromObj:object];
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:jsonValue options:0 error:&error];
    if (error) {
        NSLog(@"%@", error);
        return nil;
    }
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

+ (id<JRSON>)JSONToObject:(NSString *)json class:(Class<JRSON>)aClass {
    NSError *error;
    id obj = [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
    if (error) {
        NSLog(@"%@", error);
        return nil;
    }
    return [[JRSONTransformerManager shared] objFromJSONValue:obj class:aClass];
}



@end

//////////////////////////////////////////////////////////////////////////////////////////////////






