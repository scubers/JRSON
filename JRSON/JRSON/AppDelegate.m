//
//  AppDelegate.m
//  JRSON
//
//  Created by J on 2016/12/22.
//  Copyright © 2016年 J. All rights reserved.
//

#import "AppDelegate.h"
#import "JRSON.h"
#import "Animal.h"
#import "JRSONDefaultImplementations.h"


@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    Person *p = [Person new];
    NSString *json = [JRSON parseObjToJSON:p];
    NSLog(@"%@", json);
    p.json = json;
    json = [JRSON parseObjToJSON:p];

    NSLog(@"==========");
    NSLog(@"%@", json);
    Person *pp = [JRSON formatJSON:json withClass:[Person class]];
    NSLog(@"%@", pp);
    Person *ppp = [JRSON formatJSON:pp.json withClass:[Person class]];
    NSLog(@"%@", ppp);
    return YES;
}

@end
