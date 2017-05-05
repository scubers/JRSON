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
#import "JRSONPropertyAnalyzing.h"
#import "NSDataTransformer.h"


@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

//    [JRSON setTransformer:[NSDataTransformer new] forClass:[NSData class]];

    Person *p = [Person new];
    [p setup];
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
    
    NSArray *a = [[JRSONPropertyAnalyzing shared] analyzeClass:[Person class]];

    UIImage *image = [UIImage imageNamed:@"test.png"];

    NSData *data = UIImagePNGRepresentation(image);

    NSDate *date = [NSDate date];
    NSString *string = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    NSData *newData = [[NSData alloc] initWithBase64EncodedString:string options:NSDataBase64DecodingIgnoreUnknownCharacters];
    NSLog(@"%f", [[NSDate date] timeIntervalSinceDate:date]);

    UIImage *newImage = [UIImage imageWithData:newData];

    return YES;
}

@end
