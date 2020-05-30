//
//  TCMultitaskTimer.h
//
//  Created by xtuck on 2020/5/30.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger,TCTaskStatus) {
    TCTaskContinue, //继续执行
    TCTaskRunning,  //执行中
    TCTaskFinish,   //执行已完成
    TCTaskPause     //请求暂停
};

@interface TCTaskObject : NSObject

@property (nonatomic,assign) TCTaskStatus taskStatus;//任务执行状态

@end

typedef void (^TCTaskBlock)(TCTaskObject *status);

@interface TCMultitaskTimer : NSObject


+ (instancetype)sharedInstance;

- (void)addTaskWithKey:(NSObject *)taskKey
              interval:(NSUInteger)interval
                  task:(TCTaskBlock)task;

/**
添加需要重复执行的任务，例如要求任务必须执行成功的的请求：版本更新检查，注册推送，注销推送，等等

@param taskKey 任务的唯一id
@param interval 任务重复执行间隔
@param isDelay 增加任务时，是否延迟执行
@param task 执行任务的block,注意避免循环引用
*/
- (void)addTaskWithKey:(NSObject *)taskKey
              interval:(NSUInteger)interval
               isDelay:(BOOL)isDelay
                  task:(TCTaskBlock)task;
/**
 删除待执行的任务
 
 @param taskKey 任务的唯一id
 */
- (void)removeTaskWithKey:(NSObject *)taskKey;

//请求暂停
- (void)taskPause:(NSObject *)taskKey;
//继续执行
- (void)taskContinue:(NSObject *)taskKey;
//任务重启
- (void)taskRestart:(NSObject *)taskKey;

@end
