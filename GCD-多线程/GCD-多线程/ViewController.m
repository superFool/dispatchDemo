//
//  ViewController.m
//  GCD-多线程
//
//  Created by 宋超帅 on 2021/8/17.
//

#import "ViewController.h"

@interface ViewController ()

/** <#xxxx#>*/
@property (nonatomic,assign)int index;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self serialRequestDemo];
}

/**
    并发队列同步执行
 */
- (void)concurrentSync{
    
    dispatch_queue_t myConcurrentQueue = dispatch_queue_create("2", DISPATCH_QUEUE_CONCURRENT);
    dispatch_sync(myConcurrentQueue, ^{
        NSLog(@"1");
        NSLog(@"%@",[NSThread currentThread]);
        NSLog(@"2");
        dispatch_sync(myConcurrentQueue, ^{
            NSLog(@"%@",[NSThread currentThread]);
            NSLog(@"3");
        });
        NSLog(@"4");
    });
    NSLog(@"done!!!");
}

//dispatch_set_target_queue 示例
- (void)dispatch_set_target_queue{
    dispatch_queue_t baseSerialQueue = dispatch_queue_create("base", NULL);
    
    dispatch_queue_t mySerialQueue1 = dispatch_queue_create("1", NULL);
    dispatch_queue_t mySerialQueue2 = dispatch_queue_create("2", NULL);
    
    dispatch_set_target_queue(mySerialQueue1, baseSerialQueue);
    dispatch_set_target_queue(mySerialQueue2, baseSerialQueue);
    for (int i = 0; i < 10; i++) {
        dispatch_async(mySerialQueue1, ^{
            NSLog(@"1: %@-%d",[NSThread currentThread],i);
            sleep(1);
            
        });
        dispatch_async(mySerialQueue2, ^{
            NSLog(@"2: %@-%d",[NSThread currentThread],i);
            sleep(1);
        });
        
    }
    
    dispatch_queue_t mySerialDispatchQueue = dispatch_queue_create("com.lxc.GCD.serialQueue", NULL);
    dispatch_queue_t globalDispatchQueueBackground = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    dispatch_set_target_queue(mySerialDispatchQueue, globalDispatchQueueBackground);
}

//dispatch_after 示例
- (void)dispatchAfterTest{
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC);
    dispatch_after(time, dispatch_get_main_queue(), ^{
        NSLog(@"waited at least three seconds.");
    });
}
/** 调度组 示例*/
- (void)dispatchGroupTest1{
    dispatch_queue_t queue1 = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_queue_t queue2 = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t group = dispatch_group_create();
    
    dispatch_group_async(group, queue1, ^{
        NSLog(@"1");
    });
    dispatch_group_async(group, queue1, ^{
        NSLog(@"2");
    });
    dispatch_group_async(group, queue1, ^{
        NSLog(@"3");
    });
    dispatch_group_async(group, queue2, ^{
        NSLog(@"4");
    });
    dispatch_group_async(group, queue2, ^{
        NSLog(@"5");
    });
    dispatch_group_async(group, queue2, ^{
        sleep(1);
        NSLog(@"6");
    });
    
    dispatch_group_notify(group, queue1, ^{
        NSLog(@"done!");
    });
}

/** 调度组 示例*/
- (void)dispatchGroupTest2{
    dispatch_queue_t queue1 = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_queue_t queue2 = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t group = dispatch_group_create();
    
    
    dispatch_group_enter(group);
    dispatch_async(queue1, ^{
        NSLog(@"1");
        dispatch_group_leave(group);
    });
    dispatch_group_enter(group);
    dispatch_async(queue1, ^{
        NSLog(@"2");
        dispatch_group_leave(group);
    });
    dispatch_group_enter(group);
    dispatch_async(queue1, ^{
        NSLog(@"3");
        dispatch_group_leave(group);
    });
    dispatch_group_enter(group);
    dispatch_async(queue2, ^{
        NSLog(@"4");
        dispatch_group_leave(group);
    });
    dispatch_group_enter(group);
    dispatch_async(queue2, ^{
        NSLog(@"5");
        dispatch_group_leave(group);
    });
    dispatch_group_enter(group);
    dispatch_async(queue2, ^{
        
        sleep(1);
        NSLog(@"6");
        dispatch_group_leave(group);
    });
    
    
    dispatch_group_notify(group, queue1, ^{
        NSLog(@"done!");
    });
}


/** 调度组 示例*/
- (void)dispatchGroupTest3{
    dispatch_queue_t queue1 = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t group = dispatch_group_create();
    
    dispatch_group_async(group, queue1, ^{
        NSLog(@"1");
    });
    dispatch_group_async(group, queue1, ^{
        NSLog(@"2");
    });
    dispatch_group_async(group, queue1, ^{
        sleep(1);
        NSLog(@"3");
    });
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    NSLog(@"done!");
}

/** dispatch_barrier_async 示例*/
- (void)dispatchBarrierTest{
    dispatch_queue_t queue = dispatch_queue_create("com.test.dispatchBarrier", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        NSLog(@"reading1");
    });
    dispatch_async(queue, ^{
        sleep(1);
        NSLog(@"reading2");
    });
    dispatch_async(queue, ^{
        NSLog(@"reading3");
    });
    dispatch_barrier_async(queue, ^{
        NSLog(@"writing");
    });
    dispatch_async(queue, ^{
        NSLog(@"reading4");
    });
    dispatch_async(queue, ^{
        NSLog(@"reading5");
    });
    dispatch_async(queue, ^{
        NSLog(@"reading6");
    });

}
/**
 信号量 示例
 */
