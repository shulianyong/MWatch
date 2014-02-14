//
//  SystemInfoViewController.m
//  STB
//
//  Created by shulianyong on 13-10-26.
//  Copyright (c) 2013年 Shanghai Hanfir Enterprise Management Limited.. All rights reserved.
//

#import "SystemInfoViewController.h"
#import "CommandClient.h"
#import "STBSystemInfo.h"

@interface SystemInfoViewController ()

@property (strong, nonatomic) IBOutlet UILabel *lblBoxId;
@property (strong, nonatomic) IBOutlet UILabel *lblHardwareVersion;
@property (strong, nonatomic) IBOutlet UILabel *lblFirmwareVersion;
@property (strong, nonatomic) IBOutlet UILabel *lblFirmwareReleaseDate;
@property (strong, nonatomic) IBOutlet UILabel *lblAppVersion;


@end

@implementation SystemInfoViewController

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
    [CommandClient commandSystemInfo:^(id info, HTTPAccessState isSuccess) {
        if (isSuccess==HTTPAccessStateSuccess) {
            STBSystemInfo *currentSystemInfo = [[STBSystemInfo alloc] init];
            [currentSystemInfo reflectDataFromOtherObject:info];
            [STBSystemInfo setDefaultSystemInfo:currentSystemInfo];
            
            
            self.lblBoxId.text = currentSystemInfo.BOXID;
            self.lblHardwareVersion.text = currentSystemInfo.HardWare_Version;
            self.lblFirmwareVersion.text = currentSystemInfo.Software_Version;
            self.lblFirmwareReleaseDate.text = currentSystemInfo.Release_Date;
        }
        
    }];
    NSString *versionCode = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    self.lblAppVersion.text = versionCode;
    [self boundMultiLanWithView:self.view];
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

- (IBAction)click_back:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
