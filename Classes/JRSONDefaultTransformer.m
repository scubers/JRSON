//
//  JRSONDefaultTransformer.m
//  JRSON
//
//  Created by 王俊仁 on 2017/3/24.
//  Copyright © 2017年 jrwong. All rights reserved.
//

#import "JRSONDefaultTransformer.h"
#import "JRSON.h"
#import <objc/runtime.h>
#import "JRSONDefaultImplementations.h"
#import "JRSONPropertyAnalyzing.h"

//static BOOL jrsn_checkSubInherit(Class subClass, Class targetSuperClass) {
//    if (subClass == targetSuperClass) {
//        return YES;
//    }
//    Class realSuperClass = class_getSuperclass(subClass);
//    if (!realSuperClass) {
//        return NO;
//    }
//    return jrsn_checkSubInherit(realSuperClass, targetSuperClass);
//}


/////////////////////////////////////////////////////////////////////


/**
 主责处理
 - NSString 以及子类
 - NSNumber 以及子类
 - NSArray 以及子类
 - NSDictionary 以及子类
 - NSDate 以及子类
 - NSURL 以及子类
 */
@implementation JRSONDefaultTransformer

- (BOOL)jrsn_canHandleWithClass:(Class)aClass {
    return
    jrsn__checkSubInherit(aClass, [NSString class])
    ||jrsn__checkSubInherit(aClass, [NSNumber class])
    ||jrsn__checkSubInherit(aClass, [NSArray class])
    ||jrsn__checkSubInherit(aClass, [NSDictionary class])
    ||jrsn__checkSubInherit(aClass, [NSDate class])
    ||jrsn__checkSubInherit(aClass, [NSURL class])
    ;
}

#pragma mark 序列化

- (NSString *)jrsn_serializeObj:(id)obj {

    if (object_isClass(obj)) return nil;

    if ([obj isKindOfClass:[NSString class]]) {
        return [NSString stringWithFormat:@"\"%@\"", [self _jrsn_serializeString:obj]];
    }
    else if ([obj isKindOfClass:[NSNumber class]]) {
        return [NSString stringWithFormat:@"%@", obj];
    }
    else if ([obj isKindOfClass:[NSDate class]]) {
        return [NSString stringWithFormat:@"%@", @([((NSDate *)obj) timeIntervalSince1970] * 1000.0)];
    }
    else if ([obj isKindOfClass:[NSURL class]]) {
        return [NSString stringWithFormat:@"\"%@\"", ((NSURL *)obj).absoluteString];
    }
    else if ([obj isKindOfClass:[NSArray class]]) {
        return [self _jrsn_serializeArray:obj];
    }
    else if ([obj isKindOfClass:[NSDictionary class]]) {
        return [self _jrsn_serializeDictionary:obj];
    }
    else if ([obj conformsToProtocol:@protocol(JRSON)]) {
        return [self _jrsn_serializeJRSONObj:obj];
    }
    
    return nil;
}

- (NSString *)_jrsn_serializeString:(NSString *)aString {
    return [[aString stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"]
            stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
}

- (NSString *)_jrsn_serializeArray:(NSArray *)array {
    NSMutableString *json = [NSMutableString stringWithFormat:@"["];
    [array enumerateObjectsUsingBlock:^(id  _Nonnull subObj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *subjson = [JRSON parseObjToJSON:subObj];
        if (subjson) {
            [json appendFormat:@"%@,", subjson];
        }
    }];
    if ([json hasSuffix:@","]) {
        [json replaceCharactersInRange:NSMakeRange(json.length-1, 1) withString:@""];
    }
    [json appendString:@"]"];
    return json;
}

- (NSString *)_jrsn_serializeDictionary:(NSDictionary *)dictionary {
    NSMutableString *json = [NSMutableString stringWithFormat:@"{"];
    [dictionary enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull subObj, BOOL * _Nonnull stop) {
        NSString *subjsong = [JRSON parseObjToJSON:subObj];
        if (subjsong) {
            [json appendFormat:@"\"%@\":%@,", [key description], subjsong];
        }
    }];
    if ([json hasSuffix:@","]) {
        [json replaceCharactersInRange:NSMakeRange(json.length-1, 1) withString:@""];
    }
    [json appendString:@"}"];
    return json;
}

- (NSString *)_jrsn_serializeJRSONObj:(id<JRSON>)jrsonObj {
    
    NSMutableString *json = [NSMutableString stringWithFormat:@"{"];
    NSArray<JRSONPropertyInfo *> *infos = [[JRSONPropertyAnalyzing shared] analyzeClass:[jrsonObj class]];
    [infos enumerateObjectsUsingBlock:^(JRSONPropertyInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        id value = [(NSObject *)jrsonObj valueForKey:obj.name];
        if ([self objShouldBeIgnore:value]) return;

        NSString *subjson = [JRSON parseObjToJSON:value];
        if (subjson) {
            [json appendFormat:@"\"%@\":%@,", obj.name, subjson];
        }
    }];
    if ([json hasSuffix:@","]) {
        [json replaceCharactersInRange:NSMakeRange(json.length-1, 1) withString:@""];
    }
    [json appendString:@"}"];

    return json;
}

#pragma mark 反序列化

- (id<JRSON>)jrsn_deserializeJson:(id<JRSONValuable>)json withClass:(Class<JRSON>)aClass {

    if (jrsn__checkSubInherit(aClass, [NSDate class])) {
        if ([json jrsn_isString]) {
            return [NSDate dateWithTimeIntervalSince1970:[((NSString *)json) doubleValue] / 1000.0];
        } else if ([json jrsn_isNumber]) {
            return [NSDate dateWithTimeIntervalSince1970:[((NSNumber *)json) doubleValue] / 1000.0];
        } else {
            return nil;
        }
    }
    else if (jrsn__checkSubInherit(aClass, [NSURL class])) {
        if (![json jrsn_isString]) return nil;
        return [NSURL URLWithString:(NSString *)json];
    }
    else if (jrsn__checkSubInherit(aClass, [NSString class])) {
        return [NSString stringWithFormat:@"%@", json];
    }
    else if (jrsn__checkSubInherit(aClass, [NSNumber class])) {
        if ([json jrsn_isNumber]) {
            return json;
        } else if ([json jrsn_isString]) {
            return @([((NSString *)json) doubleValue]);
        } else {
            return nil;
        }
    }
    

    if ([json jrsn_isString]) {
        NSString *jsonString = (NSString *)json;
        NSError *error;
        id jsonObj = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:&error];
        if (error) {
            return nil;
        }
        return [self _jrsn_deserializeJson:jsonObj withClass:aClass dictExtraClass:nil];
    } else if ([json jrsn_isNumber]) {
        return json;
    }

    return [self _jrsn_deserializeJson:json withClass:aClass dictExtraClass:nil];
}


