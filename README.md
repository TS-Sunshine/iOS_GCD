一· GCD简介

```
Grand Central Dispatch(GCD) 是 Apple 开发的一个多核编程的较新的解决方法。
它主要用于优化应用程序以支持多核处理器以及其他对称多处理系统。是一个在线程池模式的基础上执行的并发任务
```

#### 为什么要用GCD呢？

```
1. GCD 可用于多核的并行运算
2. GCD 会自动利用更多的 CPU 内核（比如双核、四核）
3. GCD 会自动管理线程的生命周期（创建线程、调度任务、销毁线程）
4. 程序员只需要告诉GCD想要执行什么任务，不需要编写任何线程管理代码 

```

### 二·GCD任务和队列

#### 2.1任务

```
任务就是执行操作的意思，也就是在线程中所需要执行的那段代码，在GCD中的block中实现。
```

执行任务分为两种方式: **同步执行 (sync)** 和 **异步执行 (async)**

#### 同步执行

```
1.同步添加任务到指定的队列中，在添加的任务执行结束之前，会一直等待，直到队列里面的任务完成之后再继续执行。
2.只能在当前线程中执行任务，不具备开启新线程的能力。
```

#### 异步执行

```
1.异步添加任务到指定的队列中，它不会做任何等待，可以继续执行任务。
2.可以在新的线程中执行任务，具备开启新线程的能力。
```

#### 区别

```
是否等待队列的任务执行结束，以及是否具备开启新线程的能力。
```



#### 2.2队列（Dispatch Queue）

```
指执行任务的等待队列，即用来存放任务的队列。

队列是一种特殊的线性表，采用FIFO（先进先出）的原则，即新任务总是被插入到队列的末尾，而读取任务的时候总是从队列的头部开始读取。
每读取一个任务，则从队列中释放一个任务。
```



在GCD中有两种队列:

#### 串行队列（Serial Dispatch Queue)

```
每次只有一个任务被执行。让任务一个接着一个地执行。（只开启一个线程，一个任务执行完毕后，再执行下一个任务）
```

####  并发队列（Concurrent Dispatch Queue）

```
可以让多个任务并发（同时）执行。（可以开启多个线程，并且同时执行任务）
```

**注意：并发队列的并发功能只有在异步（dispatch async）函数下才有效**

#### 区别

```
执行顺序不同，以及开启线程数不同。
```



### 三·GCD的使用步骤

GCD 的使用步骤其实很简单，只有两步:

1. 创建一个队列（串行队列或者并发队列）。
2. 将任务追加到任务的等待队列中，然后系统就会根据任务类型执行任务（同步执行或异步执行）。

#### 3.1 队列的创建和获取

使用 dispatch_queue_create 来创建队列，需要传入两个参数:

```
1. 第一个参数表示队列的唯一标识符，用于 DEBUG，可为空，Dispatch Queue 的名称推荐使用应用程序 ID 这种逆序全程域名。
2. 第二个参数用来识别是串行队列还是并发队列。DISPATCH_QUEUE_SERIAL 表示串行队列、DISPATCH_QUEUE_CONCURRENT 表示并发队列
```

#### 方法如下

```objective-c
// 串行队列的创建方法
dispatch_queue_t queue = dispatch_queue_create("com.gcd.testQueue", DISPATCH_QUEUE_SERIAL);

// 并发队列的创建方法
dispatch_queue_t queue = dispatch_queue_create("com.gcd.testQueue", DISPATCH_QUEUE_CONCURRENT);
```



#### 主队列（Main Dispatch Queue）

主队列属于GCD中的一种特殊的串行队列，主有以下特点：

```
1. 所有放在主队列中的任务，都会放到主线程中执行。

2.可使用 dispatch_get_main_queue() 获得主队列。
```

#### 获取方法

```
// 主队列的获取方法
dispatch_queue_t queue = dispatch_get_main_queue();
```

#### 全局并发队列

在并发队列中使用，可以使用dispatch_get_global_queue 来获取。需要传入两个参数:

```
1.第一个参数表示队列优先级，一般用DISPATCH_QUEUE_PRIORITY_DEFAULT。

2.第二个参数暂时没用，用0即可。
```

#### 获取方法

```
// 全局并发队列的获取方法
dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

```

#### 3.2 任务的创建方法

GCD 提供了同步执行任务的创建方法dispatch_sync和异步执行任务创建方法dispatch_async。

```objective-c
// 同步执行任务创建方法
dispatch_sync(queue, ^{
    // 这里放同步执行任务代码
});

// 异步执行任务创建方法
dispatch_async(queue, ^{
    // 这里放异步执行任务代码
});
```

虽然使用 GCD 只需两步，但是既然我们有两种队列（串行队列/并发队列），两种任务执行方式（同步执行/异步执行），那么我们就有了四种不同的组合方式。这四种不同的组合方式是：

1. 同步执行 + 并发队列
2. 异步执行 + 并发队列
3. 同步执行 + 串行队列
4. 异步执行 + 串行队列

实际上，刚才还说了两种特殊队列：全局并发队列、主队列。全局并发队列可以作为普通并发队列来使用。但是主队列因为有点特殊，所以我们就又多了两种组合方式。这样就有六种不同的组合方式了

5. 同步执行 + 主队列
6. 异步执行 + 主队列

| 区别        | 串行队列                          | 并发队列                     | 主队列                       |
| ----------- | --------------------------------- | ---------------------------- | ---------------------------- |
| 同步(sync)  | 没有开启新线程，串行执行任务      | 没有开启新线程，串行执行任务 | 没有开启新线程，串行执行任务 |
| 异步(async) | 有开启新线程（1条），异步执行任务 | 有开启新线程，并发执行任务   | 没有开启新线程，串行执行任务 |



### 四· GCD的基本使用

#### 4.1同步队列 + 并发队列

```objective-c
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

```

日志输出：

