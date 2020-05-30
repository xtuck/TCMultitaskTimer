//
//  FXStatusMonitor.m
//  FXPublicKit
//
//  Created by fengunion on 2018/5/23.
//

#import "TCMultitaskTimer.h"
#import "MSWeakTimer.h"

@interface FXTaskObject ()

@property (nonatomic,weak)  NSObject *taskKey;//每个任务对应的key,可以是obj对象
@property (nonatomic,assign) NSUInteger interval;//任务执行间隔时间
@property (nonatomic,assign) NSInteger currentCount;//任务执行中的计数
@property (nonatomic,assign) BOOL isDelay;//是否延迟执行，即跳过第一次
@property (nonatomic,copy) FXTaskBlock task;//任务执行block

@end

@implementation FXTaskObject

@end

@interface TCMultitaskTimer ()

@property (nonatomic,strong) NSTimer *timer;
@property (nonatomic,strong) NSMutableArray *taskArray;


@end

static NSTimeInterval const scTimeInterval = 1;

@implementation TCMultitaskTimer


+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    static TCMultitaskTimer *instance = nil;
    dispatch_once( &once, ^{ instance = [[TCMultitaskTimer alloc] init]; } );
    return instance;
}

- (void)startTask:(FXTaskObject *)object {
    if (self.timer) {
        object.currentCount = -scTimeInterval;
    } else {
        object.currentCount = 0;
    }
    object.taskStatus = FXTask_Continue;
    if (!object.isDelay) {
        object.task(object);
    }
    [self timerStart];
}

//任务重启
- (void)taskRestart:(NSObject *)taskKey {
    for (FXTaskObject *object in _taskArray) {
        if (object.taskKey == taskKey) {
            [self startTask:object];
            break;
        }
    }
}

//请求暂停
- (void)taskPause:(NSObject *)taskKey {
    for (FXTaskObject *object in _taskArray) {
        if (object.taskKey == taskKey) {
            if (object.taskStatus != FXTask_Finish) {
                object.taskStatus = FXTask_Pause;
            }
            [self checkAllTaskIsFinished];
            break;
        }
    }
}
//继续执行
- (void)taskContinue:(NSObject *)taskKey {
    for (FXTaskObject *object in _taskArray) {
        if (object.taskKey == taskKey && object.taskStatus == FXTask_Pause) {
//            object.taskStatus = FXTask_Running;
//            object.currentCount = 0;
//            object.task(object);
            object.taskStatus = FXTask_Continue;
            [self timerStart];
            break;
        }
    }
}


- (void)timerStart {
    if (!self.timer) {
        self.timer = [MSWeakTimer scheduledTimerWithTimeInterval:scTimeInterval
                                                          target:self
                                                        selector:@selector(timerDidFire:)
                                                        userInfo:nil
                                                         repeats:YES
                                                   dispatchQueue:dispatch_get_main_queue()];
    }
}

- (void)timerDidFire:(MSWeakTimer *)timer {
    NSMutableArray *tempArray = [[NSMutableArray alloc] initWithArray:self.taskArray];
    for (FXTaskObject *taskObject in tempArray) {
        switch (taskObject.taskStatus) {
            case FXTask_Running:
                break;
            case FXTask_Pause:
                [self checkAllTaskIsFinished];
                break;
            case FXTask_Finish:
                [self.taskArray removeObject:taskObject];
                [self checkAllTaskIsFinished];
                break;
            case FXTask_Continue:
                taskObject.currentCount += scTimeInterval;
                if (taskObject.currentCount>=taskObject.interval) {
                    taskObject.task(taskObject);
                    taskObject.currentCount = 0;
                }
                break;
            default:
                break;
        }
    }
}

- (void)timerStop {
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (NSMutableArray *)taskArray {
    if (!_taskArray) {
        _taskArray = [NSMutableArray array];
    }
    return _taskArray;
}

- (void)addTaskWithKey:(NSObject *)taskKey interval:(NSUInteger)interval task:(FXTaskBlock)task {
    [self addTaskWithKey:taskKey interval:interval isDelay:NO task:task];
}

- (void)addTaskWithKey:(NSObject *)taskKey interval:(NSUInteger)interval isDelay:(BOOL)isDelay task:(FXTaskBlock)task {
    if (task) {
        if (interval<=0||!taskKey) {
            if (!isDelay) {
                //没有key，或者没有间隔时间，不延迟执行，则只立即执行一次
                task(nil);
            }
        } else {
            NSMutableArray *tempArray = [[NSMutableArray alloc] initWithArray:_taskArray];
            for (FXTaskObject *tObject in tempArray) {
                if (tObject.taskKey == taskKey) {
                    //任务已存在
                    return;
                }
            }
            
            FXTaskObject *taskObject = [[FXTaskObject alloc] init];
            taskObject.taskKey = taskKey;
            taskObject.isDelay = isDelay;
            taskObject.interval = interval;
            taskObject.task = task;
            __weak typeof(self) weakSelf = self;
            //taskKey为字符串常量时，hook无效，停止定时器后，请外部调用removeTaskWithKey:
            [taskKey hookAutoRemovalSEL:NSSelectorFromString(@"dealloc") before:^{
                [weakSelf removeTaskWithKey:nil];
            }];
            [self.taskArray addObject:taskObject];
            [self startTask:taskObject];
        }
    }
}

- (void)removeTaskWithKey:(NSObject *)taskKey {
    NSMutableArray *tempArray = [[NSMutableArray alloc] initWithArray:_taskArray];
    for (FXTaskObject *object in tempArray) {
        if (object.taskKey == taskKey) {
            //object.task = nil;
            [self.taskArray removeObject:object];
        }
    }
    [self checkAllTaskIsFinished];
}

- (void)checkAllTaskIsFinished {
    bool isCanStopTimer = YES;
    for (FXTaskObject *object in _taskArray) {
        if (object.taskStatus == FXTask_Running || object.taskStatus == FXTask_Continue) {
            isCanStopTimer = NO;
            break;
        }
    }
    if (isCanStopTimer) {
        [self timerStop];
    }
}

@end
