//
//  ViewController.m
//  MNProgress
//
//  Created by apoptoxin on 17/7/15.
//  Copyright © 2017年 micronil. All rights reserved.
//

#import "ViewController.h"
#import "MNCircleProgressView.h"

@interface ViewController ()
@property (nonatomic, strong) NSProgress *progress;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.progress = [NSProgress progressWithTotalUnitCount:10];
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(task) userInfo:nil repeats:YES];
    
    
    MNCircleProgressView *subView = [[MNCircleProgressView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    subView.center = self.view.center;
    [self.view addSubview:subView];
    subView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
    subView.layer.cornerRadius = 10.0f;
    subView.layer.masksToBounds = YES;
    [self testProcessWithView:subView];
    
//    [subView startAnimationWithCountDown:3.0 completion:^(BOOL finish) {
//        
//    }];
}

- (void)testProcessWithView:(MNCircleProgressView*)subView {
    self.progress.completedUnitCount = 0;
    [subView startAnimationWithProgress:self.progress completion:^(BOOL finish) {
        [self testProcessWithView:subView];
    }];
}
-(void)task{
    //完成任务单元数+1
    
    if (self.progress.completedUnitCount < self.progress.totalUnitCount) {
        self.progress.completedUnitCount +=1;
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
