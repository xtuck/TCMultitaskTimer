//
//  TCAppDelegate.m
//  TCMultitaskTimer
//
//  Created by xtuck on 05/30/2020.
//  Copyright (c) 2020 xtuck. All rights reserved.
//

#import "TCAppDelegate.h"
#import "TCViewController.h"
#import "TCMultitaskTimer.h"

@implementation TCAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:[[TCViewController alloc] init]];
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [self versionUpdateCheck];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(void)versionUpdateCheck{
    [[TCMultitaskTimer sharedInstance] addTaskWithKey:@"检查版本更新" interval:30 task:^(TCTaskObject *taskObject){
        //此设置目的：任务等待网络请求返回结果后，才进行30秒间隔的计时
//        taskObject.taskStatus = TCTaskRunning;
        
        NSLog(@"定时器任务1:检查版本更新.............");
        //通过控制taskStatus状态来控制定时器任务，得到正确结果后，该定时器任务就停止，否则一直循环执行
//        [TCVersionApi checkVersion:^(NSDictionary *result,NSError *error) {
//            if (error) {
//                taskObject.taskStatus = TCTaskContinue;
//                //NSLog(@"版本更新检查出错:%@",error.description);
//            } else {
//                taskObject.taskStatus = TCTaskFinish;
//                //NSLog(@"版本更新检查成功");
//            }
//        }];
    }];
}

@end