- (void)dispatchSemaphoreTest{
    dispatch_queue_t queue = dispatch_queue_create("com.test.semaphore", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
    
    NSMutableArray *mArr = [NSMutableArray array];
    
    for (int i = 0; i < 10000; i++) {
        dispatch_async(queue, ^{
            
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            [mArr addObject:@(i)];
            NSLog(@"%d",i);
            dispatch_semaphore_signal(semaphore);
        });
    }
}

#pragma mark - 具体案例分析
#pragma mark - 图片上传案例
/**
 案例一：需要并发上传3张图片到服务器，等3张图片全部上传成功后请求接口把三个图片名传给服务器做提交操作
 */
- (void)uploadImageDemo{
    
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_queue_create("1", DISPATCH_QUEUE_CONCURRENT);
    
    NSMutableArray *mArr = [NSMutableArray array];
    for (int i = 0; i < 3; i++) {
        NSLog(@"for%d",i);
        dispatch_group_enter(group);
        [self uploadImage:^(NSString *imageName) {
            
            dispatch_barrier_async(queue, ^{
                [mArr addObject:imageName];
            });
            
            NSLog(@"blk%d",i);
            dispatch_group_leave(group);
        } index:i];
        
    }
    
    
    
    dispatch_group_notify(group, queue, ^{
        NSLog(@"notify");
        [self requestCommitAPI:mArr];
    });
    
    
}




- (void)uploadImage:(void(^)(NSString *imageName))block index:(int)index{
    /** 延时操作模拟图片上传*/
    __weak typeof(self) weakSelf = self;
    dispatch_queue_t queue = dispatch_queue_create("com.test.uploadImage", DISPATCH_QUEUE_CONCURRENT);
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC);
    dispatch_after(time, queue, ^{
        weakSelf.index++;
        block(@(index).stringValue);
        
    });
    
}

- (void)requestCommitAPI:(NSArray *)imageNames{
    NSLog(@"imageNames:%@",imageNames);
}


#pragma mark - 串行接口请求案例
/**
 描述：请求第二个接口需要第一个接口返回结果，第三个接口入参需要第二个接口返回的结果，以此类推
 */


- (void)serialRequestDemo{
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
    dispatch_queue_t queue = dispatch_queue_create("com.test.serialQueue", DISPATCH_QUEUE_CONCURRENT);
    
    
    __block int total = 0;
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    [self requestAPI1:^(int result) {
        total = result;
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    [self requestAPI2:^(int result) {
        total = result;
        dispatch_semaphore_signal(semaphore);
    } params:total];
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    [self requestAPI3:^(int result) {
        total = result;
        dispatch_semaphore_signal(semaphore);
    } params:total];
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    [self requestAPI4:^(int result) {
        total = result;
        dispatch_semaphore_signal(semaphore);
    } params:total];
    
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    [self requestAPI5:^(int result) {
        total = result;
        dispatch_semaphore_signal(semaphore);
    } params:total];
    
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    NSLog(@"result = %d",total);
    dispatch_semaphore_signal(semaphore);
    
}



- (void)requestAPI1:(void(^)(int result))block{
    NSLog(@"%s",__func__);
    dispatch_queue_t queue = dispatch_queue_create("1", DISPATCH_QUEUE_CONCURRENT);
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC);
    dispatch_after(time, queue, ^{
        NSLog(@"%s block done",__func__);
        block(1);
    });
}
- (void)requestAPI2:(void(^)(int result))block params:(int)p{
    NSLog(@"%s",__func__);
    dispatch_queue_t queue = dispatch_queue_create("2", DISPATCH_QUEUE_CONCURRENT);
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC);
    dispatch_after(time, queue, ^{
        NSLog(@"%s block done",__func__);
        block(p + 2);
    });
}
- (void)requestAPI3:(void(^)(int result))block params:(int)p{
    NSLog(@"%s",__func__);
    dispatch_queue_t queue = dispatch_queue_create("3", DISPATCH_QUEUE_CONCURRENT);
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC);
    dispatch_after(time, queue, ^{
        NSLog(@"%s block done",__func__);
        block(p + 3);
    });
}
- (void)requestAPI4:(void(^)(int result))block params:(int)p{
    NSLog(@"%s",__func__);
    dispatch_queue_t queue = dispatch_queue_create("4", DISPATCH_QUEUE_CONCURRENT);
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC);
    dispatch_after(time, queue, ^{
        NSLog(@"%s block done",__func__);
        block(p + 4);
        
    });
}
- (void)requestAPI5:(void(^)(int result))block params:(int)p{
    NSLog(@"%s",__func__);
    dispatch_queue_t queue = dispatch_queue_create("5", DISPATCH_QUEUE_CONCURRENT);
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC);
    dispatch_after(time, queue, ^{
        NSLog(@"%s block done",__func__);
        block(p + 5);
        
    });
}



@end