```
2019-10-07 18:09:57.869226+0800 GCD_Demo[2676:468055] 当前线程：<NSThread: 0x600000246140>{number = 1, name = main}
2019-10-07 18:09:57.869461+0800 GCD_Demo[2676:468055] syncConcurrentTask 开始
2019-10-07 18:09:59.870183+0800 GCD_Demo[2676:468055] 任务1 线程：<NSThread: 0x600000246140>{number = 1, name = main}
2019-10-07 18:10:01.870867+0800 GCD_Demo[2676:468055] 任务1 线程：<NSThread: 0x600000246140>{number = 1, name = main}
2019-10-07 18:10:03.871465+0800 GCD_Demo[2676:468055] 任务2线程: <NSThread: 0x600000246140>{number = 1, name = main}
2019-10-07 18:10:05.871879+0800 GCD_Demo[2676:468055] 任务2线程: <NSThread: 0x600000246140>{number = 1, name = main}
2019-10-07 18:10:07.872111+0800 GCD_Demo[2676:468055] 任务3线程: <NSThread: 0x600000246140>{number = 1, name = main}
2019-10-07 18:10:09.873464+0800 GCD_Demo[2676:468055] 任务3线程: <NSThread: 0x600000246140>{number = 1, name = main}
2019-10-07 18:10:09.873635+0800 GCD_Demo[2676:468055] syncConcurrentTask : end

```

从执行（同步执行+并发队列）任务的输出日志中可以看到：

```
1.所有任务都是在当前线程（主线程）中执行的，没有开启新的线程（同步执行不具备开启新线程的能力）。
2.所有任务都是打印在syncConcurrentTask:begin 和syncConcurrentTask:end 之间执行的。（同步任务需要等待队列的任务执行结束）
3.任务按顺序执行。
按顺序执行的原因：虽然并发队列可以开启多个线程，并且同时执行多个任务。
但是因为本身不能创建新线程，只有当前线程这一个线程（同步任务不具备开启新线程的能力），所以也就不存在并发。而且当前线程只有等待当前队列中正在执行的任务执行完毕之后，才能继续接着执行下面的操作（同步任务需要等待队列的任务执行结束）所以任务只能一个接一个按顺序执行。
```

#### 4.2 异步执行 + 并发队列

可以开启多个线程，任务同时执行。

```objective-c
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
```

日志输出

```
2019-10-07 18:38:43.380622+0800 GCD_Demo[2912:621526] 当前线程 : <NSThread: 0x6000003f2140>{number = 1, name = main}
2019-10-07 18:38:43.380706+0800 GCD_Demo[2912:621526] asyncConcurrentTask : begin
2019-10-07 18:38:43.380794+0800 GCD_Demo[2912:621526] syncConcurrentTask : end
2019-10-07 18:38:45.383914+0800 GCD_Demo[2912:621768] 任务2线程: <NSThread: 0x60000039c100>{number = 4, name = (null)}
2019-10-07 18:38:45.383921+0800 GCD_Demo[2912:621766] 任务2线程: <NSThread: 0x600000384400>{number = 7, name = (null)}
2019-10-07 18:38:45.383913+0800 GCD_Demo[2912:621780] 任务1线程: <NSThread: 0x60000038c740>{number = 6, name = (null)}
2019-10-07 18:38:47.388254+0800 GCD_Demo[2912:621766] 任务2线程: <NSThread: 0x600000384400>{number = 7, name = (null)}
2019-10-07 18:38:47.388254+0800 GCD_Demo[2912:621768] 任务2线程: <NSThread: 0x60000039c100>{number = 4, name = (null)}
2019-10-07 18:38:47.388254+0800 GCD_Demo[2912:621780] 任务1线程: <NSThread: 0x60000038c740>{number = 6, name = (null)}
```

从执行（异步执行+ 并发队列）任务的输出日志中可以看到：

```
1.除了当前线程（主线程），系统又开启了三个线程，并且是交替/同时执行的。（异步执行具备开启新线程的能力）
2.所有任务都在打印的asyncConcurrentTask：begin和asyncConcurrentTask：end之后执行的。说明当前线程没有等到，而是直接开启了新的线程。在新线程中西拽任务（异步执行不必等待，可以继续执行）
```

#### 4.3 同步执行+串行队列

不会开启新线程，在当前线程执行任务。任务是串行的，执行完一个任务，在执行下一个任务。

```objective-c
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

```

输出日志

```
2019-10-07 18:55:05.886128+0800 GCD_Demo[3098:717450] 当前线程 : <NSThread: 0x600003905cc0>{number = 1, name = main}
2019-10-07 18:55:05.886221+0800 GCD_Demo[3098:717450] asyncConcurrentTask : begin
2019-10-07 18:55:07.887364+0800 GCD_Demo[3098:717450] 任务1线程: <NSThread: 0x600003905cc0>{number = 1, name = main}
2019-10-07 18:55:09.888402+0800 GCD_Demo[3098:717450] 任务1线程: <NSThread: 0x600003905cc0>{number = 1, name = main}
2019-10-07 18:55:11.889507+0800 GCD_Demo[3098:717450] 任务2线程: <NSThread: 0x600003905cc0>{number = 1, name = main}
2019-10-07 18:55:13.890365+0800 GCD_Demo[3098:717450] 任务2线程: <NSThread: 0x600003905cc0>{number = 1, name = main}
2019-10-07 18:55:15.891965+0800 GCD_Demo[3098:717450] 任务3线程: <NSThread: 0x600003905cc0>{number = 1, name = main}
2019-10-07 18:55:17.893323+0800 GCD_Demo[3098:717450] 任务3线程: <NSThread: 0x600003905cc0>{number = 1, name = main}
2019-10-07 18:55:17.893503+0800 GCD_Demo[3098:717450] syncConcurrentTask : end
```

从执行（同步执行+串行队列）任务的输出日志可以看到：

