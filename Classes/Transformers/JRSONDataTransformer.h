//
//  JRSONDataTransformer.h
//  JRSON
//
//  Created by 王俊仁 on 2017/5/5.
//  Copyright © 2017年 J. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JRSONProtocols.h"

@interface JRSONDataTransformer : NSObject <JRSONTransformer>

@end

@interface NSData (JRSONDataTransformer) <JRSON>

@end
