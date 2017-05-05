//
//  JRSONDefaultImplementations.h
//  JRSON
//
//  Created by 王俊仁 on 2017/3/24.
//  Copyright © 2017年 jrwong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JRSONProtocols.h"


@interface NSString (JRSONDefaultImplementation) <JRSONValuable>
@end

@interface NSNumber (JRSONDefaultImplementation) <JRSONValuable>
@end

@interface NSArray (JRSONDefaultImplementation) <JRSONValuable>
@end

@interface NSDictionary (JRSONDefaultImplementation) <JRSONValuable>
@end

@interface NSDate (JRSONDefaultImplementation) <JRSON>
@end

@interface NSURL (JRSONDefaultImplementation) <JRSON>
@end

@interface NSData (JRSONDefaultImplementation) <JRSON>
@end







