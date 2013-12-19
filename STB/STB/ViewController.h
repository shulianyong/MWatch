//
//  ViewController.h
//  STB
//
//  Created by shulianyong on 13-9-28.
//  Copyright (c) 2013年 Chengdu Sifang Information Technology Co.LTD. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "KxMovieViewController.h"

@interface ViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIToolbar *tbarBottom;
- (IBAction)click_Play:(id)sender;
- (IBAction)click_Volume:(id)sender;
- (IBAction)click_next:(id)sender;

@end
