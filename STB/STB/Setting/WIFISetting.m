//
//  WIFISetting.m
//  STB
//
//  Created by shulianyong on 13-10-22.
//  Copyright (c) 2013年 Chengdu Sifang Information Technology Co.LTD. All rights reserved.
//

#import "WIFISetting.h"
#import "CommandClient.h"
#import "WifiInfo.h"
#import "CommonUtil.h"

@interface WIFISetting ()
@property (strong, nonatomic) IBOutlet UITextField *txtWifiName;
@property (strong, nonatomic) IBOutlet UITextField *txtPassword;
@property (strong, nonatomic) IBOutlet UITextField *txtVerifyPwd;
@property (strong, nonatomic) IBOutlet UIScrollView *sclContent;
    
@property (strong, nonatomic) IBOutlet UILabel *lblName;
@property (strong, nonatomic) IBOutlet UILabel *lblEncode;
@property (strong, nonatomic) IBOutlet UIButton *btnOK;
@property (strong, nonatomic) IBOutlet UISwitch *switchNeedPwd;

@property (strong,nonatomic) WifiInfo *currentWifiInfo;

@end

@implementation WIFISetting

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
    self.txtPassword.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 5)];
    self.txtPassword.leftViewMode = UITextFieldViewModeAlways;
    self.txtWifiName.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 5)];
    self.txtWifiName.leftViewMode = UITextFieldViewModeAlways;
    self.txtVerifyPwd.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 5)];
    self.txtVerifyPwd.leftViewMode = UITextFieldViewModeAlways;
    
    [self boundMultiLanWithView:self.view];
    WIFISetting *weakSelf = self;
    [CommandClient commandGetWifiInfo:^(id info, HTTPAccessState isSuccess) {
        if (isSuccess==HTTPAccessStateSuccess) {
            WifiInfo *wInfo = info;
            weakSelf.currentWifiInfo = info;
            weakSelf.txtWifiName.text = wInfo.wifi_ap_name;
            weakSelf.switchNeedPwd.on = wInfo.free_status.boolValue;
        }
    }];
//    [self.btnOK setTitle:MyLocalizedString(@"OK") forState:UIControlStateNormal];
    self.txtPassword.placeholder = MyLocalizedString(@"Please input the new password");
    self.txtWifiName.placeholder = MyLocalizedString(@"WIFI Name");
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
    
#pragma mark keyboard
- (void)showKeyboard
    {
        UITextField *txtSelected = nil;
        if (self.txtVerifyPwd.isFirstResponder) {
            txtSelected = self.txtVerifyPwd;
        }
        else
        {
            return;
        }
        CGFloat keyboardHeight = 162;
        NSNumber *time = @0.25;
        
        CGFloat offset = txtSelected.frame.origin.y+txtSelected.bounds.size.height+20+keyboardHeight-self.view.bounds.size.height;
        if (offset>0) {
            [UIView setAnimationDuration:[time doubleValue]];
            [UIView beginAnimations:@"keyboardWillShow" context:nil];
            self.sclContent.contentOffset = CGPointMake(0, offset);
            [UIView commitAnimations];
        }
    }
    
- (void)keyboardWillShow:(NSNotification*)obj
    {
        UITextField *txtSelected = nil;
        if (self.txtVerifyPwd.isFirstResponder) {
            txtSelected = self.txtVerifyPwd;
        }
        else
        {
            return;
        }
        
        NSDictionary *keyUserinfo = [obj userInfo];
        NSNumber *time = [keyUserinfo valueForKey:UIKeyboardAnimationDurationUserInfoKey];
        CGRect keyboardBound = [[keyUserinfo valueForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
        
        
        CGFloat offset = txtSelected.frame.origin.y+txtSelected.bounds.size.height+20+keyboardBound.size.width-self.view.bounds.size.height;
        if (offset>0) {
            [UIView setAnimationDuration:[time doubleValue]];
            [UIView beginAnimations:@"keyboardWillShow" context:nil];
            self.sclContent.contentOffset = CGPointMake(0, offset);
            [UIView commitAnimations];
        }
    }
    
    
- (void)keyboardWillHide:(NSNotification*)obj
    {
        NSDictionary *keyUserinfo = [obj userInfo];
        NSNumber *time = [keyUserinfo valueForKey:UIKeyboardAnimationDurationUserInfoKey];
        [UIView setAnimationDuration:[time doubleValue]];
        [UIView beginAnimations:@"keyboardWillShow" context:nil];
        self.sclContent.contentOffset = CGPointMake(0, 0);
        [UIView commitAnimations];
    }

- (IBAction)touchView:(id)sender
{
    if ([self.txtPassword isFirstResponder]) {
        [self.txtPassword resignFirstResponder];
    }
    if (self.txtVerifyPwd.isFirstResponder) {
        [self.txtVerifyPwd resignFirstResponder];
    }
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([self.txtPassword isFirstResponder]) {
        [self.txtPassword resignFirstResponder];
    }
    if (self.txtVerifyPwd.isFirstResponder) {
        [self.txtVerifyPwd resignFirstResponder];
    }
}
    
#pragma mark event

- (IBAction)click_back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)click_txtEnd:(UITextField*)sender {
    if (sender.returnKeyType==UIReturnKeyNext)
    {
        [self.txtVerifyPwd becomeFirstResponder];
        [self showKeyboard];
    }
    else
    {
        [sender resignFirstResponder];
    }
}
- (IBAction)click_btnOK:(id)sender {
    if ([NSString isEmpty:self.txtWifiName.text.trim]) {
        [CommonUtil showMessage:MyLocalizedString(@"Please Input WIFI Name")];
        return;
    }
    if ((self.txtPassword.text.trim.length>7 &&[self.txtPassword.text.trim isEqualToString:self.txtVerifyPwd.text.trim]) || self.switchNeedPwd.on==NO) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:MyLocalizedString(@"Alert")
                                                            message:MyLocalizedString(@"Are you really want to modify the WIFI Password")
                                                           delegate:self
                                                  cancelButtonTitle:MyLocalizedString(@"Cancel")
                                                  otherButtonTitles:MyLocalizedString(@"OK"), nil];
        
        [alertView show];
    }
    else if(self.txtPassword.text.trim.length<8) {
        [CommonUtil showMessage:MyLocalizedString(@"WIFI password shall not be less than 8")];
    }
    else if (![self.txtPassword.text.trim isEqualToString:self.txtVerifyPwd.text.trim])
    {
        [CommonUtil showMessage:MyLocalizedString(@"The new password and verify password is not equal")];
    }
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    __weak WIFISetting *weakSelf = self;
    if (buttonIndex==alertView.firstOtherButtonIndex) {
        if (self.currentWifiInfo) {
            [CommandClient configWifiName:self.txtWifiName.text.trim
                             withPassword:self.txtPassword.text.trim
                              withNeedPwd:self.switchNeedPwd.on
                               withResult:^(id info, HTTPAccessState isSuccess) {
                                   [weakSelf.navigationController popViewControllerAnimated:YES];
                               }];
        }
    }
}

- (IBAction)changeNeedPwd:(id)sender {
    self.txtPassword.enabled = self.switchNeedPwd.on;
}


@end
