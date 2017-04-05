//
//  JRSONPropertyAnalyzing.h
//  JRSON
//
//  Created by 王俊仁 on 2017/4/5.
//  Copyright © 2017年 J. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JRSONProtocols.h"

BOOL jrsn__checkSubInherit(Class subClass, Class targetSuperClass);

typedef NS_ENUM(NSInteger, JRSONPropertyType) {
    JRSONPropertyTypeString,
    JRSONPropertyTypeNumber,
    JRSONPropertyTypeArray,
    JRSONPropertyTypeDictionary,
    JRSONPropertyTypeDate,
    JRSONPropertyTypeURL,
    JRSONPropertyTypeJRSONObj,
};

@interface JRSONPropertyInfo : NSObject

@property (nonatomic, assign) JRSONPropertyType type;

@property (nonatomic, copy  ) NSString *name;

@property (nonatomic, strong) Class<JRSON> targetClass;

@property (nonatomic, strong) Class<JRSON> arrayClass;

@property (nonatomic, strong) Class<JRSON> dictClass;

@property (nonatomic, strong) NSArray<JRSONPropertyInfo *> *subInfos;

@end


////////////////////////////////////////////////

@interface JRSONPropertyAnalyzing : NSObject

+ (instancetype)shared;

- (NSArray<JRSONPropertyInfo *> *)analyzeClass:(Class<JRSON>)aClass;

@end
