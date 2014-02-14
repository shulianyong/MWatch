//
//  CustomSegue.m
//  STB
//
//  Created by shulianyong on 13-9-28.
//  Copyright (c) 2013年 Shanghai Hanfir Enterprise Management Limited.. All rights reserved.
//

#import "CustomSegue.h"
#import "UIViewController+JASidePanel.h"
#import "JASidePanelController.h"

@interface AlertViewDelegate : NSObject

@property (nonatomic,strong) UIViewController *current;
@property (nonatomic,strong) UIViewController *next;
+ (AlertViewDelegate*)shareInstance;

@end

@implementation AlertViewDelegate

+ (AlertViewDelegate*)shareInstance
{
    static AlertViewDelegate *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[AlertViewDelegate alloc] init];
    });
    
    return instance;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==alertView.firstOtherButtonIndex) {
        UIViewController *current = self.current;
        UIViewController *next = self.next;
        [current.navigationController pushViewController:next animated:YES];
    }
}


@end

@implementation CustomSegue

- (id)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination
{
    self = [super initWithIdentifier:identifier source:source destination:destination];
    if (self) {
        [AlertViewDelegate shareInstance].current = self.sourceViewController;
        [AlertViewDelegate shareInstance].next = self.destinationViewController;
    }
    return self;
}

- (void)perform
{
    UIViewController *currentViewController = self.sourceViewController;
    UIViewController *nextViewController = self.destinationViewController;
    
    [currentViewController.sidePanelController setRightPanel:nextViewController];   
}


@end
