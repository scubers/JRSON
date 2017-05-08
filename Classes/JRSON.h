//
//  JRSON.h
//  JRSON
//
//  Created by 王俊仁 on 2017/3/23.
//  Copyright © 2017年 jrwong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JRSONProtocols.h"


////////////////////////////////////////////////////////////////////////

@interface JRSON : NSObject


/**
 设置指定类的转化器

 @param transformer transformer description
 @param aClass aClass description
 */
+ (void)setTransformer:(id<JRSONTransformer>)transformer forClass:(Class<JRSON>)aClass;


+ (NSString *)parseObjToJSON:(id<JRSON>)obj;


+ (id<JRSON>)formatJSON:(id<JRSONValuable>)json withClass:(Class<JRSON>)aClass;

+ (BOOL)_canCustomFormatClass:(Class<JRSON>)aClass;

@end


////////////////////////////////////////////////////////////////////////