```
1.所有任务都是在当前线程（主线程）中执行的，并没有开启新的线程（同步执行不具备开启新线程的能力）。
2.所有任务都在打印的asyncConcurrentTask：begin和asyncConcurrentTask：end之间执行的。
3.任务是按顺序执行的（串行队列每次只有一个任务呗执行，任务一个接一个顺序执行）
```



#### 4.4 异步执行 + 串行队列

会开启新线程，但是因为任务是串行的，执行完一个任务，再执行下一个任务。

```objective-c
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
```

输出日志:

```
2019-10-07 20:00:59.078240+0800 GCD_Demo[1002:89329] 当前线程 : <NSThread: 0x60000381a200>{number = 1, name = main}
2019-10-07 20:00:59.078324+0800 GCD_Demo[1002:89329] asyncConcurrentTask : begin
2019-10-07 20:01:01.079491+0800 GCD_Demo[1002:89329] 任务1线程: <NSThread: 0x60000381a200>{number = 1, name = main}
2019-10-07 20:01:03.080565+0800 GCD_Demo[1002:89329] 任务1线程: <NSThread: 0x60000381a200>{number = 1, name = main}
2019-10-07 20:01:05.081193+0800 GCD_Demo[1002:89329] 任务2线程: <NSThread: 0x60000381a200>{number = 1, name = main}
2019-10-07 20:01:07.081802+0800 GCD_Demo[1002:89329] 任务2线程: <NSThread: 0x60000381a200>{number = 1, name = main}
2019-10-07 20:01:09.082740+0800 GCD_Demo[1002:89329] 任务3线程: <NSThread: 0x60000381a200>{number = 1, name = main}
2019-10-07 20:01:11.083086+0800 GCD_Demo[1002:89329] 任务3线程: <NSThread: 0x60000381a200>{number = 1, name = main}
2019-10-07 20:01:11.083208+0800 GCD_Demo[1002:89329] syncConcurrentTask : end
```

从执行（异步执行+串行队列）任务的输出日志中可以看到：

1. 开启了一条新线程（异步执行具备开启新线程的能力，串行队列只开启一个线程）
2. 所有任务是在打印的asyncConcurrentTask：begin和asyncConcurrentTask：end之后开始执行的，异步不会做任何等待，可以继续执行任务。
3. 任务是按顺序执行的（串行队列每次只有一个任务被执行，任务一个接一个按顺序执行）



#### 同步执行+主队列

**主队列：GCD自带的一种特殊的串行队列**

```
1.所有放在主队列中的任务，都会放到主线程中执行
2.可使用dispatch_get_main_queue()获得主队列
```

互相等待卡主。

```objective-c
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
```

日志输出

```
2019-10-07 20:56:07.683865+0800 GCD_Demo[1568:429039] 当前线程 : <NSThread: 0x600000baa200>{number = 1, name = main}
2019-10-07 20:56:07.683951+0800 GCD_Demo[1568:429039] syncMainTask : begin
```

从主线程执行（同步执行+主队列）任务的输出日志可以看到

```
1.在主线程使用同步执行+主队列，追加到主线程的任务1，任务2，任务3都不再执行了
```

### 在其他线程中调用同步执行+主队列

```
//使用NSThread的detachNewThreadSelector方法会创建线程，并自动启动线程执行
[NSThread detachNewThreadSelector:@selector(syncMainTask) toTarget:self withObject:nil];
```

日志输出

```
2019-10-07 21:08:01.673807+0800 GCD_Demo[1768:494204] 当前线程 : <NSThread: 0x600001f0b600>{number = 7, name = (null)}
2019-10-07 21:08:01.673888+0800 GCD_Demo[1768:494204] syncMainTask : begin
2019-10-07 21:08:03.680641+0800 GCD_Demo[1768:494050] 任务1线程: <NSThread: 0x600001f71d40>{number = 1, name = main}
2019-10-07 21:08:05.681759+0800 GCD_Demo[1768:494050] 任务1线程: <NSThread: 0x600001f71d40>{number = 1, name = main}
2019-10-07 21:08:07.690134+0800 GCD_Demo[1768:494050] 任务2线程: <NSThread: 0x600001f71d40>{number = 1, name = main}
2019-10-07 21:08:09.690885+0800 GCD_Demo[1768:494050] 任务2线程: <NSThread: 0x600001f71d40>{number = 1, name = main}
2019-10-07 21:08:11.692653+0800 GCD_Demo[1768:494050] 任务3线程: <NSThread: 0x600001f71d40>{number = 1, name = main}
2019-10-07 21:08:13.693498+0800 GCD_Demo[1768:494050] 任务3线程: <NSThread: 0x600001f71d40>{number = 1, name = main}
```

从其他线程执行，为什么就不会卡住？

```
答： 因为 syncMainTask 放到了其他线程里，而任务1、任务2、任务3都追加在主队列中，这三个任务都会在主线程中执行。
    syncMainTask任务在其他线程中执行追加到任务1到队列中，因为主队列现在没有正在执行的任务，
    所以，会直接执行主队列的任务1，等任务1执行完毕，再接着执行任务2、任务3。所以这里不会卡住线程。
```

#### 4.5 异步执行+主队列

只在主线程中执行任务，执行完一个任务，再执行下一个任务。

```objective-c
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
```

输出日志：

```
019-10-07 21:31:27.821865+0800 GCD_Demo[1982:624402] 当前线程 : <NSThread: 0x600002c261c0>{number = 1, name = main}
2019-10-07 21:31:27.822087+0800 GCD_Demo[1982:624402] asyncMainTask : begin
2019-10-07 21:31:27.822194+0800 GCD_Demo[1982:624402] asyncMainTask : end
2019-10-07 21:31:29.831639+0800 GCD_Demo[1982:624402] 任务1线程: <NSThread: 0x600002c261c0>{number = 1, name = main}
2019-10-07 21:31:31.832358+0800 GCD_Demo[1982:624402] 任务1线程: <NSThread: 0x600002c261c0>{number = 1, name = main}
2019-10-07 21:31:33.833010+0800 GCD_Demo[1982:624402] 任务2线程: <NSThread: 0x600002c261c0>{number = 1, name = main}
2019-10-07 21:31:35.833882+0800 GCD_Demo[1982:624402] 任务2线程: <NSThread: 0x600002c261c0>{number = 1, name = main}
2019-10-07 21:31:37.834613+0800 GCD_Demo[1982:624402] 任务3线程: <NSThread: 0x600002c261c0>{number = 1, name = main}
2019-10-07 21:31:39.836140+0800 GCD_Demo[1982:624402] 任务3线程: <NSThread: 0x600002c261c0>{number = 1, name = main}

```

