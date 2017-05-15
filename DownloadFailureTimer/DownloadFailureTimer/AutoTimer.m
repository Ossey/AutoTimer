//
//  AutoTimer.m
//  DownloadFailureTimer
//
//  Created by Ossey on 2017/5/15.
//  Copyright © 2017年 Ossey. All rights reserved.
//

#import "AutoTimer.h"
#import <objc/runtime.h>


@implementation AutoTimer {
    
    NSMutableDictionary *_timerDictionary;
    NSMutableDictionary *_actionBlockDictionary;
}


+ (AutoTimer *)sharedInstance {
    
    static AutoTimer *_timer = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _timer = [AutoTimer new];
        _timer->_timerDictionary = [NSMutableDictionary dictionaryWithCapacity:0];
        _timer->_actionBlockDictionary = [NSMutableDictionary dictionaryWithCapacity:0];
    });
    
    return _timer;
}


+ (void)startTimerWithIdentifier:(NSString *)timerIdentifier
                    timeInterval:(NSTimeInterval)interval
                           queue:(dispatch_queue_t)queue
                         repeats:(BOOL)repeats
                    actionOption:(AutoTimerActionOption)option
                           block:(void (^)())block {
    
    if (nil == timerIdentifier) {
        return;
    }
    
    if (queue == nil) {
        queue = dispatch_queue_create("com.ossey.AutoTimer.queue", DISPATCH_QUEUE_CONCURRENT);
        
    }
    
    dispatch_source_t timer = [[AutoTimer sharedInstance]->_timerDictionary objectForKey:timerIdentifier];
    if (!timer) {
        timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
        dispatch_resume(timer);
        [[AutoTimer sharedInstance]->_timerDictionary setObject:timer forKey:timerIdentifier];
    }
    
    dispatch_source_set_timer(timer, dispatch_time(DISPATCH_TIME_NOW, interval * NSEC_PER_SEC), interval * NSEC_PER_SEC, 0.1 * NSEC_PER_SEC);
    
    __weak typeof(self) weakSelf = self;
    
    if (option == AutoTimerActionOptionGiveUp) {
        
        // 移除之前的定时器执行的事件
        [[AutoTimer sharedInstance]->_actionBlockDictionary removeObjectForKey:timerIdentifier];
        
        dispatch_source_set_event_handler(timer, ^{
            if (block) {
                block();
            }
            
            if (!repeats) {
                [weakSelf cancel:timerIdentifier];
            }
        });
    } else if (option == AutoTimerActionOptionMerge) {
        
        // 保存定时器执行的事件
        [[AutoTimer sharedInstance] saveActionBlock:block forTimerIdentifier:timerIdentifier];
        
        dispatch_source_set_event_handler(timer, ^{
            NSMutableArray *actionArray = [[AutoTimer sharedInstance]->_actionBlockDictionary objectForKey:timerIdentifier];
            [actionArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                void (^block)() = obj;
                if (block) {
                    block();
                }
            }];
            
            [[AutoTimer sharedInstance]->_actionBlockDictionary removeObjectForKey:timerIdentifier];
            
            if (!repeats) {
                [weakSelf cancel:timerIdentifier];
            }
        });
    }
    
}

+ (void)cancel:(NSString *)timerKey {
    
    if (nil == timerKey) {
        return;
    }
    
    dispatch_source_t timer = [[AutoTimer sharedInstance]->_timerDictionary objectForKey:timerKey];
    
    if (!timer) {
        return;
    }
    
    [[AutoTimer sharedInstance]->_timerDictionary removeObjectForKey:timerKey];
    dispatch_source_cancel(timer);
    timer = nil;
    
    [[AutoTimer sharedInstance]->_actionBlockDictionary removeObjectForKey:timerKey];
}

+ (BOOL)existTimer:(NSString *)timerKey {
    return [[AutoTimer sharedInstance]->_timerDictionary objectForKey:timerKey];
}

- (void)saveActionBlock:(void (^)())block forTimerIdentifier:(NSString *)timerIdentifier {
    if (nil == timerIdentifier) {
        return;
    }
    
    id actionArray = [_actionBlockDictionary objectForKey:timerIdentifier];
    
    if (actionArray && [actionArray isKindOfClass:[NSMutableArray class]]) {
        [(NSMutableArray *)actionArray addObject:block];
    }else {
        NSMutableArray *array = [NSMutableArray arrayWithObject:block];
        [_actionBlockDictionary setObject:array forKey:timerIdentifier];
    }
}


@end
