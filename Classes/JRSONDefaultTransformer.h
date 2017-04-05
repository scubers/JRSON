//
//  JRSONDefaultTransformer.h
//  JRSON
//
//  Created by 王俊仁 on 2017/3/24.
//  Copyright © 2017年 jrwong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JRSONProtocols.h"


/**
 负责处理
 - NSString 以及子类
 - NSNumber 以及子类
 - NSArray 以及子类
 - NSDictionary 以及子类
 - NSDate 以及子类
 - NSURL 以及子类
 */
@interface JRSONDefaultTransformer : NSObject <JRSONTransformer>

@end
