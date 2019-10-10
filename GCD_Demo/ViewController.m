//
//  ViewController.m
//  GCD_Demo
//
//  Created by 安静的为你歌唱 on 2019/10/7.
//  Copyright © 2019 安静的为你歌唱. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor redColor];
    
    //    [self syncConcurrentTask];
    //    [self asyncConcurrentTask];
    //    [self syncSerialTask];
    //    [self syncMainTask];
    //    [NSThread detachNewThreadSelector:@selector(syncMainTask) toTarget:self withObject:nil];
    //    [self asyncMainTask];
    //    [self reloadData];
    //    [self barrierAsyncTask];
    //    [self afterTask];
    //    [self applyTask];
    //    [self asyncGroupTask];
    //    [self asyncGroupTask];
    //    [self asyncGroupEnterAndLeaveTask];
    [self asyncSemaphoreTask];
}

/**
 * 同步执行 + 并发队列
 * 特点：在当前线程中执行任务，不会开启新线程，执行完一个任务，再执行下一个任务。
 */
- (void)syncConcurrentTask {
    NSLog(@"当前线程：%@",[NSThread currentThread]);
    NSLog(@"syncConcurrentTask 开始");
    //并发队列
    dispatch_queue_t queue = dispatch_queue_create("com.tsbdj.gcd", DISPATCH_QUEUE_CONCURRENT);
    // 同步执行
    
    //任务1
    dispatch_sync(queue, ^{
        for (NSInteger index = 0; index < 2; ++index) {
            [NSThread sleepForTimeInterval:2];
            NSLog(@"任务1 线程：%@", [NSThread currentThread]);
        }
    });
    //任务2
    dispatch_sync(queue, ^{
        for (NSInteger index = 0; index < 2; index ++ ) {
            [NSThread sleepForTimeInterval:2];
            NSLog(@"任务2线程: %@",[NSThread currentThread]);
        }
    });
    
    //任务3
    dispatch_sync(queue, ^{
        for (NSInteger index = 0; index < 2; index ++ ) {
            [NSThread sleepForTimeInterval:2];
            NSLog(@"任务3线程: %@",[NSThread currentThread]);
        }
    });
    
    NSLog(@"syncConcurrentTask : end");
}

