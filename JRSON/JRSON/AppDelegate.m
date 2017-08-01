//
//  AppDelegate.m
//  JRSON
//
//  Created by J on 2016/12/22.
//  Copyright © 2016年 J. All rights reserved.
//

#import "AppDelegate.h"
#import "JRSONUtil.h"
#import "Animal.h"
#import "JRSONDefaultImplementations.h"
#import "JRSONPropertyAnalyzing.h"
#import "JRSONTransformerManager.h"
#import "JRSONDataTransformer.h"


@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    [[JRSONTransformerManager shared] addTransformer:[LittleDogTransformer new]];
//    [[JRSONTransformerManager shared] addTransformer:[JRSONDataTransformer new]];

    Person *p = [Person new];
    [p setup];

    NSArray *arr = @[p,p,p,p];

    NSString *json = [arr jrsn_jsonString];

    NSLog(@"%@", json);

    NSArray *newarr = [Person jrsn_objectFromJSON:json];

    NSDictionary *dict = @{@"key" : p};

    NSString *dictJson = [dict jrsn_jsonString];

    NSLog(@"%@", dictJson);

    return YES;
}

@end
