//
//  JRSONDefaultImplementations.m
//  JRSON
//
//  Created by 王俊仁 on 2017/3/24.
//  Copyright © 2017年 jrwong. All rights reserved.
//

#import "JRSONDefaultImplementations.h"
#import "JRSON.h"



@implementation NSString (JRSONDefaultImplementation)

- (JRSONValuableType)jrsn_valuableType {
    return JRSONValuableTypeString;
}

@end

@implementation NSNumber (JRSONDefaultImplementation)

- (JRSONValuableType)jrsn_valuableType {
    return JRSONValuableTypeNumber;
}


@end


@implementation NSArray (JRSONDefaultImplementation)

- (JRSONValuableType)jrsn_valuableType {
    return JRSONValuableTypeArray;
}


@end


@implementation NSDictionary (JRSONDefaultImplementation)

- (JRSONValuableType)jrsn_valuableType {
    return JRSONValuableTypeDictionary;
}


@end

@implementation NSDate (JRSONDefaultImplementation)
@end

@implementation NSURL (JRSONDefaultImplementation)
@end


///////////////////////////////////////////////////////////////////////////////////////////////////


@implementation JRSNDefaultImp

+ (NSArray<NSString *> *)jrsn_ignoreProperties {
    return nil;
}

+ (NSDictionary<NSString *, Class<JRSON>> *)jrsn_arrayPropertiesClassMap {
    return nil;
}

+ (NSDictionary<NSString *, Class<JRSON>> *)jrsn_dictPropertiesClassMap {
    return nil;
}

- (NSString *)jrsn_jsonString {
    return [JRSON jsonStringWithObject:(id<JRSON>)self];
}

+ (id)jrsn_objectFromJSON:(NSString *)json {
    return [JRSON objectWithJSONString:json class:self];
}

- (id)jrsn_copy {
    NSAssert(![self isKindOfClass:[NSDictionary class]], @"- jrsn_copy 不支持字典", self);
    NSAssert([self conformsToProtocol:@protocol(JRSON)], @"对象[%@], 未实现 protocol <JRSON>", self);
    if ([self isKindOfClass:[NSArray class]]) {

        NSMutableArray *newArray = [NSMutableArray array];
        [((NSArray *)self) enumerateObjectsUsingBlock:^(id<JRSON>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [newArray addObject:[obj jrsn_copy]];
        }];

        if ([self isKindOfClass:[NSMutableArray class]]) {
            return newArray;
        }
        return [newArray copy];
    }
    return [JRSON objectWithJSONString:[JRSON jsonStringWithObject:(id<JRSON>)self] class:self.class];
}


@end