- (void)asyncConcurrentTask {
    NSLog(@"当前线程 : %@",[NSThread currentThread]);
    NSLog(@"asyncConcurrentTask : begin");
    
    dispatch_queue_t queue = dispatch_queue_create("com.tsbdj.gcd", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_async(queue, ^{
        for (NSInteger index = 0; index < 2; index ++ ) {
            [NSThread sleepForTimeInterval:2];                    // 休眠2s，模拟耗时操作
            NSLog(@"任务1线程: %@",[NSThread currentThread]);      // 打印当前线程
        }
    });
    dispatch_async(queue, ^{
        for (NSInteger index = 0; index < 2; index ++ ) {
            [NSThread sleepForTimeInterval:2];                    // 休眠2s，模拟耗时操作
            NSLog(@"任务2线程: %@",[NSThread currentThread]);      // 打印当前线程
        }
    });
    dispatch_async(queue, ^{
        for (NSInteger index = 0; index < 2; index ++ ) {
            [NSThread sleepForTimeInterval:2];                    // 休眠2s，模拟耗时操作
            NSLog(@"任务2线程: %@",[NSThread currentThread]);      // 打印当前线程
        }
    });
    NSLog(@"syncConcurrentTask : end");
}

- (void) syncSerialTask {
    NSLog(@"当前线程 : %@",[NSThread currentThread]);
    NSLog(@"asyncConcurrentTask : begin");
    
    dispatch_queue_t queue = dispatch_queue_create("com.tsbdj.gcd", DISPATCH_QUEUE_SERIAL);
    
    dispatch_sync(queue, ^{
        for (NSInteger index = 0; index < 2; index ++ ) {
            [NSThread sleepForTimeInterval:2];                    // 休眠2s，模拟耗时操作
            NSLog(@"任务1线程: %@",[NSThread currentThread]);      // 打印当前线程
        }
    });
    dispatch_sync(queue, ^{
        for (NSInteger index = 0; index < 2; index ++ ) {
            [NSThread sleepForTimeInterval:2];                    // 休眠2s，模拟耗时操作
            NSLog(@"任务2线程: %@",[NSThread currentThread]);      // 打印当前线程
        }
    });
    dispatch_sync(queue, ^{
        for (NSInteger index = 0; index < 2; index ++ ) {
            [NSThread sleepForTimeInterval:2];                    // 休眠2s，模拟耗时操作
            NSLog(@"任务3线程: %@",[NSThread currentThread]);      // 打印当前线程
        }
    });
    NSLog(@"syncConcurrentTask : end");
}

- (void)asyncSerialTask {
    NSLog(@"当前线程 : %@",[NSThread currentThread]);
    NSLog(@"asyncSerialTask : begin");
    
    dispatch_queue_t queue = dispatch_queue_create("com.tsbdj.gcd", DISPATCH_QUEUE_SERIAL);
    dispatch_async(queue, ^{
        for (NSInteger index = 0; index < 0; ++index) {
            [NSThread sleepForTimeInterval:2];
            NSLog(@"任务1线程: %@",[NSThread currentThread]);
        }
    });
    
    dispatch_async(queue, ^{
        for (NSInteger index = 0; index < 0; ++index) {
            [NSThread sleepForTimeInterval:2];
            NSLog(@"任务2线程: %@",[NSThread currentThread]);
        }
    });
    
    dispatch_async(queue, ^{
        for (NSInteger index = 0; index < 0; ++index) {
            [NSThread sleepForTimeInterval:2];
            NSLog(@"任务3线程: %@",[NSThread currentThread]);
        }
    });
    
    NSLog(@"asyncSerialTask : end");
}

- (void)syncMainTask {
    NSLog(@"当前线程 : %@",[NSThread currentThread]);
    NSLog(@"syncMainTask : begin");
    dispatch_queue_t queue = dispatch_get_main_queue();
    
    dispatch_sync(queue, ^{
        for (NSInteger index = 0; index < 2; index ++ ) {
            [NSThread sleepForTimeInterval:2];                    // 休眠2s，模拟耗时操作
            NSLog(@"任务1线程: %@",[NSThread currentThread]);      // 打印当前线程
        }
    });
    dispatch_sync(queue, ^{
        for (NSInteger index = 0; index < 2; index ++ ) {
            [NSThread sleepForTimeInterval:2];                    // 休眠2s，模拟耗时操作
            NSLog(@"任务2线程: %@",[NSThread currentThread]);      // 打印当前线程
        }
    });
    dispatch_sync(queue, ^{
        for (NSInteger index = 0; index < 2; index ++ ) {
            [NSThread sleepForTimeInterval:2];                    // 休眠2s，模拟耗时操作
            NSLog(@"任务3线程: %@",[NSThread currentThread]);      // 打印当前线程
        }
    });
}

- (void)asyncMainTask {
    NSLog(@"当前线程 : %@",[NSThread currentThread]);
    NSLog(@"asyncMainTask : begin");
    dispatch_queue_t queue = dispatch_get_main_queue();
    dispatch_async(queue, ^{
        for (NSInteger index = 0; index < 2; ++index) {
            [NSThread sleepForTimeInterval:2];
            NSLog(@"任务1线程: %@",[NSThread currentThread]);
        }
    });
    dispatch_async(queue, ^{
        for (NSInteger index = 0; index < 2; ++index) {
            [NSThread sleepForTimeInterval:2];
            NSLog(@"任务2线程: %@",[NSThread currentThread]);
        }
    });
    dispatch_async(queue, ^{
        for (NSInteger index = 0; index < 2; ++index) {
            [NSThread sleepForTimeInterval:2];
            NSLog(@"任务3线程: %@",[NSThread currentThread]);
        }
    });
    NSLog(@"asyncMainTask : end");
}

- (void)reloadData {
    //获取全局并发队列
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    //获取主队列
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    
    dispatch_async(queue, ^{
        for (NSInteger index = 0; index < 2; index ++ ) {
            [NSThread sleepForTimeInterval:2];                    // 休眠2s，模拟耗时操作
            NSLog(@"异步线程: %@",[NSThread currentThread]);       // 打印当前线程
        }
        
        dispatch_async(mainQueue, ^{
            //主线程，更新UI等等
            [NSThread sleepForTimeInterval:2];                    // 休眠2s，模拟耗时操作
            NSLog(@"主线程: %@",[NSThread currentThread]);       // 打印当前线程
        });
    });
}

//栅栏方法
- (void)barrierAsyncTask {
    NSLog(@"当前线程 : %@",[NSThread currentThread]);
    NSLog(@"barrierAsyncTask : begin");
    
    dispatch_queue_t queue = dispatch_queue_create("com.tsbdj.gcd", DISPATCH_QUEUE_CONCURRENT);
    //任务1
    dispatch_async(queue, ^{
        for (NSInteger index = 0; index < 2; index ++ ) {
            [NSThread sleepForTimeInterval:2];                    // 休眠2s，模拟耗时操作
            NSLog(@"任务1线程: %@",[NSThread currentThread]);      // 打印当前线程
        }
    });
    
    //任务2
    dispatch_async(queue, ^{
        for (NSInteger index = 0; index < 2; index ++ ) {
            [NSThread sleepForTimeInterval:2];                    // 休眠2s，模拟耗时操作
            NSLog(@"任务2线程: %@",[NSThread currentThread]);      // 打印当前线程
        }
    });
    
    //栅栏方法
    dispatch_barrier_async(queue, ^{
        for (NSInteger index = 0; index < 2; index ++ ) {
            [NSThread sleepForTimeInterval:2];                    // 休眠2s，模拟耗时操作
            NSLog(@"栅栏方法 barrier: %@",[NSThread currentThread]);      // 打印当前线程
        }
    });
    
    //任务3
    dispatch_async(queue, ^{
        for (NSInteger index = 0; index < 2; index ++ ) {
            [NSThread sleepForTimeInterval:2];                    // 休眠2s，模拟耗时操作
            NSLog(@"任务3线程: %@",[NSThread currentThread]);      // 打印当前线程
        }
    });
    
    //任务4
    dispatch_async(queue, ^{
        for (NSInteger index = 0; index < 2; index ++ ) {
            [NSThread sleepForTimeInterval:2];                    // 休眠2s，模拟耗时操作
            NSLog(@"任务4线程: %@",[NSThread currentThread]);      // 打印当前线程
        }
    });
    
    NSLog(@"barrierAsyncTask : end");
}

- (void)afterTask {
    NSLog(@"当前线程：%@",[NSThread currentThread]);
    NSLog(@"afterTask : begin");
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 2.0秒后异步追加任务代码到主队列，并开始执行
        NSLog(@"延时任务: %@",[NSThread currentThread]);  // 打印当前线程
    });
    NSLog(@"afterTask: end");
}

