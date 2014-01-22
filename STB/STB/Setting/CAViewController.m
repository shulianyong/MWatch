//
//  CAViewController.m
//  STB
//
//  Created by shulianyong on 13-10-26.
//  Copyright (c) 2013年 Chengdu Sifang Information Technology Co.LTD. All rights reserved.
//

#import "CAViewController.h"
#import "CommandClient.h"

@interface CAViewController ()

@property (strong, nonatomic) IBOutlet UILabel *lblCAInfo;

@end

@implementation CAViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (NSDateFormatter*)dateFormatter {
	static NSDateFormatter *formatter = nil;
	if (formatter == nil)  {
		formatter = [[NSDateFormatter alloc] init];
		NSLocale *enUS = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
		[formatter setLocale:enUS];
		[formatter setDateFormat:@"MM dd yyyy"];
	}
	return formatter;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self boundMultiLanWithView:self.view];
    [CommandClient commandGetCAInfo:^(id info, HTTPAccessState isSuccess) {
        if (isSuccess==HTTPAccessStateSuccess) {
            NSDictionary *dicInfo = info;
            NSString *datetime = [dicInfo objectForKey:@"Valid Date"];
            self.lblCAInfo.text = [NSString stringWithFormat:@"%@%@",MyLocalizedString(@"The CA will expire on "),datetime];
        }
    }];
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
