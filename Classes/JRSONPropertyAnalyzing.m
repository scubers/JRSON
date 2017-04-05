//
//  JRSONPropertyAnalyzing.m
//  JRSON
//
//  Created by 王俊仁 on 2017/4/5.
//  Copyright © 2017年 J. All rights reserved.
//

#import "JRSONPropertyAnalyzing.h"
#import <objc/runtime.h>

BOOL jrsn__checkSubInherit(Class subClass, Class targetSuperClass) {
    if (subClass == targetSuperClass) {
        return YES;
    }
    Class realSuperClass = class_getSuperclass(subClass);
    if (!realSuperClass) {
        return NO;
    }
    return jrsn__checkSubInherit(realSuperClass, targetSuperClass);
}

@implementation JRSONPropertyInfo
@end


@interface JRSONPropertyAnalyzing ()

@property (nonatomic, strong) NSMutableDictionary<NSString *, NSArray<JRSONPropertyInfo *> *> *infos;

@end

@implementation JRSONPropertyAnalyzing

static id __instance;
+ (instancetype)shared {
    if (__instance) return __instance;
    return [[self alloc] init];
}
+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __instance = [super allocWithZone:zone];
    });
    return __instance;
}

- (NSArray<JRSONPropertyInfo *> *)analyzeClass:(Class<JRSON>)aClass {
    NSArray<JRSONPropertyInfo *> *cacheInfo = self.infos[NSStringFromClass(aClass)];
    if (cacheInfo) return cacheInfo;

    NSMutableArray *info = [NSMutableArray array];

    JRSONPropertyInfo *propertyInfo = nil;
    unsigned int outCount = 0;
    objc_property_t *props = class_copyPropertyList(aClass, &outCount);
    for (int i = 0 ; i < outCount; i ++) {
        objc_property_t prop = props[i];

        NSString *name = [NSString stringWithUTF8String:property_getName(prop)];
        if ([self keyShouldBeIgnore:name]) continue;

        char *typeString = property_copyAttributeValue(prop, "T");
        Class propClass = [self classForPropertyTypeAttr:typeString];
        free(typeString);

        if (!propClass) {
            continue;
        }

        propertyInfo = [JRSONPropertyInfo new];
        propertyInfo.name = name;

        propertyInfo.targetClass = propClass;
        if (jrsn__checkSubInherit(propClass, [NSString class])) {
            propertyInfo.type = JRSONPropertyTypeString;
        }
        else if (jrsn__checkSubInherit(propClass, [NSNumber class])) {
            propertyInfo.type = JRSONPropertyTypeNumber;
        }
        else if (jrsn__checkSubInherit(propClass, [NSURL class])) {
            propertyInfo.type = JRSONPropertyTypeURL;
        }
        else if (jrsn__checkSubInherit(propClass, [NSDate class])) {
            propertyInfo.type = JRSONPropertyTypeDate;
        }
        else if (jrsn__checkSubInherit(propClass, [NSArray class])) {
            propertyInfo.type = JRSONPropertyTypeArray;
            Class clazz = [aClass jrsn_arrayPropertiesClassMap][name];
            NSAssert(!jrsn__checkSubInherit(clazz, [NSArray class]),
                     @"[%@ %@] 不能反序列化数组中的数组",
                     NSStringFromClass(aClass),
                     NSStringFromSelector(@selector(jrsn_arrayPropertiesClassMap)));
            NSAssert(!jrsn__checkSubInherit(clazz, [NSDictionary class]),
                     @"[%@ %@] 不能反序列化数组中的字典",
                     NSStringFromClass(aClass),
                     NSStringFromSelector(@selector(jrsn_arrayPropertiesClassMap)));
            propertyInfo.arrayClass = clazz;
        }
        else if (jrsn__checkSubInherit(propClass, [NSDictionary class])) {
            propertyInfo.type = JRSONPropertyTypeDictionary;
            Class clazz = [aClass jrsn_dictPropertiesClassMap][name];

            NSAssert(!jrsn__checkSubInherit(clazz, [NSArray class]),
                     @"[%@ %@] 不能反序列化数组中的数组",
                     NSStringFromClass(aClass),
                     NSStringFromSelector(@selector(jrsn_dictPropertiesClassMap)));
            NSAssert(!jrsn__checkSubInherit(clazz, [NSDictionary class]),
                     @"[%@ %@] 不能反序列化数组中的字典",
                     NSStringFromClass(aClass),
                     NSStringFromSelector(@selector(jrsn_dictPropertiesClassMap)));

            propertyInfo.dictClass = clazz;
        }
        else if (class_conformsToProtocol(aClass, @protocol(JRSON))) {
            propertyInfo.type = JRSONPropertyTypeJRSONObj;
            propertyInfo.subInfos = [self analyzeClass:propClass];
        }
        else {
            continue;
        }

        [info addObject:propertyInfo];
    }
    free(props);

    self.infos[NSStringFromClass(aClass)] = info;
    return info;

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


#pragma mark getter setter

- (NSMutableDictionary<NSString *, NSArray<JRSONPropertyInfo *> *> *)infos {
    if (!_infos) {
        _infos = [[NSMutableDictionary<NSString *, NSArray<JRSONPropertyInfo *> *> alloc] init];
    }
    return _infos;
}
@end