- (void)onceTask {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //只执行一次的代码（默认线程安全的）
    });
}

- (void)applyTask {
    NSLog(@"applyTask: begin");
    //    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_queue_t queue = dispatch_queue_create("com.tsbdj.gcd", DISPATCH_QUEUE_CONCURRENT);
    dispatch_apply(100, queue, ^(size_t index) {
        NSLog(@"applyTask -- %ld: %@",index,[NSThread currentThread]);  // 打印当前线程
    });
    NSLog(@"applyTask : end");
}

- (void)asyncGroupTask {
    NSLog(@"当前线程 : %@",[NSThread currentThread]);
    NSLog(@"asyncGroupTask : begin");
    
    dispatch_group_t queue = dispatch_group_create();
    
    //任务1
    dispatch_group_async(queue, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (NSInteger index = 0; index < 2; index ++ ) {
            [NSThread sleepForTimeInterval:2];                    // 休眠2s，模拟耗时操作
            NSLog(@"任务1线程: %@",[NSThread currentThread]);      // 打印当前线程
        }
    });
    
    //任务1
    dispatch_group_async(queue, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (NSInteger index = 0; index < 2; index ++ ) {
            [NSThread sleepForTimeInterval:4];                    // 休眠2s，模拟耗时操作
            NSLog(@"任务1线程: %@",[NSThread currentThread]);      // 打印当前线程
        }
    });
    
    dispatch_group_notify(queue, dispatch_get_main_queue(), ^{
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"主线程: %@",[NSThread currentThread]);      // 打印当前线程
        }
        NSLog(@"asyncGroupTask : end");
    });
}