从日志中可以看出：

```
1. 所有任务都是在当前线程（主线程）中执行的，并没有开启新的线程（虽然异步执行具备开启线程的能力，但因为是主队列，所以所有任务都在主线程中）。

2. 所有任务是在打印的syncConcurrent---begin和syncConcurrent---end之后才开始执行的（异步执行不会做任何等待，可以继续执行任务）。

3. 任务是按顺序执行的（因为主队列是串行队列，每次只有一个任务被执行，任务一个接一个按顺序执行）。
```



### 五·GCD线程间的通信

在iOS开发过程中，我们一般在主线程里边进行UI刷新，例如：点击、滚动、拖拽等事件。我们通常把一些耗时的操作放在其他线程，比如说图片下载、文件上传等耗时操作。而当我们有时候在其他线程完成了耗时操作时，就需要回到主线程，那么久用到了线程之间的通讯。

```objective-c
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
```

日志输出

```
2019-10-07 21:46:23.703741+0800 GCD_Demo[2135:700873] 异步线程: <NSThread: 0x6000005a54c0>{number = 7, name = (null)}
2019-10-07 21:46:25.708566+0800 GCD_Demo[2135:700873] 异步线程: <NSThread: 0x6000005a54c0>{number = 7, name = (null)}
2019-10-07 21:46:27.709128+0800 GCD_Demo[2135:700648] 主线程: <NSThread: 0x6000005d6200>{number = 1, name = main}
```

从执行任务的结果上看：

```
1.可以看到在其他线程中先执行任务，执行完了之后回到主线程执行主线程的相应操作。
```



### 六· GCD的特殊方法

在日常开发过程中，有时候需要一部执行两组操作，而且第一组操作执行完成以后，才能开始执行第二组操作，这样我们就需要一个相当于栅栏一样的一个方法将两组一部执行的操作组给分割起来，当然，这里的操作组里可以包含一个或多个任务。这就需要用到dispatch_barrier_async方法在两个操作组间形成栅栏。

```
dispatch_barrier_async 函数会等待前边追加到并发队列中的任务全部执行完毕之后，再将指定的任务追加到该异步队列中。
后在 dispatch_barrier_async 函数追加的任务执行完毕之后，异步队列才恢复为一般动作，接着追加任务到该异步队列并开始执行。
```

```objective-c
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
```

日志输出：

```
2019-10-07 22:14:02.372862+0800 GCD_Demo[2383:848067] 当前线程 : <NSThread: 0x600002189d40>{number = 1, name = main}
2019-10-07 22:14:02.373028+0800 GCD_Demo[2383:848067] barrierAsyncTask : begin
2019-10-07 22:14:02.373163+0800 GCD_Demo[2383:848067] barrierAsyncTask : end
2019-10-07 22:14:04.377751+0800 GCD_Demo[2383:848482] 任务2线程: <NSThread: 0x6000021dd200>{number = 5, name = (null)}
2019-10-07 22:14:04.377751+0800 GCD_Demo[2383:848474] 任务1线程: <NSThread: 0x6000021dcb00>{number = 4, name = (null)}
2019-10-07 22:14:06.381500+0800 GCD_Demo[2383:848474] 任务1线程: <NSThread: 0x6000021dcb00>{number = 4, name = (null)}
2019-10-07 22:14:06.381518+0800 GCD_Demo[2383:848482] 任务2线程: <NSThread: 0x6000021dd200>{number = 5, name = (null)}
2019-10-07 22:14:08.386062+0800 GCD_Demo[2383:848482] 栅栏方法 barrier: <NSThread: 0x6000021dd200>{number = 5, name = (null)}
2019-10-07 22:14:10.389920+0800 GCD_Demo[2383:848482] 栅栏方法 barrier: <NSThread: 0x6000021dd200>{number = 5, name = (null)}
2019-10-07 22:14:12.394270+0800 GCD_Demo[2383:848482] 任务3线程: <NSThread: 0x6000021dd200>{number = 5, name = (null)}
2019-10-07 22:14:12.394270+0800 GCD_Demo[2383:848474] 任务4线程: <NSThread: 0x6000021dcb00>{number = 4, name = (null)}
2019-10-07 22:14:14.398643+0800 GCD_Demo[2383:848482] 任务3线程: <NSThread: 0x6000021dd200>{number = 5, name = (null)}
2019-10-07 22:14:14.398643+0800 GCD_Demo[2383:848474] 任务4线程: <NSThread: 0x6000021dcb00>{number = 4, name = (null)}
```

从执行任务的输出日志中可以看到：

```
1. 在执行完栅栏前面的操作之后，才执行栅栏操作，最后再执行栅栏后边的操作。
```



#### 6.2 延时方法：dispatch_after

在一些日常的开发任务中，会遇到这样的需求: 在指定时间(例如3秒)之后执行某个任务。 可以用 dispatch_after 函数来实现。需要注意的是：

```
dispatch_after 函数并不是在指定时间之后才开始执行处理，而是在指定时间之后将任务追加到主队列中。
严格来说，这个时间并不是绝对准确的，但想要大致延迟执行任务，dispatch_after函数是很有效的
```

```objective-c
- (void)afterTask {
    NSLog(@"当前线程：%@",[NSThread currentThread]);
    NSLog(@"afterTask : begin");
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 2.0秒后异步追加任务代码到主队列，并开始执行
        NSLog(@"延时任务: %@",[NSThread currentThread]);  // 打印当前线程
    });
    NSLog(@"afterTask: end");
}
```

