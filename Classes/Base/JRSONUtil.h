//
//  JRSON.h
//  JRSON
//
//  Created by 王俊仁 on 2017/3/23.
//  Copyright © 2017年 jrwong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JRSONProtocols.h"


////////////////////////////////////////////////////////////////////////

@interface JRSON : NSObject

#pragma mark json format method

+ (NSString *)jsonStringWithObject:(id<JRSON>)object;

+ (id<JRSON>)objectWithJSONString:(NSString *)jsonString class:(Class<JRSON>)aClass;

#pragma mark json valuable method

+ (id<JRSONValuable>)jsonValueWithObject:(id<JRSON>)object;

+ (id<JRSON>)objectWithJSONValue:(id<JRSONValuable>)jsonValue class:(Class<JRSON>)aClass;

#pragma mark json transformer method

+ (void)addTransformer:(id<JRSONTransformer>)transformer;

+ (void)removeTransformer:(Class<JRSONTransformer>)transformer;


@end


////////////////////////////////////////////////////////////////////////


