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

+ (NSString *)objectToJSON:(id<JRSON>)object;

+ (id<JRSON>)JSONToObject:(NSString *)json class:(Class<JRSON>)aClass;


- (void)addTransformer:(id<JRSONTransformer>)transformer;

- (void)removeTransformer:(Class<JRSONTransformer>)transformer;


@end


////////////////////////////////////////////////////////////////////////


