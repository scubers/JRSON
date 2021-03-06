//
//  Animal.h
//  JRSON
//
//  Created by 王俊仁 on 2017/3/23.
//  Copyright © 2017年 jrwong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JRSONProtocols.h"


@class Dog;
@class LittleDog;

@interface Animal : NSObject <JRSON>

@property (nonatomic, strong) NSString *xxxxx;

@property (nonatomic, strong) NSArray *animalsDog;

@end


@interface Person : Animal <JRSON>
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) int age;
@property (nonatomic, assign) BOOL isMale;
@property (nonatomic, strong) NSDate *birthday;
@property (nonatomic, strong) NSURL *homepage;
@property (nonatomic, strong) Dog *dog;
@property (nonatomic, strong) NSArray<Dog *> *dogs;
@property (nonatomic, strong) NSDictionary<NSString *, Dog *> *nameDogs;
@property (nonatomic, strong) NSString *json;

@property (nonatomic, strong, readonly) NSString *notKVO;

@property (nonatomic, strong) NSData *data;

@property (nonatomic, strong) NSArray *strings;
@property (nonatomic, strong) NSDictionary *dicts;

@property (nonatomic, strong) NSArray *strangeArray;
@property (nonatomic, strong) NSDictionary *strangeDict;

@property (nonatomic, strong) LittleDog *littleDog;


- (instancetype)setup;

@end

@interface Dog : NSObject <JRSON>

@property (nonatomic, strong) NSString *name;

- (instancetype)setup;

@end

@interface LittleDog : NSObject <JRSON>

@property (nonatomic, strong) NSString *abaaaa;

@end



@interface LittleDogTransformer : NSObject <JRSONTransformer>



@end
