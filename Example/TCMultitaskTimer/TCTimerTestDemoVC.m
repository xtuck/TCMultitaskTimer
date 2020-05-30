//
//  TCTimerTestDemoVC.m
//  TCMultitaskTimer_Example
//
//  Created by fengunion on 2020/5/30.
//  Copyright © 2020 xtuck. All rights reserved.
//

#import "TCTimerTestDemoVC.h"
#import "TCMultitaskTimer.h"
#import "TCTimerTestDemoVC2.h"

@interface TCTimerTestDemoVC ()

@end

@implementation TCTimerTestDemoVC


static NSString * const kTimerKey = @"kTimerKey";


- (void)nextVC {
    TCTimerTestDemoVC2 *vc = [[TCTimerTestDemoVC2 alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = NSStringFromClass(self.class);
    
    UIBarButtonItem *rightBar = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFastForward target:self action:@selector(nextVC)];
    self.navigationItem.rightBarButtonItem = rightBar;

    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(50, 100, 200, 50);
    [btn setTitle:@"Restart timerTask" forState:UIControlStateNormal];
    btn.backgroundColor = [UIColor orangeColor];
    [self.view addSubview:btn];
    [btn addTarget:self action:@selector(testRestartTask) forControlEvents:UIControlEventTouchUpInside];
    
    
    UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn2.frame = CGRectMake(50, 200, 200, 50);
    [btn2 setTitle:@"Pause timerTask" forState:UIControlStateNormal];
    btn2.backgroundColor = [UIColor orangeColor];
    [btn2 addTarget:self action:@selector(testPauseTask) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn2];

    __weak typeof(self) weakSelf = self;
    [[TCMultitaskTimer sharedInstance] addTaskWithKey:kTimerKey interval:3 isDelay:YES task:^(TCTaskObject *status) {
        [weakSelf testAction];
    }];
}

- (void)testRestartTask {
    [[TCMultitaskTimer sharedInstance] taskRestart:kTimerKey];
}

- (void)testPauseTask {
    [[TCMultitaskTimer sharedInstance] taskPause:kTimerKey];
}

- (void)testAction {
    NSLog(@"定时器任务...........3");
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[TCMultitaskTimer sharedInstance] taskContinue:kTimerKey];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[TCMultitaskTimer sharedInstance] taskPause:kTimerKey];
}
- (void)dealloc {
    [[TCMultitaskTimer sharedInstance] removeTaskWithKey:kTimerKey];
    NSLog(@"控制器已销毁，定时器任务3停止");
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
