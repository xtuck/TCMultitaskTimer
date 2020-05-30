//
//  TCTimerTestDemoVC2.m
//  TCMultitaskTimer_Example
//
//  Created by fengunion on 2020/5/30.
//  Copyright © 2020 xtuck. All rights reserved.
//

#import "TCTimerTestDemoVC2.h"
#import "TCMultitaskTimer.h"

@interface TCTimerTestDemoVC2 ()

@end

@implementation TCTimerTestDemoVC2

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = NSStringFromClass(self.class);
    [[TCMultitaskTimer sharedInstance] addTaskWithKey:self interval:7 task:^(TCTaskObject *status) {
        NSLog(@"定时器任务.......4");
    }];
}

- (void)dealloc {
    NSLog(@"控制器已销毁，定时器任务4自动停止");
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
