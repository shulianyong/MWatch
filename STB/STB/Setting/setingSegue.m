//
//  setingSegue.m
//  STB
//
//  Created by shulianyong on 13-10-11.
//  Copyright (c) 2013年 Shanghai Hanfir Enterprise Management Limited.. All rights reserved.
//

#import "setingSegue.h"

@implementation setingSegue

- (void)perform
{
    UIViewController *currentViewController = self.sourceViewController;
    UIViewController *nextViewController = self.destinationViewController;
    
    [currentViewController.navigationController.view addSubview:nextViewController.view];
    currentViewController.view.userInteractionEnabled = NO;
    nextViewController.view.frame = CGRectMake(-200, 0, 200, currentViewController.navigationController.view.bounds.size.height);
    
    [UIView beginAnimations:@"channel" context:Nil];
    nextViewController.view.frame = CGRectMake(0, 0, 200, currentViewController.navigationController.view.bounds.size.height);
    [UIView commitAnimations];   
    
}

@end