日志输出：

```
2019-10-07 22:28:10.710553+0800 GCD_Demo[2452:925285] 当前线程：<NSThread: 0x600000535d00>{number = 1, name = main}
2019-10-07 22:28:10.710633+0800 GCD_Demo[2452:925285] afterTask : begin
2019-10-07 22:28:10.710706+0800 GCD_Demo[2452:925285] afterTask: end
2019-10-07 22:28:12.710895+0800 GCD_Demo[2452:925285] 延时任务: <NSThread: 0x600000535d00>{number = 1, name = main}
```

#### 6.3 一次性代码（只执行一次）：dispatch_once

在实现单例创建或者整个程序运行过程只执行一次的代码时，就可以使用到 dispatch_once 函数。

```
使用 dispatch_once 函数能保证某段代码在程序运行过程中只被执行一次，并且即使多线程的环境下，dispatch_once 也可以保证线程安全
```

```objective-c
- (void)onceTask {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //只执行一次的代码（默认线程安全的）
    });
}
```



#### 6.4 快速迭代方法：dispatch_apply 

通常情况下，回使用for循环遍历，但是GCD提供了快速迭代的方法 dispatch_apply

```
dispatch_apply按照指定的次数将指定的任务追加到指定的队列中，并等待全部队列执行结束。
```

还可以利用异步队列同时遍历，例如： 遍历0-5 这6个数字，for循环的做法是每次取出一个元素，逐个遍历。而dispatch_apply 可以同时遍历多个数字

```objective-c
- (void)applyTask {
    NSLog(@"applyTask: begin");
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//    dispatch_queue_t queue = dispatch_queue_create("com.tsbdj.gcd", DISPATCH_QUEUE_CONCURRENT);
    dispatch_apply(6, queue, ^(size_t index) {
       NSLog(@"applyTask -- %ld: %@",index,[NSThread currentThread]);  // 打印当前线程
    });
    NSLog(@"applyTask : end");
}
```

日志输出：

```
2019-10-07 22:50:57.135256+0800 GCD_Demo[2587:1046657] applyTask: begin
2019-10-07 22:50:57.135374+0800 GCD_Demo[2587:1046657] applyTask -- 0: <NSThread: 0x6000001ae1c0>{number = 1, name = main}
2019-10-07 22:50:57.135389+0800 GCD_Demo[2587:1046972] applyTask -- 1: <NSThread: 0x6000001d2280>{number = 7, name = (null)}
2019-10-07 22:50:57.135392+0800 GCD_Demo[2587:1046968] applyTask -- 2: <NSThread: 0x60000019e240>{number = 6, name = (null)}
2019-10-07 22:50:57.135409+0800 GCD_Demo[2587:1046969] applyTask -- 3: <NSThread: 0x60000019f480>{number = 4, name = (null)}
2019-10-07 22:50:57.135422+0800 GCD_Demo[2587:1046973] applyTask -- 4: <NSThread: 0x6000001f6ec0>{number = 3, name = (null)}
2019-10-07 22:50:57.135450+0800 GCD_Demo[2587:1046657] applyTask -- 5: <NSThread: 0x6000001ae1c0>{number = 1, name = main}
2019-10-07 22:50:57.135493+0800 GCD_Demo[2587:1046657] applyTask : end
```

```
1. 使用dispatch_apply遍历的过程中，日志输出打印的结果顺序不定，但 applyTask : end 是在最后才执行的
```

在并发队列中异步执行任务，所以各个任务的执行时间长短不定，所以结束的顺序也不定，但是 applyTask : end一定在最后才执行，这是因为 dispatch_apply 函数会等待全部任务执行完毕。



### 6.5 组队列：dispatch_group

在日常开发过程中，可能回遇到类似于这样的需求: 分别异步执行2个耗时任务，然后当2个耗时任务都执行完毕后再回到主线程执行任务。比如“多任务下载列表” ，对于这种情况的处理，我们可以使用 GCD的队列组。

```
1. 调用队列组的 dispatch_group_async 先把任务放到队列中，然后将队列放入队列组中。或者使用队列组的 dispatch_group_enter、dispatch_group_leave 组合 来实现
dispatch_group_async。

2. 调用队列组的 dispatch_group_notify 回到指定线程执行任务。或者使用 dispatch_group_wait 回到当前线程继续向下执行（会阻塞当前线程）。
```

#### 6.5.1 dispatch_group_notify

```
监听 group 中任务的完成状态，当所有的任务都执行完成后，追加任务到 group 中，并执行任务。
```

```objective-c
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
```

日志输出：

```
2019-10-07 23:19:47.117266+0800 GCD_Demo[2745:1210724] 当前线程 : <NSThread: 0x600001d341c0>{number = 1, name = main}
2019-10-07 23:19:47.117370+0800 GCD_Demo[2745:1210724] asyncGroupTask : begin
2019-10-07 23:19:49.121796+0800 GCD_Demo[2745:1211002] 任务1线程: <NSThread: 0x600001d4c480>{number = 5, name = (null)}
2019-10-07 23:19:51.121728+0800 GCD_Demo[2745:1210999] 任务1线程: <NSThread: 0x600001d77300>{number = 4, name = (null)}
2019-10-07 23:19:51.126080+0800 GCD_Demo[2745:1211002] 任务1线程: <NSThread: 0x600001d4c480>{number = 5, name = (null)}
2019-10-07 23:19:55.123324+0800 GCD_Demo[2745:1210999] 任务1线程: <NSThread: 0x600001d77300>{number = 4, name = (null)}
2019-10-07 23:19:57.124800+0800 GCD_Demo[2745:1210724] 主线程: <NSThread: 0x600001d341c0>{number = 1, name = main}
2019-10-07 23:19:59.126007+0800 GCD_Demo[2745:1210724] 主线程: <NSThread: 0x600001d341c0>{number = 1, name = main}
2019-10-07 23:19:59.126198+0800 GCD_Demo[2745:1210724] asyncGroupTask : end
```

