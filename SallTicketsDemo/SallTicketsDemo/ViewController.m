//
//  ViewController.m
//  SallTicketsDemo
//
//  Created by 刘宏立 on 16/9/22.
//  Copyright © 2016年 lhl. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property(nonatomic,assign)NSInteger tickets;

@end

@implementation ViewController {
    dispatch_queue_t _queue;
}

static id instance;
// initialize 会在类第一次被使用时调用
// initialize 方法的调用是安全的
+ (void)initialize {
//    NSLog(@"创建单例");
    instance = [[self alloc]init];
}
+ (instancetype)sharedTools {
    return instance;
}

//懒汉式单例实现
+ (instancetype)sharedTools2 {
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc]init];
    });
    return instance;
}





- (void)viewDidLoad {
    [super viewDidLoad];
//    [self setupQueue];
//    [self concurrentQueueAsync];
//    [self concurrentQueueSync];
//    [self gcdMainQueueAsync];
//    [self gcdMainQueueSync];
//    [self gcdMainQueueSync2];
//    [self gcdMainQueueSyncAsyncExcu];
//    [self syncExcu];
//    [self asyncLogin];
//    [self globleQueue];
//    [self gcdOnce];
//    [self delay];
//    [self gcdGroup];
    [self gcdGroup2];
    
}

- (void)setupQueue {
    _queue = dispatch_queue_create("cn.liuhongli2120.tickets", DISPATCH_QUEUE_SERIAL);
    _tickets = 20;
}

//- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        NSLog(@"卖票A %@", [NSThread currentThread]);
//        [self saleTickets];
//    });
//    
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        NSLog(@"卖票B %@", [NSThread currentThread]);
//        [self saleTickets];
//    });
//}

- (void)saleTickets {
    while (self.tickets > 0) {
        [NSThread sleepForTimeInterval:0.3];
        
        dispatch_sync(_queue, ^{
            if (self.tickets > 0) {
                self.tickets--;
                
                NSLog(@"剩余票数 %zd张, %@", self.tickets, [NSThread currentThread]);
            } else {
                NSLog(@"对不起,票已售完 %@", [NSThread currentThread]);
            }
        });
    }
}
/**
 睡0.3秒时打印输出 和 不睡眠时打印输出结果是不一样的
 */


/******并发队列********************************/
///并发队列异步执行
- (void)concurrentQueueAsync {
    NSLog(@"添加并发队列");
    dispatch_queue_t queue = dispatch_queue_create("cn.liuhongli.concurrent", DISPATCH_QUEUE_CONCURRENT);
    NSLog(@"异步执行的任务");
    for (NSInteger i = 0; i < 500; i ++) {
        dispatch_async(queue, ^{
            NSLog(@"%zd, %@", i, [NSThread currentThread]);
        });
    }
    NSLog(@"come here");
}

///并发队列同步执行
- (void)concurrentQueueSync {
    NSLog(@"添加并发队列");
    dispatch_queue_t queue = dispatch_queue_create("com.liuhongli.concurrent", DISPATCH_QUEUE_CONCURRENT);
    NSLog(@"添加同步执行任务");
    for (NSInteger i = 0; i < 5; i++) {
        dispatch_sync(queue, ^{
            [NSThread sleepForTimeInterval:0.3];
            NSLog(@"%zd, %@", i, [NSThread currentThread]);
        });
    }
    NSLog(@"come here");
}

/*****主队列***********************/
//主队列异步执行

- (void)gcdMainQueueAsync {
    //主队列
    dispatch_queue_t queue = dispatch_get_main_queue();
    for (NSInteger i = 0; i < 10; i++) {
//        [NSThread sleepForTimeInterval:0.3];
        //异步执行任务
        dispatch_async(queue, ^{
            NSLog(@"%zd, %@", i, [NSThread currentThread]);
        });
    }
    NSLog(@"come here");
}

//主队列同步执行
- (void)gcdMainQueueSync {
    dispatch_queue_t queue = dispatch_get_main_queue();
    for (NSInteger i = 0; i < 10; i++) {
        dispatch_sync(queue, ^{
            NSLog(@"%zd, %@", i, [NSThread currentThread]);
        });
    }
    NSLog(@"end");
}
//主队列同步执行也可以简写为
- (void)gcdMainQueueSync2 {
    dispatch_sync(dispatch_get_main_queue(), ^{
        NSLog(@"主队列和主线程相互等待造成死锁,此代码不会执行");
    });
}

//将"主队列同步执行"放到异步执行
- (void)gcdMainQueueSyncAsyncExcu {
    dispatch_queue_t queue = dispatch_queue_create("com.liuhongli.queue", DISPATCH_QUEUE_SERIAL);
    dispatch_async(queue, ^{
        for (NSInteger i = 0; i < 5; i++) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                NSLog(@"%zd, %@", i, [NSThread currentThread]);
            });
        }
        NSLog(@"come here");
    });
    NSLog(@"end");
}


