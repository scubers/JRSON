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

static BOOL jrsn_checkSubInherit(Class subClass, Class targetSuperClass) {
    if (subClass == targetSuperClass) {
        return YES;
    }
    Class realSuperClass = class_getSuperclass(subClass);
    if (!realSuperClass) {
        return NO;
    }
    return jrsn_checkSubInherit(realSuperClass, targetSuperClass);
}


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
    jrsn_checkSubInherit(aClass, [NSString class])
    ||jrsn_checkSubInherit(aClass, [NSNumber class])
    ||jrsn_checkSubInherit(aClass, [NSArray class])
    ||jrsn_checkSubInherit(aClass, [NSDictionary class])
    ||jrsn_checkSubInherit(aClass, [NSDate class])
    ||jrsn_checkSubInherit(aClass, [NSURL class])
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

    unsigned int outCount = 0;
    objc_property_t *props = class_copyPropertyList([jrsonObj class], &outCount);
    for (int i = 0 ; i < outCount; i ++) {
        NSString *name = [NSString stringWithUTF8String:property_getName(props[i])];
        if ([self keyShouldBeIgnore:name]) continue;

        id value = [(NSObject *)jrsonObj valueForKey:name];
        if ([self objShouldBeIgnore:value]) continue;

        NSString *subjson = [JRSON parseObjToJSON:value];
        if (subjson) {
            [json appendFormat:@"\"%@\":%@,", name, subjson];
        }
    }
    free(props);
    if ([json hasSuffix:@","]) {
        [json replaceCharactersInRange:NSMakeRange(json.length-1, 1) withString:@""];
    }
    [json appendString:@"}"];

    return json;
}

#pragma mark 反序列化

- (id<JRSON>)jrsn_deserializeJson:(id<JRSONValuable>)json withClass:(Class<JRSON>)aClass {

    if (jrsn_checkSubInherit(aClass, [NSDate class])) {
        if ([json jrsn_isString]) {
            return [NSDate dateWithTimeIntervalSince1970:[((NSString *)json) doubleValue] / 1000.0];
        } else if ([json jrsn_isNumber]) {
            return [NSDate dateWithTimeIntervalSince1970:[((NSNumber *)json) doubleValue] / 1000.0];
        } else {
            return nil;
        }
    }
    else if (jrsn_checkSubInherit(aClass, [NSURL class])) {
        if (![json jrsn_isString]) return nil;
        return [NSURL URLWithString:(NSString *)json];
    }
    else if (jrsn_checkSubInherit(aClass, [NSString class])) {
        return [NSString stringWithFormat:@"%@", json];
    }
    else if (jrsn_checkSubInherit(aClass, [NSNumber class])) {
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

        if (jrsn_checkSubInherit(aClass, [NSDictionary class])) {
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

            unsigned int outCount = 0;
            objc_property_t *props = class_copyPropertyList(targetClass, &outCount);
            for (int i = 0 ; i < outCount; i ++) {

                // 遍历属性名
                NSString *name = [NSString stringWithUTF8String:property_getName(props[i])];
                if ([self keyShouldBeIgnore:name]) continue;

                // 在jsonvalue中获取对应的值
                id<JRSONValuable> subValue = dict[name];

                if (subValue) {
                    if ([subValue jrsn_isArray]) {
                        NSDictionary *dict = [aClass jrsn_arrayPropertiesClassMap];
                        Class subClass = dict[name];
                        if (subClass) {
                            [targetObj setValue:[self _jrsn_deserializeJson:subValue withClass:subClass dictExtraClass:nil] forKey:name];
                        } else {
                            @try {
                                [targetObj setValue:subValue forKey:name];
                            } @catch (NSException *exception) {
                                NSLog(@"%@", exception);
                            }
                        }
                    }
                    else if ([subValue jrsn_isDictionary]) {
                        char *typeString = property_copyAttributeValue(props[i], "T");
                        Class subClass = [self classForPropertyTypeAttr:typeString];
                        free(typeString);
                        if (subClass) {
                            Class extraClass = nil;

                            if (jrsn_checkSubInherit(subClass, [NSDictionary class])) {
                                NSDictionary *dict = [aClass jrsn_dictPropertiesClassMap];
                                extraClass = dict[name];
                            }
                            [targetObj setValue:[self _jrsn_deserializeJson:subValue withClass:subClass dictExtraClass:extraClass] forKey:name];
                        } else {
                            @try {
                                [targetObj setValue:subValue forKey:name];
                            } @catch (NSException *exception) {
                                NSLog(@"%@", exception);
                            }
                        }
                    }
                    else {
                        char *typeString = property_copyAttributeValue(props[i], "T");
                        Class subClass = [self classForPropertyTypeAttr:typeString];
                        free(typeString);
                        [targetObj setValue:[self _jrsn_deserializeJson:subValue withClass:subClass dictExtraClass:nil] forKey:name];
                    }
                }
                
            }
            free(props);
            return targetObj;
        }

    }

    return nil;
}

#pragma mark private method


/**
 获取Property的属性对应的类

 @param type ---->   『@"NSString<JRSON>"』  『@"<UITableDelegate>"』  之类的
 @return return 返回 NSClassFromString(@"NSString")
 */
- (Class)classForPropertyTypeAttr:(const char *)type {

    if (
        strcmp(type, @encode(float)) == 0
        || strcmp(type, @encode(double)) == 0

        || strcmp(type, @encode(int)) == 0
        || strcmp(type, @encode(unsigned int)) == 0

        || strcmp(type, @encode(long)) == 0
        || strcmp(type, @encode(unsigned long)) == 0

        || strcmp(type, @encode(long long)) == 0
        || strcmp(type, @encode(unsigned long long)) == 0

        || strcmp(type, @encode(short)) == 0
        || strcmp(type, @encode(unsigned short)) == 0

        || strcmp(type, @encode(char)) == 0
        || strcmp(type, @encode(unsigned char)) == 0

        || strcmp(type, @encode(BOOL)) == 0
        ) {
        return [NSNumber class];
    }

    NSString *typeString = [NSString stringWithUTF8String:type];

    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\<[^\\>\\<]+\\>"
                                                                           options:NSRegularExpressionCaseInsensitive error:&error];

    typeString = [regex stringByReplacingMatchesInString:typeString options:NSMatchingReportCompletion range:NSMakeRange(0, typeString.length) withTemplate:@""];

    typeString =
    [[typeString stringByReplacingOccurrencesOfString:@"@" withString:@""]
     stringByReplacingOccurrencesOfString:@"\"" withString:@""];

    return NSClassFromString(typeString);
}

- (BOOL)keyShouldBeIgnore:(NSString *)key {
    return
    [key isEqualToString:@"hash"]
    ||[key isEqualToString:@"description"]
    ||[key isEqualToString:@"superclass"]
    ||[key isEqualToString:@"debugDescription"]
    ;
}

- (BOOL)objShouldBeIgnore:(id)obj {
    BOOL flag1 = object_isClass(obj);
    return flag1 || obj == nil;
}

@end
