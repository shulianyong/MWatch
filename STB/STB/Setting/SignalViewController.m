//
//  SignalViewController.m
//  STB
//
//  Created by shulianyong on 13-10-26.
//  Copyright (c) 2013年 Chengdu Sifang Information Technology Co.LTD. All rights reserved.
//

#import "SignalViewController.h"
#import "CommandClient.h"
#import "SignalInfo.h"

@interface SignalViewController ()

@property (strong, nonatomic) IBOutlet UIView *viewProcess;
@property (strong, nonatomic) IBOutlet UILabel *lblProcessValue;

@property (nonatomic) CGFloat processValue;
@property (nonatomic,strong) NSTimer *processTimer;

//信号强度

@property (strong, nonatomic) IBOutlet UIView *viewStrengthProcess;
@property (strong, nonatomic) IBOutlet UILabel *lblStrengthValue;
@property (nonatomic) CGFloat strengthProcessValue;


@end

@implementation SignalViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)setProcessValue:(CGFloat)processValue
{
    _processValue = processValue;
    
    UIView *processSupper = self.viewProcess.superview;
    CGFloat width = processSupper.bounds.size.width;
    if (processValue<=100) {
        CGFloat widthValue = processValue/100.f*width;
        CGRect processBound = self.viewProcess.bounds;
        processBound.size.width = widthValue;
        self.viewProcess.frame = processBound;
        self.lblProcessValue.text = [NSString stringWithFormat:@"%.0f％",processValue];
    }
    
}

- (void)setStrengthProcessValue:(CGFloat)processValue
{
    _strengthProcessValue = processValue;
    
    UIView *processSupper = self.viewStrengthProcess.superview;
    CGFloat width = processSupper.bounds.size.width;
    if (processValue<=100) {
        CGFloat widthValue = processValue/100.f*width;
        CGRect processBound = self.viewStrengthProcess.bounds;
        processBound.size.width = widthValue;
        self.viewStrengthProcess.frame = processBound;
        self.lblStrengthValue.text = [NSString stringWithFormat:@"%.0f％",processValue];
    }
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.processTimer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(signalShow:) userInfo:nil repeats:YES];
    
    [self boundMultiLanWithView:self.view];
//    self.processTimer = [NSTimer timerWithTimeInterval:3 target:self selector:@selector(signalShow:) userInfo:nil repeats:YES];
//    [self.processTimer fire];
	// Do any additional setup after loading the view.
}


- (void)boundMultiLanWithView:(UIView*)supView
{
    for (UIView *sub in supView.subviews) {
        if (![sub isKindOfClass:[UIButton class]] && sub.subviews.count>0) {
            [self boundMultiLanWithView:sub];
        }
        else
        {
            if ([sub isKindOfClass:[UILabel class]]) {
                UILabel *lblKey = (UILabel*)sub;
                lblKey.text = MyLocalizedString(lblKey.text);
            }
            else if([sub isKindOfClass:[UIButton class]])
            {
                UIButton *btnKey = (UIButton*)sub;
                [btnKey setTitle:MyLocalizedString(btnKey.titleLabel.text) forState:UIControlStateNormal];
            }
        }
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self setProcessValue:0];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if (self.processTimer) {        
        [self.processTimer invalidate];
        self.processTimer = nil;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)click_back:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)signalShow:(id)sender
{
    __weak SignalViewController *weakSelf = self;
    [CommandClient commandGetSignal:^(id info, HTTPAccessState isSuccess) {
        if (isSuccess == HTTPAccessStateSuccess) {
            SignalInfo *aSignal = info;
            if (aSignal.noiseRatio.floatValue>0) {
                [weakSelf setProcessValue:aSignal.noiseRatio.floatValue];
            }
            if (aSignal.strength.floatValue>0) {                
                [weakSelf setStrengthProcessValue:aSignal.strength.floatValue];
            }
        }
    }];
}

- (void)dealloc
{
    if (self.processTimer) {
        [self.processTimer invalidate];
        self.processTimer = nil;
    }
}

@end
