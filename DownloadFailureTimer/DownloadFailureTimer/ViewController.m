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
    
    
    __weak typeof(self) weakSelf = self;
    
    [AutoTimer startTimerWithIdentifier:timerKey timeInterval:10.0 queue:nil repeats:YES actionOption:AutoTimerActionOptionGiveUp block:^{
        [weakSelf doSomethingEveryTwoSeconds];
    }];
}


/* timer每次执行打印一条log记录，在执行到n==10的时候cancel掉timer */
- (void)doSomethingEveryTwoSeconds
{
    static NSUInteger n = 0;
    NSLog(@"myTimer runs %lu times!", (unsigned long)n++);
    
    if (n >= 10) {
        [AutoTimer cancel:timerKey];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
