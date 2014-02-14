//
//  EnsureMenuPassword.m
//  STB
//
//  Created by shulianyong on 13-10-22.
//  Copyright (c) 2013年 Shanghai Hanfir Enterprise Management Limited.. All rights reserved.
//

#import "EnsureMenuPassword.h"

@interface EnsureMenuPassword ()

@end

@implementation EnsureMenuPassword

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)click_back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)click_txtEnd:(UITextField*)sender {
    [sender resignFirstResponder];
    NSString *identifier = nil;
    
    //父母锁
    if (sender.tag==1) {
        identifier = @"ParentLock";
    }//Menu Password
    else if (sender.tag==2)
    {
        identifier = @"MenuPassword";
    }
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Video" bundle:nil];
    UIViewController *controller = [storyBoard instantiateViewControllerWithIdentifier:identifier];
    [self.navigationController pushViewController:controller animated:YES];

    
}

@end
