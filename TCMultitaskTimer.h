//
//  FXStatusMonitor.h
//  FXPublicKit
//
//  Created by fengunion on 2018/5/23.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger,FXTaskStatus) {
    FXTask_Continue,//继续执行
    FXTask_Running,//执行中
    FXTask_Finish,//执行已完成
    FXTask_Pause//请求暂停
};

@interface FXTaskObject : NSObject

@property (nonatomic,assign) FXTaskStatus taskStatus;//任务执行状态

@end

typedef void (^FXTaskBlock)(FXTaskObject *status);

@interface TCMultitaskTimer : NSObject


+ (instancetype)sharedInstance;

- (void)addTaskWithKey:(NSObject *)taskKey
              interval:(NSUInteger)interval
                  task:(FXTaskBlock)task;

/**
添加需要重复执行的任务，例如要求任务必须执行成功的的请求：版本更新检查，注册推送，注销推送，等等

@param taskKey 任务的唯一id
@param interval 任务重复执行间隔
@param isDelay 增加任务时，是否延迟执行
@param task 执行任务的block
*/
- (void)addTaskWithKey:(NSObject *)taskKey
              interval:(NSUInteger)interval
               isDelay:(BOOL)isDelay
                  task:(FXTaskBlock)task;
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
