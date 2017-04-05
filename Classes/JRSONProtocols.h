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

+ (NSDictionary<NSString *, Class<JRSON>> *)jrsn_arrayPropertiesClassMap;

+ (NSDictionary<NSString *, Class<JRSON>> *)jrsn_dictPropertiesClassMap;

- (NSString *)jrsn_jsonString;

@end

////////////////////////////////////////////////////////////////////////

/// 可以作为json的值的协议
/// NSString, NSNumber, NSDictionary, NSArray都遵守本协议
@protocol JRSONValuable <JRSON>
- (BOOL)jrsn_isNumber;
- (BOOL)jrsn_isString;
- (BOOL)jrsn_isArray;
- (BOOL)jrsn_isDictionary;
@end


////////////////////////////////////////////////////////////////////////

/// 将对象转化成JSON字符串的工具
@protocol JRSONSerializer <NSObject>

- (NSString *)jrsn_serializeObj:(id)obj;

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
