//
//  Animal.m
//  JRSON
//
//  Created by 王俊仁 on 2017/3/23.
//  Copyright © 2017年 jrwong. All rights reserved.
//

#import "Animal.h"


@implementation Person

- (instancetype)init {
    self = [super init];
    if (self) {
        _name = @"jac\\k\"";
        _age = 10;
        _isMale = YES;
        _birthday = [NSDate date];
        _homepage = [NSURL URLWithString:@"http://www.baidu.com"];
        _dog = [Dog new];
        _dogs = @[
                  [Dog new],
                  [Dog new],
                  [Dog new],
                  [Dog new],
                  [Dog new],
                  [Dog new],
                  ];
        _nameDogs = @{
                      @"abc" : [Dog new],
                      @"ddd" : [Dog new],
                      @"ccc" : [Dog new],
                      @"fff" : [Dog new],
                      @"ggg" : [Dog new],
                      @"rrr" : [Dog new],
                      @"tyy" : [Dog new],
                      };

    }
    return self;
}

+ (NSDictionary<NSString *,Class<JRSON>> *)jrsn_arrayPropertiesClassMap {
    return @{
             @"dogs" : [Dog class],
             };
}

+ (NSDictionary<NSString *,Class<JRSON>> *)jrsn_dictPropertiesClassMap {
    return @{
             @"nameDogs" : [Dog class],
             };
}



@end

@implementation Dog

- (instancetype)init
{
    self = [super init];
    if (self) {
        _name = @"job";
    }
    return self;
}

@end