- (id<JRSON>)_jrsn_deserializeJson:(id<JRSONValuable>)json withClass:(Class<JRSON>)aClass dictExtraClass:(Class)extraClass {

    if (!class_conformsToProtocol(aClass, @protocol(JRSON))) return nil;

    if ([json jrsn_isString]) {
        return [JRSON formatJSON:json withClass:aClass];
    }
    else if ([json jrsn_isNumber]) {
        return [JRSON formatJSON:json withClass:aClass];
    }
    else if ([json jrsn_isArray]) {
        NSArray *array = (NSArray *)json;
        NSMutableArray *newArray = [NSMutableArray arrayWithCapacity:array.count];
        [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [newArray addObject:[self _jrsn_deserializeJson:obj withClass:aClass dictExtraClass:nil]];
        }];
        return newArray;
    }
    else if ([json jrsn_isDictionary]) {

        if (jrsn__checkSubInherit(aClass, [NSDictionary class])) {
            // 是一个字典

            if (![json jrsn_isDictionary]) return nil;

            NSMutableDictionary *dict = [NSMutableDictionary dictionary];

            NSDictionary *jsonDict = (NSDictionary *)json;

            [jsonDict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                id<JRSON> subobj = [self _jrsn_deserializeJson:obj withClass:extraClass dictExtraClass:nil];
                if (subobj) {
                    dict[key] = subobj;
                }
            }];

            return dict;

        } else {
            // 是一个对象
            NSDictionary *dict = (NSDictionary *)json;
            Class targetClass = aClass;

            // 创建一个对象
            id targetObj = [[targetClass alloc] init];

            NSArray<JRSONPropertyInfo *> *infos = [[JRSONPropertyAnalyzing shared] analyzeClass:targetClass];

            [infos enumerateObjectsUsingBlock:^(JRSONPropertyInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {

                // 在jsonvalue中获取对应的值
                id<JRSONValuable> subValue = dict[obj.name];

                if (subValue) {

                    switch (obj.type) {
                        case JRSONPropertyTypeArray:
                        {
                            if (obj.arrayClass) {
                                [targetObj setValue:[self _jrsn_deserializeJson:subValue withClass:obj.arrayClass dictExtraClass:nil] forKey:obj.name];
                            }
                            break;
                        }
                        case JRSONPropertyTypeDictionary:
                        {
                            if (obj.dictClass) {
                                [targetObj setValue:[self _jrsn_deserializeJson:subValue withClass:obj.targetClass dictExtraClass:obj.dictClass] forKey:obj.name];
                            }
                            break;
                        }
                        default:
                        {
                            [targetObj setValue:[self _jrsn_deserializeJson:subValue withClass:obj.targetClass dictExtraClass:nil] forKey:obj.name];
                            break;
                        }
                    }
                }

            }];

            return targetObj;
        }

    }

    return nil;
}

#pragma mark private method

- (BOOL)objShouldBeIgnore:(id)obj {
    BOOL flag1 = object_isClass(obj);
    return flag1 || obj == nil;
}

@end