从执行任务的输出日志中可以看到:

```
当所有任务都执行完成之后，才执行dispatch_group_notify block 中的任务。
```



#### 6.5.2 dispatch_group_wait

```
暂停当前线程（阻塞当前线程），等待指定的 group 中的任务执行完成后，才会往下继续执行。
```

```
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
```

日志输出：

```
2019-10-07 23:27:34.815860+0800 GCD_Demo[2777:1263623] 当前线程 : <NSThread: 0x6000027ca200>{number = 1, name = main}
2019-10-07 23:27:34.815986+0800 GCD_Demo[2777:1263623] asyncGroupTask : begin
2019-10-07 23:27:36.818749+0800 GCD_Demo[2777:1263812] 任务1线程: <NSThread: 0x6000027b4cc0>{number = 7, name = (null)}
2019-10-07 23:27:38.819683+0800 GCD_Demo[2777:1263807] 任务1线程: <NSThread: 0x6000027a0640>{number = 5, name = (null)}
2019-10-07 23:27:38.823676+0800 GCD_Demo[2777:1263812] 任务1线程: <NSThread: 0x6000027b4cc0>{number = 7, name = (null)}
2019-10-07 23:27:42.823771+0800 GCD_Demo[2777:1263807] 任务1线程: <NSThread: 0x6000027a0640>{number = 5, name = (null)}
2019-10-07 23:27:44.824352+0800 GCD_Demo[2777:1263623] 主线程: <NSThread: 0x6000027ca200>{number = 1, name = main}
2019-10-07 23:27:46.824912+0800 GCD_Demo[2777:1263623] 主线程: <NSThread: 0x6000027ca200>{number = 1, name = main}
2019-10-07 23:27:46.825289+0800 GCD_Demo[2777:1263623] asyncGroupTask : end
```

#### 6.5.3 dispatch_group_enter、dispatch_group_leave

```
1. dispatch_group_enter 标志着一个任务追加到 group，执行一次，相当于 group 中未执行完毕任务数+1

2. dispatch_group_leave 标志着一个任务离开了 group，执行一次，相当于 group 中未执行完毕任务数-1。

3. 当 group 中未执行完毕任务数为0的时候，才会使dispatch_group_wait解除阻塞，以及执行追加到dispatch_group_notify中的任务。
```

```objective-c
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
```

输出日志

```
2019-10-07 23:46:41.864816+0800 GCD_Demo[2872:1372394] 当前线程 : <NSThread: 0x600001c645c0>{number = 1, name = main}
2019-10-07 23:46:41.864903+0800 GCD_Demo[2872:1372394] asyncGroupEnterAndLeaveTask : begin
2019-10-07 23:46:43.867566+0800 GCD_Demo[2872:1372582] 任务2线程: <NSThread: 0x600001c7ff80>{number = 3, name = (null)}
2019-10-07 23:46:43.867564+0800 GCD_Demo[2872:1372581] 任务1线程: <NSThread: 0x600001c21200>{number = 4, name = (null)}
2019-10-07 23:46:45.869307+0800 GCD_Demo[2872:1372582] 任务2线程: <NSThread: 0x600001c7ff80>{number = 3, name = (null)}
2019-10-07 23:46:45.869307+0800 GCD_Demo[2872:1372581] 任务1线程: <NSThread: 0x600001c21200>{number = 4, name = (null)}
2019-10-07 23:46:47.870516+0800 GCD_Demo[2872:1372394] 主线程: <NSThread: 0x600001c645c0>{number = 1, name = main}
2019-10-07 23:46:49.871415+0800 GCD_Demo[2872:1372394] 主线程: <NSThread: 0x600001c645c0>{number = 1, name = main}
2019-10-07 23:46:49.871611+0800 GCD_Demo[2872:1372394] asyncGroupEnterAndLeaveTask : end
```

从执行任务的输出日志中可以看到:

```
当所有任务执行完成之后，才执行 dispatch_group_notify 中的任务。这里的dispatch_group_enter、dispatch_group_leave组合，其实等同于dispatch_group_async
```





### 6.6 信号量：dispatch_semaphore

GCD 中的信号量是指 **Dispatch Semaphore** ，是持有计数的信号。 类似于一个高速路收费站的栏杆。可以通过时，打开栏杆，不可以通过时，关闭栏杆。

在 **Dispatch Semaphore** 中，使用计数来完成这个功能，计数为0时等待，不可通过。计数为1或大于1时，计数减1且不等待，可通过。

**Dispatch Semaphore** 提供了三个函数:

```
1. dispatch_semaphore_create: 创建一个Semaphore并初始化信号的总量

2. dispatch_semaphore_signal: 发送一个信号，让信号总量加1

3. dispatch_semaphore_wait: 可以使总信号量减1，当信号总量为0时，就会一直等待（阻塞所在线程），否则就可以正常执行。
```

#### 注意

```
信号量的使用前提是：想清楚你需要处理哪个线程等待（阻塞），又要哪个线程继续执行，然后使用信号量。
```

#### Dispatch Semaphore 在实际开发中主要用于：

```
1. 保持线程同步，将异步执行任务转换为同步执行任务
2. 保证线程安全，为线程加锁
```

#### 6.6.1 Dispatch Semaphore 线程同步

在日常开发任务中，会有这样的需求: 异步执行耗时任务，并使用异步执行的结果进行一些额外的操作。 换句话说，相当于将异步执行任务转换为同步执行任务。

```
比如说：AFNetworking 中 AFURLSessionManager.m 里面的 tasksForKeyPath: 方法。 通过引入信号量的方式，等待异步执行任务结果，获取到 tasks，然后再返回该 tasks。
```

##### 下面，我们来利用 Dispatch Semaphore 实现线程同步，将异步执行任务转换为同步执行任务。

```objective-c
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
```

