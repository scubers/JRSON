//
//  JRSONTransformerManager.h
//  JRSON
//
//  Created by 王俊仁 on 2017/5/13.
//  Copyright © 2017年 J. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JRSONProtocols.h"

@interface JRSONTransformerManager : NSObject

+ (instancetype)shared;


- (void)addTransformer:(id<JRSONTransformer>)transformer;


- (void)removeTransformer:(Class<JRSONTransformer>)transformer;


- (id<JRSONValuable>)jsonValueFromObj:(id<JRSON>)obj;


- (id<JRSON>)objFromJSONValue:(id<JRSONValuable>)jsonValue class:(Class<JRSON>)aClass;




@end
