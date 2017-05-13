//
//  JRSONNewTransformer.h
//  JRSON
//
//  Created by 王俊仁 on 2017/5/12.
//  Copyright © 2017年 J. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JRSONProtocols.h"


/**
 负责处理
 - NSString 以及子类
 - NSNumber 以及子类
 - NSDate 以及子类
 - NSURL 以及子类
 - NSData 以及子类
 */
@interface JRSONNewTransformer : NSObject <JRSONTransformer>

@end