- (void)asyncGroupWaitTask{
    NSLog(@"当前线程 : %@",[NSThread currentThread]);
    NSLog(@"asyncGroupWaitTask : begin");
    
    dispatch_group_t group = dispatch_group_create();
    
    //任务1
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (NSInteger index = 0; index < 2; index ++ ) {
            [NSThread sleepForTimeInterval:2];                    // 休眠2s，模拟耗时操作
            NSLog(@"任务1线程: %@",[NSThread currentThread]);      // 打印当前线程
        }
    });
    
    //任务2
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (NSInteger index = 0; index < 2; index ++ ) {
            [NSThread sleepForTimeInterval:2];                    // 休眠2s，模拟耗时操作
            NSLog(@"任务2线程: %@",[NSThread currentThread]);      // 打印当前线程
        }
    });
    
    // 等待上面的任务全部完成后，会往下继续执行（会阻塞当前线程）
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    
    NSLog(@"asyncGroupWaitTask : end");
}

- (void)asyncGroupEnterAndLeaveTask {
    NSLog(@"当前线程 : %@",[NSThread currentThread]);
    NSLog(@"asyncGroupEnterAndLeaveTask : begin");
    
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_enter(group);
    dispatch_async(queue, ^{
        for (NSInteger index = 0; index < 2; index ++ ) {
            [NSThread sleepForTimeInterval:2];                    // 休眠2s，模拟耗时操作
            NSLog(@"任务1线程: %@",[NSThread currentThread]);      // 打印当前线程
        }
        dispatch_group_leave(group);
    });
    
    dispatch_group_enter(group);
    dispatch_async(queue, ^{
        for (NSInteger index = 0; index < 2; index ++ ) {
            [NSThread sleepForTimeInterval:2];                    // 休眠2s，模拟耗时操作
            NSLog(@"任务2线程: %@",[NSThread currentThread]);      // 打印当前线程
        }
        dispatch_group_leave(group);
    });
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        // 等前面的异步任务1、任务2都执行完毕后，回到主线程执行下边任务
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"主线程: %@",[NSThread currentThread]);      // 打印当前线程
        }
        NSLog(@"asyncGroupEnterAndLeaveTask : end");
    });
}

- (void)asyncSemaphoreTask {
    NSLog(@"当前线程 : %@",[NSThread currentThread]);
    NSLog(@"asyncSemaphoreTask : begin");
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block NSInteger number = 0;
    dispatch_async(queue, ^{
        for (NSInteger index = 0; index < 2; index ++ ) {
            [NSThread sleepForTimeInterval:2];                    // 休眠2s，模拟耗时操作
            NSLog(@"任务1线程: %@",[NSThread currentThread]);      // 打印当前线程
        }
        number = 100;
        dispatch_semaphore_signal(semaphore);
    });
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    NSLog(@"asyncSemaphoreTask: end,number = %zd",number);
}

@end
