//
//  ChannelSearchController.m
//  STB
//
//  Created by shulianyong on 13-11-27.
//  Copyright (c) 2013年 Shanghai Hanfir Enterprise Management Limited.. All rights reserved.
//

#import "ChannelSearchController.h"
#import "TPInfo.h"
#import "CommonUtil.h"
#import "SearchChannelTool.h"

@interface ChannelSearchController ()
@property (strong, nonatomic) IBOutlet UITextField *txtFrequency;
@property (strong, nonatomic) IBOutlet UITextField *txtSymbolRate;
@property (strong, nonatomic) IBOutlet UITextField *txtPolar;
@property (strong, nonatomic) IBOutlet UIButton *btnRolarLeft;
@property (strong, nonatomic) IBOutlet UIButton *btnPolarRight;

@property (strong, nonatomic) IBOutlet UIButton *btnBack;

@property (strong, nonatomic) IBOutlet UIButton *btnSearch;

@end

@implementation ChannelSearchController

static NSString *FrequencyUserDefault = @"FrequencyUserDefault";
static NSString *SymbolRateUserDefault = @"SymbolRateUserDefault";
static NSString *PolarUserDefault=@"PolarUserDefault";

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
    
    NSString *frequencyValue = [[NSUserDefaults standardUserDefaults] objectForKey:FrequencyUserDefault];
    NSString *symbolRateValue = [[NSUserDefaults standardUserDefaults] objectForKey:SymbolRateUserDefault];
    NSString *polarValue = [[NSUserDefaults standardUserDefaults] objectForKey:PolarUserDefault];
    if (![NSString isEmpty:frequencyValue]) {
        self.txtFrequency.text = frequencyValue;
        self.txtSymbolRate.text = symbolRateValue;
        self.txtPolar.text = polarValue;
    }
    
    
	// Do any additional setup after loading the view.
    [self.btnBack setTitle:MyLocalizedString(@"Box Setup") forState:UIControlStateNormal];
    [self boundMultiLanWithView:self.view];
}

- (void)configDeafult
{
    [[NSUserDefaults standardUserDefaults] setObject:self.txtFrequency.text forKey:FrequencyUserDefault];
    [[NSUserDefaults standardUserDefaults] setObject:self.txtSymbolRate.text forKey:SymbolRateUserDefault];
    [[NSUserDefaults standardUserDefaults] setObject:self.txtPolar.text forKey:PolarUserDefault];
    [[NSUserDefaults standardUserDefaults] synchronize];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -------点击事件

//H与V的切换
- (IBAction)click_btnPolarLeft:(id)sender
{
   self.txtPolar.text = [self.txtPolar.text.trim isEqualToString:@"H"]?@"V":@"H";
}
- (IBAction)click_btnPolarRight:(id)sender
{
    self.txtPolar.text = [self.txtPolar.text.trim isEqualToString:@"H"]?@"V":@"H";
}
- (IBAction)txtChanged:(UITextField*)sender {
    if (sender.text.length>5) {
        sender.text = [sender.text.trim substringToIndex:5];
    }
}


- (IBAction)click_btnSearch:(id)sender
{
    if ([NSString isEmpty:self.txtFrequency.text.trim]) {
        [CommonUtil showMessage:MyLocalizedString(@"please input the Frequency")];
        return;
    }
    if ([NSString isEmpty:self.txtSymbolRate.text.trim]) {
        [CommonUtil showMessage:MyLocalizedString(@"please input the Symbol Rate")];
        return;
    }
    if ([NSString isEmpty:self.txtPolar.text.trim]) {
        [CommonUtil showMessage:MyLocalizedString(@"please input the Polar")];
        return;
    }
    [self configDeafult];
    
    TPInfo *aInfo = [[TPInfo alloc] init];
    
    NSInteger frequency = self.txtFrequency.text.integerValue;
    frequency = frequency;
    
    NSInteger symbolRate = self.txtSymbolRate.text.integerValue;
    symbolRate = symbolRate;
    
    NSInteger polar = [self.txtPolar.text.trim isEqualToString:@"H"]?0:1;
    
    aInfo.frequency = @(frequency);
    aInfo.symbolRate = @(symbolRate);
    aInfo.polarization = @(polar);
    
    SearchChannelTool *searchTool = [SearchChannelTool shareInstance];
    searchTool.defaultTPInfo = aInfo;
    [searchTool searchChannel];
//    aInfo.frequency
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.txtFrequency resignFirstResponder];
    [self.txtPolar resignFirstResponder];
    [self.txtSymbolRate resignFirstResponder];
}
- (IBAction)click_btnBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
