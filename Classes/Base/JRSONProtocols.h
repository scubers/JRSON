//
//  JRSONProtocols.h
//  JRSON
//
//  Created by 王俊仁 on 2017/3/24.
//  Copyright © 2017年 jrwong. All rights reserved.
//

#ifndef JRSONProtocols_h
#define JRSONProtocols_h

@protocol JRSON <NSObject>

@optional

+ (NSArray<NSString *> *)jrsn_ignoreProperties;

+ (NSDictionary<NSString *, Class<JRSON>> *)jrsn_arrayPropertiesClassMap;

+ (NSDictionary<NSString *, Class<JRSON>> *)jrsn_dictPropertiesClassMap;


/**
 将对象转化成json

 @return return value description
 */
- (NSString *)jrsn_jsonString;


/**
 返回id<JRSON> 或者 NSArray<id<JRSON>>

 @param json json description
 @return return value description
 */
+ (id)jrsn_objectFromJSON:(NSString *)json;


/**
 使用json的序列化和反序列化进行进行对象深copy

 @return return value description
 */
- (id)jrsn_copy;

@end

////////////////////////////////////////////////////////////////////////

typedef NS_ENUM(int, JRSONValuableType) {
    JRSONValuableTypeString,
    JRSONValuableTypeNumber,
    JRSONValuableTypeArray,
    JRSONValuableTypeDictionary,
};

/// 可以作为json的值的协议
/// NSString, NSNumber, NSDictionary, NSArray都遵守本协议
@protocol JRSONValuable <JRSON>

- (JRSONValuableType)jrsn_valuableType;

@end


////////////////////////////////////////////////////////////////////////

/// 将对象转化成JSON字符串的工具
@protocol JRSONSerializer <NSObject>

- (id<JRSONValuable>)jrsn_serializeObj:(id<JRSON>)obj;

@end

////////////////////////////////////////////////////////////////////////

/// 将JRSONValuable转化成对象的工具
@protocol JRSONDeserializer <NSObject>

- (id<JRSON>)jrsn_deserializeJson:(id<JRSONValuable>)json withClass:(Class<JRSON>)aClass;

@end


////////////////////////////////////////////////////////////////////////

/// 可以进行序列化和反序列化的工具
@protocol JRSONTransformer <JRSONSerializer, JRSONDeserializer>

- (BOOL)jrsn_canHandleWithClass:(Class)aClass;

@end


#endif /* JRSONProtocols_h */
