//
//  ViewController.m
//  DownloadFailureTimer
//
//  Created by Ossey on 2017/5/15.
//  Copyright © 2017年 Ossey. All rights reserved.
//

#import "ViewController.h"
#import "AutoTimer.h"

static NSString *timerKey = @"timer";

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    

    
    [AutoTimer startTimerWithIdentifier:timerKey fireTime:10.0 timeInterval:10.0 queue:nil repeats:YES actionOption:AutoTimerActionOptionGiveUp block:^{
        // timer每次执行打印一条n的值，在执行到n==10的时候cancel掉timer
        // 即使执行timer期间，再次触发touchesBegan方法，log的打印也不会受影响
        static NSUInteger n = 0;
        NSLog(@"n: %lu", n++);
        
        if (n >= 10) {
            [AutoTimer cancel:timerKey];
        }

    }];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
