//
//  FirmwareUpgradeController.m
//  STB
//
//  Created by shulianyong on 13-12-5.
//  Copyright (c) 2013年 Shanghai Hanfir Enterprise Management Limited.. All rights reserved.
//

#import "FirmwareUpgradeController.h"
#import "STBVersionCheck.h"

@interface FirmwareUpgradeController ()

@property (strong, nonatomic) IBOutlet UIButton *btnSelected;
@property (strong, nonatomic) IBOutlet UISwitch *switchFirmwareUpgrade;

@end

@implementation FirmwareUpgradeController

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
    
    [self boundMultiLanWithView:self.view];
    self.btnSelected.selected = [STBVersionCheck IsSTBRemindUpgrade];
    [self.switchFirmwareUpgrade setOn:[STBVersionCheck IsSTBRemindUpgrade] animated:YES];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (IBAction)click_barBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)click_btnUpgradeFirmware:(id)sender
{
    [[STBVersionCheck shareInstance] manualSTBUpdate];
}

- (IBAction)switchUpgrade:(id)sender
{
    BOOL isRemind = self.switchFirmwareUpgrade.isOn;    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:isRemind] forKey:STB_RemindUpgrade];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


@end