日志输出：

```
2019-10-08 00:09:56.970590+0800 GCD_Demo[3008:1524536] 当前线程 : <NSThread: 0x60000004dcc0>{number = 1, name = main}
2019-10-08 00:09:56.970682+0800 GCD_Demo[3008:1524536] asyncSemaphoreTask : begin
2019-10-08 00:09:58.971710+0800 GCD_Demo[3008:1524724] 任务1线程: <NSThread: 0x60000001a600>{number = 6, name = (null)}
2019-10-08 00:10:00.975037+0800 GCD_Demo[3008:1524724] 任务1线程: <NSThread: 0x60000001a600>{number = 6, name = (null)}
2019-10-08 00:10:00.975590+0800 GCD_Demo[3008:1524536] asyncSemaphoreTask: end,number = 100
```

可得：

```
1. semaphore---end 是在执行完 number = 100; 之后才打印的。而且输出结果 number 为 100。 这是因为异步执行不会做任何等待，可以继续执行任务。
    
2.异步执行将任务1追加到队列之后，不做等待，接着执行dispatch_semaphore_wait方法。此时 semaphore == 0，当前线程进入等待状态。
  然后，异步任务1开始执行。任务1执行到dispatch_semaphore_signal之后，总信号量，此时 semaphore == 1，dispatch_semaphore_wait方法使总信号量减1，
  正在被阻塞的线程（主线程）恢复继续执行。

3. 最后打印 asyncSemaphoreTask: end,number = 100。这样就实现了线程同步，将异步执行任务转换为同步执行任务。

```

#### 6.6.2 Dispatch Semaphore 线程安全和线程同步（为线程加锁）

#### 线程安全:

```
1. 如果你的代码所在的进程中有多个线程在同时运行，而这些线程可能会同时运行这段代码。如果每次运行结果和单线程运行的结果是一样的，而且其他的变量的值也和预期的是一样的，就是线程安全的。

2. 若每个线程中对全局变量、静态变量只有读操作，而无写操作，一般来说，这个全局变量是线程安全的；若有多个线程同时执行写操作（更改变量），一般都需要考虑线程同步，否则的话就可能影响线程安全。
```

#### 线程同步:

```
可理解为线程 A 和 线程 B 一块配合，A 执行到一定程度时要依靠线程 B 的某个结果，于是停下来，示意 B 运行；B 依言执行，再将结果给 A；A 再继续操作。

举个简单例子就是：两个人在一起聊天。两个人不能同时说话，避免听不清(操作冲突)。等一个人说完(一个线程结束操作)，另一个再说(另一个线程再开始操作)。
```

#### 6.6.2.1 非线程安全（不使用 semaphore）

```
/**
 * 非线程安全：不使用 semaphore
 * 初始化火车票数量、卖票窗口(非线程安全)、并开始卖票
 */
- (void)initTicketStatusNotSafeTask{
    NSLog(@"当前线程 : %@",[NSThread currentThread]);
    NSLog(@"initTicketStatusNotSafeTask : begin");
    
    self.ticketSurplusCount = 10;
    
    // queue1 代表北京火车票售卖窗口
    dispatch_queue_t queue1 = dispatch_queue_create("net.gcd.testQueue1", DISPATCH_QUEUE_SERIAL);
    // queue2 代表上海火车票售卖窗口
    dispatch_queue_t queue2 = dispatch_queue_create("net.gcd.testQueue2", DISPATCH_QUEUE_SERIAL);

    __weak typeof(self) ws = self;
    dispatch_async(queue1, ^{
        [ws saleTicketNotSafeTask];
    });
    
    dispatch_async(queue2, ^{
        [ws saleTicketNotSafeTask];
    });
}

/**
 * 售卖火车票(非线程安全)
 */
- (void)saleTicketNotSafeTask {
    while (1) {
        if (self.ticketSurplusCount > 0) { //如果还有票，继续售卖
            self.ticketSurplusCount--;
            NSLog(@"%@", [NSString stringWithFormat:@"剩余票数：%ld 窗口：%@", self.ticketSurplusCount, [NSThread currentThread]]);
            [NSThread sleepForTimeInterval:0.2];
        }else{ //如果已卖完，关闭售票窗口
            NSLog(@"所有火车票均已售完");
            break;
        }
    }
}

日志输出:

2019-08-19 11:53:16.220078+0800 XKHttpNetworkHelper[20418:614512] 当前线程 : <NSThread: 0x600002caa940>{number = 1, name = main}
2019-08-19 11:53:16.220223+0800 XKHttpNetworkHelper[20418:614512] initTicketStatusNotSafeTask : begin
2019-08-19 11:53:16.220462+0800 XKHttpNetworkHelper[20418:614556] 剩余票数：8 窗口：<NSThread: 0x600002cf50c0>{number = 4, name = (null)}
2019-08-19 11:53:16.220498+0800 XKHttpNetworkHelper[20418:614561] 剩余票数：9 窗口：<NSThread: 0x600002cc3d40>{number = 3, name = (null)}
2019-08-19 11:53:16.423119+0800 XKHttpNetworkHelper[20418:614556] 剩余票数：6 窗口：<NSThread: 0x600002cf50c0>{number = 4, name = (null)}
2019-08-19 11:53:16.423124+0800 XKHttpNetworkHelper[20418:614561] 剩余票数：7 窗口：<NSThread: 0x600002cc3d40>{number = 3, name = (null)}
2019-08-19 11:53:16.627985+0800 XKHttpNetworkHelper[20418:614561] 剩余票数：4 窗口：<NSThread: 0x600002cc3d40>{number = 3, name = (null)}
2019-08-19 11:53:16.627986+0800 XKHttpNetworkHelper[20418:614556] 剩余票数：5 窗口：<NSThread: 0x600002cf50c0>{number = 4, name = (null)}
2019-08-19 11:53:16.828705+0800 XKHttpNetworkHelper[20418:614556] 剩余票数：3 窗口：<NSThread: 0x600002cf50c0>{number = 4, name = (null)}
2019-08-19 11:53:16.828705+0800 XKHttpNetworkHelper[20418:614561] 剩余票数：2 窗口：<NSThread: 0x600002cc3d40>{number = 3, name = (null)}
2019-08-19 11:53:17.030931+0800 XKHttpNetworkHelper[20418:614556] 剩余票数：1 窗口：<NSThread: 0x600002cf50c0>{number = 4, name = (null)}
2019-08-19 11:53:17.030943+0800 XKHttpNetworkHelper[20418:614561] 剩余票数：1 窗口：<NSThread: 0x600002cc3d40>{number = 3, name = (null)}
2019-08-19 11:53:17.232633+0800 XKHttpNetworkHelper[20418:614556] 剩余票数：0 窗口：<NSThread: 0x600002cf50c0>{number = 4, name = (null)}
2019-08-19 11:53:17.232645+0800 XKHttpNetworkHelper[20418:614561] 剩余票数：0 窗口：<NSThread: 0x600002cc3d40>{number = 3, name = (null)}
2019-08-19 11:53:17.434801+0800 XKHttpNetworkHelper[20418:614556] 所有火车票均已售完
2019-08-19 11:53:17.434811+0800 XKHttpNetworkHelper[20418:614561] 所有火车票均已售完

```



