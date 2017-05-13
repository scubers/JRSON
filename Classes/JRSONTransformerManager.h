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

@property (nonatomic, strong) id<JRSONTransformer> defaultTransformer;

- (void)setTransformer:(id<JRSONTransformer>)transformer forClass:(Class<JRSON>)aClass;

- (void)removeTransformerForClass:(Class<JRSON>)aClass;


- (id<JRSONValuable>)jsonValueFromObj:(id<JRSON>)obj;

- (id<JRSON>)objFromJSONValue:(id<JRSONValuable>)jsonValue class:(Class<JRSON>)aClass;




@end
