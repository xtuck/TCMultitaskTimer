//
//  TCViewController.m
//  TCMultitaskTimer_Example
//
//  Created by fengunion on 2020/5/30.
//  Copyright © 2020 xtuck. All rights reserved.
//

#import "TCViewController.h"
#import "TCMultitaskTimer.h"
#import "TCTimerTestDemoVC.h"

@interface TCViewController ()

@end

@implementation TCViewController



- (void)nextVC {
    TCTimerTestDemoVC *vc = [[TCTimerTestDemoVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = NSStringFromClass(self.class);
    
    UIBarButtonItem *rightBar = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFastForward target:self action:@selector(nextVC)];
    self.navigationItem.rightBarButtonItem = rightBar;

    __weak typeof(self) weakSelf = self;
    [[TCMultitaskTimer sharedInstance] addTaskWithKey:self interval:5 task:^(TCTaskObject *status) {
        [weakSelf testAction];
    }];
}

- (void)testAction {
    NSLog(@"定时器任务2:测试...........");
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