#### 6.6.2.2  线程安全（使用 semaphore 加锁）

```
/**
 * 线程安全：使用 semaphore 加锁
 * 初始化火车票数量、卖票窗口(线程安全)、并开始卖票
 */
- (void)initTicketStatusSafeTask{
    NSLog(@"当前线程 : %@",[NSThread currentThread]);
    NSLog(@"initTicketStatusNotSafeTask : begin");
    
    self.semaphoreLock = dispatch_semaphore_create(1);
    
    self.ticketSurplusCount = 10;
    
    // queue1 代表北京火车票售卖窗口
    dispatch_queue_t queue1 = dispatch_queue_create("net.gcd.testQueue1", DISPATCH_QUEUE_SERIAL);
    // queue2 代表上海火车票售卖窗口
    dispatch_queue_t queue2 = dispatch_queue_create("net.gcd.testQueue2", DISPATCH_QUEUE_SERIAL);

    __weak typeof(self) ws = self;
    dispatch_async(queue1, ^{
        [ws saleTicketSafeTask];
    });
    
    dispatch_async(queue2, ^{
        [ws saleTicketSafeTask];
    });
}

/**
 * 售卖火车票(线程安全)
 */
- (void)saleTicketSafeTask {
    while (1) {
        // 相当于加锁
        dispatch_semaphore_wait(self.semaphoreLock, DISPATCH_TIME_FOREVER);
        
        if (self.ticketSurplusCount > 0) { //如果还有票，继续售卖
            self.ticketSurplusCount--;
            NSLog(@"%@", [NSString stringWithFormat:@"剩余票数：%ld 窗口：%@", self.ticketSurplusCount, [NSThread currentThread]]);
            [NSThread sleepForTimeInterval:0.2];
            
        }else{ //如果已卖完，关闭售票窗口
            NSLog(@"所有火车票均已售完");
            
            // 相当于解锁
            dispatch_semaphore_signal(self.semaphoreLock);
            break;
        }
        // 相当于解锁
        dispatch_semaphore_signal(self.semaphoreLock);
    }
}

日志输出:

2019-08-19 12:02:25.846200+0800 XKHttpNetworkHelper[20593:640200] 当前线程 : <NSThread: 0x600003ed2900>{number = 1, name = main}
2019-08-19 12:02:25.846374+0800 XKHttpNetworkHelper[20593:640200] initTicketStatusNotSafeTask : begin
2019-08-19 12:02:25.846739+0800 XKHttpNetworkHelper[20593:640300] 剩余票数：9 窗口：<NSThread: 0x600003e8c700>{number = 3, name = (null)}
2019-08-19 12:02:26.051095+0800 XKHttpNetworkHelper[20593:640302] 剩余票数：8 窗口：<NSThread: 0x600003ede500>{number = 4, name = (null)}
2019-08-19 12:02:26.256409+0800 XKHttpNetworkHelper[20593:640300] 剩余票数：7 窗口：<NSThread: 0x600003e8c700>{number = 3, name = (null)}
2019-08-19 12:02:26.459732+0800 XKHttpNetworkHelper[20593:640302] 剩余票数：6 窗口：<NSThread: 0x600003ede500>{number = 4, name = (null)}
2019-08-19 12:02:26.664534+0800 XKHttpNetworkHelper[20593:640300] 剩余票数：5 窗口：<NSThread: 0x600003e8c700>{number = 3, name = (null)}
2019-08-19 12:02:26.869298+0800 XKHttpNetworkHelper[20593:640302] 剩余票数：4 窗口：<NSThread: 0x600003ede500>{number = 4, name = (null)}
2019-08-19 12:02:27.073980+0800 XKHttpNetworkHelper[20593:640300] 剩余票数：3 窗口：<NSThread: 0x600003e8c700>{number = 3, name = (null)}
2019-08-19 12:02:27.278409+0800 XKHttpNetworkHelper[20593:640302] 剩余票数：2 窗口：<NSThread: 0x600003ede500>{number = 4, name = (null)}
2019-08-19 12:02:27.480733+0800 XKHttpNetworkHelper[20593:640300] 剩余票数：1 窗口：<NSThread: 0x600003e8c700>{number = 3, name = (null)}
2019-08-19 12:02:27.683954+0800 XKHttpNetworkHelper[20593:640302] 剩余票数：0 窗口：<NSThread: 0x600003ede500>{number = 4, name = (null)}
2019-08-19 12:02:27.887163+0800 XKHttpNetworkHelper[20593:640300] 所有火车票均已售完
2019-08-19 12:02:27.887329+0800 XKHttpNetworkHelper[20593:640302] 所有火车票均已售完

```





