//
//  JRSONDefaultImplementations.m
//  JRSON
//
//  Created by 王俊仁 on 2017/3/24.
//  Copyright © 2017年 jrwong. All rights reserved.
//

#import "JRSONDefaultImplementations.h"
#import "JRSON.h"

@interface NSObject (JRSONDefaultImplementation)

@end

@implementation NSObject (JRSONDefaultImplementation)

+ (NSDictionary<NSString *, Class<JRSON>> *)jrsn_arrayPropertiesClassMap {
    return nil;
}

+ (NSDictionary<NSString *, Class<JRSON>> *)jrsn_dictPropertiesClassMap {
    return nil;
}

- (NSString *)jrsn_jsonString {
    return [JRSON parseObjToJSON:(id<JRSON>)self];
}

+ (id)jrsn_objectFromJSON:(NSString *)json {
    return [JRSON formatJSON:json withClass:self];
}

@end



@implementation NSString (JRSONDefaultImplementation)

- (BOOL)jrsn_isNumber {
    return [self isKindOfClass:[NSNumber class]];
}

- (BOOL)jrsn_isString {
    return [self isKindOfClass:[NSString class]];
}

- (BOOL)jrsn_isArray {
    return [self isKindOfClass:[NSArray class]];
}

- (BOOL)jrsn_isDictionary {
    return [self isKindOfClass:[NSDictionary class]];
}

@end

@implementation NSNumber (JRSONDefaultImplementation)

- (BOOL)jrsn_isNumber {
    return [self isKindOfClass:[NSNumber class]];
}

- (BOOL)jrsn_isString {
    return [self isKindOfClass:[NSString class]];
}

- (BOOL)jrsn_isArray {
    return [self isKindOfClass:[NSArray class]];
}

- (BOOL)jrsn_isDictionary {
    return [self isKindOfClass:[NSDictionary class]];
}

@end


@implementation NSArray (JRSONDefaultImplementation)

- (BOOL)jrsn_isNumber {
    return [self isKindOfClass:[NSNumber class]];
}

- (BOOL)jrsn_isString {
    return [self isKindOfClass:[NSString class]];
}

- (BOOL)jrsn_isArray {
    return [self isKindOfClass:[NSArray class]];
}

- (BOOL)jrsn_isDictionary {
    return [self isKindOfClass:[NSDictionary class]];
}

@end


@implementation NSDictionary (JRSONDefaultImplementation)

- (BOOL)jrsn_isNumber {
    return [self isKindOfClass:[NSNumber class]];
}

- (BOOL)jrsn_isString {
    return [self isKindOfClass:[NSString class]];
}

- (BOOL)jrsn_isArray {
    return [self isKindOfClass:[NSArray class]];
}

- (BOOL)jrsn_isDictionary {
    return [self isKindOfClass:[NSDictionary class]];
}

@end

@implementation NSDate (JRSONDefaultImplementation)
@end

@implementation NSURL (JRSONDefaultImplementation)
@end

