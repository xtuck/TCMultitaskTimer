//
//  TCMultitaskTimer.m
//
//  Created by xtuck on 2020/5/30.
//

#import "TCMultitaskTimer.h"
#import "MSWeakTimer.h"
#import "Aspects.h"
#import <objc/runtime.h>

@interface TCMTWeakContainer : NSObject

@property (nonatomic, weak) id weakObj;
@property (nonatomic, copy) id primitiveTK;
@property (nonatomic, assign) BOOL isPrimitiveTK;

@end

@implementation TCMTWeakContainer

@end

@interface TCTaskObject ()

@property (nonatomic,strong) NSObject *taskKey;//每个任务对应的key,obj对象
@property (nonatomic,assign) NSUInteger interval;//任务执行间隔时间
@property (nonatomic,assign) NSInteger currentCount;//任务执行中的计数
@property (nonatomic,assign) BOOL isDelay;//是否延迟执行，即跳过第一次
@property (nonatomic,copy) TCTaskBlock task;//任务执行block

+ (BOOL)isTKPrimitiveType:(NSObject *)key;

@end

@implementation TCTaskObject

- (NSObject *)taskKey {
    TCMTWeakContainer *container = objc_getAssociatedObject(self, _cmd);
    if (container.isPrimitiveTK) {
        return container.primitiveTK;
    }
    return container.weakObj;
}

- (void)setTaskKey:(NSObject *)taskKey {
    TCMTWeakContainer *container = nil;
    if (taskKey != nil) {
        container = [[TCMTWeakContainer alloc] init];
        container.isPrimitiveTK = [TCTaskObject isTKPrimitiveType:taskKey];
        if (container.isPrimitiveTK) {
            container.primitiveTK = taskKey;
        } else {
            container.weakObj = taskKey;
        }
    }
    objc_setAssociatedObject(self, @selector(taskKey), container, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (BOOL)isTKPrimitiveType:(NSObject *)key {
    if ([key isKindOfClass:NSString.class] ||
        [key isKindOfClass:NSNumber.class] ||
        [key isKindOfClass:NSData.class]) {
        return YES;
    }
    return NO;
}

@end

@interface TCMultitaskTimer ()

@property (nonatomic,strong) MSWeakTimer *timer;
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

- (void)startTask:(TCTaskObject *)object {
    if (self.timer) {
        object.currentCount = -scTimeInterval;
    } else {
        object.currentCount = 0;
    }
    object.taskStatus = TCTaskContinue;
    if (!object.isDelay) {
        object.task(object);
    }
    [self timerStart];
}

//任务重启
- (void)taskRestart:(NSObject *)taskKey {
    for (TCTaskObject *object in _taskArray) {
        if (object.taskKey == taskKey) {
            [self startTask:object];
            break;
        }
    }
}

//请求暂停
- (void)taskPause:(NSObject *)taskKey {
    for (TCTaskObject *object in _taskArray) {
        if (object.taskKey == taskKey) {
            if (object.taskStatus != TCTaskFinish) {
                object.taskStatus = TCTaskPause;
            }
            [self checkAllTaskIsFinished];
            break;
        }
    }
}
//继续执行
- (void)taskContinue:(NSObject *)taskKey {
    for (TCTaskObject *object in _taskArray) {
        if (object.taskKey == taskKey && object.taskStatus == TCTaskPause) {
            object.taskStatus = TCTaskContinue;
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
    for (TCTaskObject *taskObject in tempArray) {
        switch (taskObject.taskStatus) {
            case TCTaskRunning:
                break;
            case TCTaskPause:
                [self checkAllTaskIsFinished];
                break;
            case TCTaskFinish:
                [self.taskArray removeObject:taskObject];
                [self checkAllTaskIsFinished];
                break;
            case TCTaskContinue:
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

- (void)addTaskWithKey:(NSObject *)taskKey interval:(NSUInteger)interval task:(TCTaskBlock)task {
    [self addTaskWithKey:taskKey interval:interval isDelay:NO task:task];
}

- (void)addTaskWithKey:(NSObject *)taskKey interval:(NSUInteger)interval isDelay:(BOOL)isDelay task:(TCTaskBlock)task {
    if (task) {
        if (interval<=0||!taskKey) {
            if (!isDelay) {
                //没有key，或者没有间隔时间，不延迟执行，则只立即执行一次
                task(nil);
            }
        } else {
            for (TCTaskObject *tObject in _taskArray) {
                if (tObject.taskKey == taskKey) {
                    //任务已存在
                    return;
                }
            }
            TCTaskObject *taskObject = [[TCTaskObject alloc] init];
            taskObject.taskKey = taskKey;
            taskObject.isDelay = isDelay;
            taskObject.interval = interval;
            taskObject.task = task;
            //taskKey为基本数据类型时，被调用的对象销毁后，请外部调用removeTaskWithKey:来停止定时器
            if (![TCTaskObject isTKPrimitiveType:taskKey]) {
                __weak typeof(self) weakSelf = self;
                [taskKey aspect_hookSelector:NSSelectorFromString(@"dealloc") withOptions:AspectPositionBefore usingBlock:^(id<AspectInfo> aspectInfo) {
                    [weakSelf removeTaskWithKey:nil];
                } error:nil];
            }
            [self.taskArray addObject:taskObject];
            [self startTask:taskObject];
        }
    }
}

- (void)removeTaskWithKey:(NSObject *)taskKey {
    NSMutableArray *tempArray = [[NSMutableArray alloc] initWithArray:_taskArray];
    for (TCTaskObject *object in tempArray) {
        if (object.taskKey == taskKey) {
            [self.taskArray removeObject:object];
        }
    }
    [self checkAllTaskIsFinished];
}

- (void)checkAllTaskIsFinished {
    bool isCanStopTimer = YES;
    for (TCTaskObject *object in _taskArray) {
        if (object.taskStatus == TCTaskRunning || object.taskStatus == TCTaskContinue) {
            isCanStopTimer = NO;
            break;
        }
    }
    if (isCanStopTimer) {
        [self timerStop];
    }
}

@end
