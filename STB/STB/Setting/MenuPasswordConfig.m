//
//  MenuPasswordConfig.m
//  STB
//
//  Created by shulianyong on 13-10-23.
//  Copyright (c) 2013年 Chengdu Sifang Information Technology Co.LTD. All rights reserved.
//

#import "MenuPasswordConfig.h"
#import "LockInfo.h"
#import "CommonUtil.h"
#import "CommandClient.h"

static NSInteger menuTagOffset = 100;
@interface MenuPasswordConfig ()

@property (strong, nonatomic) IBOutlet UIButton *btnBack;
@property (strong, nonatomic) IBOutlet UILabel *lblTitle;



@property (strong, nonatomic) IBOutlet UIScrollView *sclView;
@property (strong, nonatomic) IBOutlet UITextField *txtPrimitivePassword;
@property (strong, nonatomic) IBOutlet UITextField *txtNewPassword;
@property (strong, nonatomic) IBOutlet UITextField *txtChannelPassword;


@end

@implementation MenuPasswordConfig

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
    
    [self configTextFieldStyle];
    
    self.sclView.contentSize = CGSizeMake(480, 400);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    
    [self boundMultiLanWithView:self.view];
	// Do any additional setup after loading the view.
}

- (void)boundMultiLanWithView:(UIView*)supView
{
    for (UIView *sub in supView.subviews) {
        if (sub.subviews.count>0) {
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



- (void)configTextFieldStyle
{
    for (NSInteger i=0; i<3; i++) {
        UITextField *txtTemp = (UITextField*)[self.view viewWithTag:i+menuTagOffset];
        txtTemp.placeholder = MyLocalizedString(txtTemp.placeholder);
        
        UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        txtTemp.leftView = leftView;
        txtTemp.leftViewMode = UITextFieldViewModeAlways;
        
    }
    
    self.lblTitle.text = MyLocalizedString(@"Menu Password");
    [self.btnBack setTitle:MyLocalizedString(@"SETUP") forState:UIControlStateNormal];
}

#pragma mark ------------------------- 设置键盘问题
- (UITextField*)txtSelected
{
    UITextField *txtSelected = nil;
    for (NSInteger i=0; i<3; i++) {
        UITextField *txtTemp = (UITextField*)[self.view viewWithTag:i+menuTagOffset];
        if (txtTemp.isFirstResponder) {
            txtSelected = txtTemp;
            break;
        }
    }
    return txtSelected;
    
}

- (void)showKeyboard
{
    UITextField *txtSelected = [self txtSelected];
    CGFloat keyboardHeight = 162;
    NSNumber *time = @0.25;
    
    CGFloat offset = txtSelected.frame.origin.y+txtSelected.bounds.size.height+20+keyboardHeight-self.view.bounds.size.height;
    if (offset>0) {
        [UIView setAnimationDuration:[time doubleValue]];
        [UIView beginAnimations:@"keyboardWillShow" context:nil];
        self.sclView.contentOffset = CGPointMake(0, offset);
        [UIView commitAnimations];
    }
}

- (void)keyboardWillShow:(NSNotification*)obj
{
    [self.txtChannelPassword isFirstResponder];
    
    NSDictionary *keyUserinfo = [obj userInfo];
    NSNumber *time = [keyUserinfo valueForKey:UIKeyboardAnimationDurationUserInfoKey];
    CGRect keyboardBound = [[keyUserinfo valueForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    
    CGFloat offset = self.txtSelected.frame.origin.y+self.txtSelected.bounds.size.height+20+keyboardBound.size.width-self.view.bounds.size.height;
    if (offset>0) {
        [UIView setAnimationDuration:[time doubleValue]];
        [UIView beginAnimations:@"keyboardWillShow" context:nil];
        self.sclView.contentOffset = CGPointMake(0, offset);
        [UIView commitAnimations];
    }
}


- (void)keyboardWillHide:(NSNotification*)obj
{
    NSDictionary *keyUserinfo = [obj userInfo];
    NSNumber *time = [keyUserinfo valueForKey:UIKeyboardAnimationDurationUserInfoKey];
    [UIView setAnimationDuration:[time doubleValue]];
    [UIView beginAnimations:@"keyboardWillShow" context:nil];
    self.sclView.contentOffset = CGPointMake(0, 0);
    [UIView commitAnimations];
}

- (IBAction)click_txtExit:(UITextField*)sender {
    if (sender.returnKeyType==UIReturnKeyNext) {
        UITextField *txtNext = (UITextField*)[self.sclView viewWithTag:sender.tag+1];
        [txtNext becomeFirstResponder];
        [self showKeyboard];
    }
}

- (IBAction)touchView:(id)sender {
    UITextField *txtSelected = [self txtSelected];
    if (txtSelected) {
        [txtSelected resignFirstResponder];
    }
}


- (IBAction)txtChanged:(UITextField*)sender {
    
    if (sender.text.trim.length>4) {
        sender.text = [sender.text substringToIndex:4];
    }
    
}


- (IBAction)click_back:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)click_btnOK:(id)sender {
    //验证为空
    if ([NSString isEmpty:self.txtPrimitivePassword.text]) {
        [CommonUtil showMessage:MyLocalizedString(@"Please input the primitive password")];
    }
    else if ([NSString isEmpty:self.txtNewPassword.text])
    {
        [CommonUtil showMessage:MyLocalizedString(@"Please input the new password")];
    }
    else if ([NSString isEmpty:self.txtChannelPassword.text])
    {
        [CommonUtil showMessage:MyLocalizedString(@"Please input the channel password")];
    }
    //验证是否通过
    else if (![self.txtPrimitivePassword.text isEqualToString:[LockInfo shareInstance].univeral_passwd]
             && ![self.txtPrimitivePassword.text isEqualToString:[LockInfo shareInstance].passwd])
    {
        [CommonUtil showMessage:MyLocalizedString(@"Primitive is not correct,please reenter")];
    }//验证长度
    else if (self.txtNewPassword.text.trim.length!=4 || self.txtChannelPassword.text.trim.length!=4)
    {
        [CommonUtil showMessage:MyLocalizedString(@"Password lenth is 4,please reenter")];
    }
    
    else//验证能过
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:MyLocalizedString(@"Alert") message:MyLocalizedString(@"Are you sure to change the password") delegate:self cancelButtonTitle:MyLocalizedString(@"Cancel") otherButtonTitles:MyLocalizedString(@"OK"), nil];
        [alert show];
    }
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==alertView.firstOtherButtonIndex) {
        __weak MenuPasswordConfig *weakSelf = self;
        [CommandClient commandMenuPass:self.txtNewPassword.text.trim withChannelPassword:self.txtChannelPassword.text.trim withCallback:^(id info, HTTPAccessState isSuccess) {
            if (isSuccess==HTTPAccessStateSuccess) {
                [LockInfo shareInstance].passwd = weakSelf.txtNewPassword.text.trim;
                [LockInfo shareInstance].passwd_channel = weakSelf.txtChannelPassword.text.trim;
                [weakSelf click_back:nil];
            }
            else
            {
                [CommonUtil showMessage:MyLocalizedString(@"Change password fail")];
            }
        }];
    }
}

@end
