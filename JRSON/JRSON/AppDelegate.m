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
#import "JRSONTransformerManager.h"


@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {


//    [JRSON setTransformer:[LittleDogTransformer new] forClass:[LittleDog class]];

    [[JRSONTransformerManager shared] setTransformer:[LittleDogTransformer new] forClass:[LittleDog class]];

    Person *p = [Person new];
    [p setup];
    NSString *json = [p jrsn_jsonString];
    Person *np = [Person jrsn_objectFromJSON:json];
    NSLog(@"%@", json);
    p.json = json;
    json = [p jrsn_jsonString];

    NSLog(@"==========");
    NSLog(@"%@", json);
    Person *pp = [Person jrsn_objectFromJSON:json];
    NSLog(@"%@", pp);
    Person *ppp = [Person jrsn_objectFromJSON:pp.json];
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