//GCD同步任务的作用:同步任务，可以让其他异步执行的任务，依赖某一个同步任务
- (void)syncExcu {
    dispatch_queue_t queue = dispatch_queue_create("com.liuhongli.sync", DISPATCH_QUEUE_SERIAL);
    //同步登录
    dispatch_sync(queue, ^{
        [NSThread sleepForTimeInterval:1.0];
        NSLog(@"login %@", [NSThread currentThread]);
    });
    //异步下载
    dispatch_async(queue, ^{
        [NSThread sleepForTimeInterval:1.0];
        NSLog(@"download A %@", [NSThread currentThread]);
    });
    dispatch_async(queue, ^{
        NSLog(@"download B %@", [NSThread currentThread]);
    });
}



- (void)syncExcu2 {
    dispatch_queue_t queue = dispatch_queue_create("com.liuhongli.sync", DISPATCH_QUEUE_CONCURRENT);
    //同步登录
    dispatch_sync(queue, ^{
        [NSThread sleepForTimeInterval:1.0];
        NSLog(@"login %@", [NSThread currentThread]);
    });
    //异步下载
    dispatch_async(queue, ^{
        [NSThread sleepForTimeInterval:1.0];
        NSLog(@"download A %@", [NSThread currentThread]);
    });
    dispatch_async(queue, ^{
        NSLog(@"download B %@", [NSThread currentThread]);
    });
}


//让登录也在异步执行
- (void)asyncLogin {
    dispatch_queue_t queue = dispatch_queue_create("com.liuhongli.asynclogin", DISPATCH_QUEUE_CONCURRENT);
    dispatch_block_t task = ^{
        dispatch_sync(queue, ^{
            NSLog(@"login %@", [NSThread currentThread]);
        });
        
        dispatch_async(queue, ^{
            [NSThread sleepForTimeInterval:1.0];
            NSLog(@"download A %@", [NSThread currentThread]);
        });
        
        dispatch_async(queue, ^{
            NSLog(@"download B %@", [NSThread currentThread]);
        });
    };
    //将任务添加到队列
    dispatch_async(queue, task);
}

//全局队列,运行效果和并发队列一致
- (void)globleQueue {
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    for (NSInteger i = 0; i < 5; i++) {
        dispatch_async(queue, ^{
           NSLog(@"%zd, %@", i, [NSThread currentThread]);
        });
    }
    NSLog(@"end");
}

/********GCD高级技巧*********************************************/
- (void)gcdOnce {
    static dispatch_once_t onceToken;
    NSLog(@"onceToken == %zd", onceToken);
    dispatch_once(&onceToken, ^{
        NSLog(@"执行了");
    });
    NSLog(@"come here");
}

////测试多线程的一次性执行
//- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    for (NSInteger i = 0; i < 10; i++) {
//        dispatch_async(dispatch_get_global_queue(0, 0), ^{
//            [self gcdOnce];
//        });
//    }
//}


/**************** GCD延迟操作 *******************/

- (void)delay {
    NSLog(@"%s", __FUNCTION__);
    dispatch_time_t when = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC));
    dispatch_block_t task = ^{
        NSLog(@"==%@", [NSThread currentThread]);
    };
    dispatch_after(when, dispatch_get_main_queue(), task);
    dispatch_after(when, dispatch_get_global_queue(0, 0), task);
    dispatch_after(when, dispatch_queue_create("queue", NULL), task);
    NSLog(@"end");
    [self after];
}
- (void)after {
    [self.view performSelector:@selector(setBackgroundColor:) withObject:[UIColor orangeColor] afterDelay:1.0];
    NSLog(@"-----%@", [NSThread currentThread]);
}

/*****GCD调度组*******************/
- (void)gcdGroup {
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    dispatch_group_async(group, queue, ^{
        NSLog(@"下载图像 A %@", [NSThread currentThread]);
    });
    dispatch_group_async(group, queue, ^{
        NSLog(@"下载图像 B %@",[NSThread currentThread]);
    });
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSLog(@"完成 %@", [NSThread currentThread]);
    });
    NSLog(@"come here");
}

- (void)gcdGroup2 {
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    dispatch_group_enter(group);
    dispatch_async(queue, ^{
        [NSThread sleepForTimeInterval:3.0];
        NSLog(@"download A %@",[NSThread currentThread]);
        dispatch_group_leave(group);
    });
    
    dispatch_group_enter(group);
    dispatch_async(queue, ^{
        NSLog(@"download B %@", [NSThread currentThread]);
        dispatch_group_leave(group);
    });
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSLog(@"完成 %@", [NSThread currentThread]);
    });
    NSLog(@"come here");
}




@end
