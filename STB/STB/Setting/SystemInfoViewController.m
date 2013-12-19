//
//  SystemInfoViewController.m
//  STB
//
//  Created by shulianyong on 13-10-26.
//  Copyright (c) 2013年 Chengdu Sifang Information Technology Co.LTD. All rights reserved.
//

#import "SystemInfoViewController.h"
#import "CommandClient.h"

@interface SystemInfoViewController ()
@property (strong, nonatomic) IBOutlet UILabel *lblLoaderVersion;
@property (strong, nonatomic) IBOutlet UILabel *lblSoftwareVersion;
@property (strong, nonatomic) IBOutlet UILabel *lblReleaseDate;
@property (strong, nonatomic) IBOutlet UILabel *lblDefaultDB;
@property (strong, nonatomic) IBOutlet UILabel *lblLib;
@property (strong, nonatomic) IBOutlet UILabel *lblVersion;

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
            NSDictionary *dicInfo = info;
            self.lblLoaderVersion.text = [NSString stringWithFormat:@"%@ %@",MyLocalizedString(self.lblLoaderVersion.text),[dicInfo objectForKey:@"Loader"]];
            self.lblSoftwareVersion.text = [NSString stringWithFormat:@"%@ %@",MyLocalizedString(self.lblSoftwareVersion.text),[dicInfo objectForKey:@"Application"]];
            //REALEASE_DATE;
            NSNumber *releaseDateNumber = [dicInfo objectForKey:@"REALEASE_DATE"];
            NSString *realeaseDateStr = releaseDateNumber.stringValue;
            if ([NSString isEmpty:realeaseDateStr]) {
                realeaseDateStr = @"";
            }
            else
            {
                NSDate *realeaseDate = [NSDate dateFromString:realeaseDateStr withFormat:@"yyyyMMdd"];
                realeaseDateStr = [realeaseDate descriptionLocalAsFormat:@"yyyy-MM-dd"];
            }
            self.lblReleaseDate.text = [NSString stringWithFormat:@"%@ %@",MyLocalizedString(self.lblReleaseDate.text),realeaseDateStr];
            
            self.lblDefaultDB.text = [NSString stringWithFormat:@"%@ %@",MyLocalizedString(self.lblDefaultDB.text),[dicInfo objectForKey:@"Default DB"]];
            self.lblLib.text = [NSString stringWithFormat:@"%@ %@",MyLocalizedString(self.lblLib.text),[dicInfo objectForKey:@"Lib"]];
        }
        
    }];
    NSString *versionCode = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    self.lblVersion.text = [NSString stringWithFormat:@"%@ %@",MyLocalizedString(self.lblVersion.text),versionCode];
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

- (IBAction)click_back:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
