//
//  Animal.m
//  JRSON
//
//  Created by 王俊仁 on 2017/3/23.
//  Copyright © 2017年 jrwong. All rights reserved.
//

#import "Animal.h"
#import <UIKit/UIKit.h>
#import "JRSONDefaultImplementations.h"

@implementation Person

- (instancetype)init {
    self = [super init];
    if (self) {

    }
    return self;
}

+ (NSArray<NSString *> *)jrsn_ignoreProperties {
    return @[
//             @"data",
             ];
}

+ (NSDictionary<NSString *,Class<JRSON>> *)jrsn_arrayPropertiesClassMap {
    return @{
             @"dogs" : [Dog class],
             @"strings" : [NSString class],
//             @"strangeArray" : [NSDictionary class],
             };
}

+ (NSDictionary<NSString *,Class<JRSON>> *)jrsn_dictPropertiesClassMap {
    return @{
             @"nameDogs" : [Dog class],
             @"dicts" : [NSNumber class],
//             @"strangeDict" : [NSDictionary class],
             };
}

- (instancetype)setup {
    _name = @"ja\nc\\k\"------\t";
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
    [_dogs enumerateObjectsUsingBlock:^(Dog * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj setup];
    }];
    _nameDogs = @{
                  @"abc" : [Dog new],
                  @"ddd" : [Dog new],
                  @"ccc" : [Dog new],
                  @"fff" : [Dog new],
                  @"ggg" : [Dog new],
                  @"rrr" : [Dog new],
                  @"tyy" : [Dog new],
                  };

    [_nameDogs enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, Dog * _Nonnull obj, BOOL * _Nonnull stop) {
        [obj setup];
    }];

    _strings = @[
                 @"1",
                 @"2",
                 @"3",
                 @"4",
                 @"5",
                 ];

    _dicts = @{
               @"1" : @1,
               @"2" : @1,
               @"3" : @1,
               @"4" : @1,
               };

    _strangeArray = @[
                      @{@"11":@1},
                      @{@"12":@1},
                      @{@"13":@1},
                      @{@"14":@1},
                      ];

    _strangeDict = @{
                     @"array" : @[@1, @2],
                     @"dict" : @{
                                @"22": @22,
                                @"33": @33,
                             },
                     };

    _data = UIImagePNGRepresentation([UIImage imageNamed:@"test.png"]);

    _littleDog = [LittleDog new];
    
    return self;
}

- (NSString *)notKVO {
    return @"";
}

@end

@implementation Dog

- (instancetype)init
{
    self = [super init];
    if (self) {

    }
    return self;
}

- (instancetype)setup {
    _name = @"job";
    return self;
}

@end


@implementation LittleDog



@end


@implementation LittleDogTransformer

- (BOOL)jrsn_canHandleWithClass:(Class)aClass {
    return aClass == [LittleDog class];
}

- (id<JRSONValuable>)jrsn_serializeObj:(id)obj {
    return @{
             @"aaa" : @"bbb",
             };
}

- (id<JRSON>)jrsn_deserializeJson:(id<JRSONValuable>)json withClass:(Class<JRSON>)aClass {
    NSLog(@"%@----", json);
    return [LittleDog new];
}

@end
