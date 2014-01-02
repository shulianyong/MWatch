//
//  ChannelCell.m
//  STB
//
//  Created by shulianyong on 13-10-12.
//  Copyright (c) 2013年 Chengdu Sifang Information Technology Co.LTD. All rights reserved.
//

#import "ChannelCell.h"

@implementation ChannelCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    //设置选中样式
    //    [self setSelectionStyle:UITableViewCellSelectionStyleGray];
    
    self.imageView.frame = CGRectMake(5, 16,28, 28);
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    static NSInteger aTag = 1000;
    UIView *lockView = [self viewWithTag:aTag];
    if (lockView) {
        [lockView removeFromSuperview];
    }
    
    if (self.isLock) {
        UIImageView *imgLock = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lock.png"]];
        imgLock.tag = aTag;
        imgLock.frame = CGRectMake(28-8-2, 28-9-2, 8, 9);
        [self.imageView addSubview:imgLock];
    }
    
    
    
    //设置文样式
    //    self.textLabel.font = [UIFont systemFontOfSize:16];
    //    self.textLabel.textColor = RGBColor(52, 52, 52);
    //
    //    self.detailTextLabel.font = [UIFont systemFontOfSize:11];
    //    self.detailTextLabel.textColor = RGBColor(81, 81, 81);
    
    //设置位置
    CGFloat X = 5+28+5;
    CGFloat width = self.bounds.size.width;
    CGRect textLabelFrame = CGRectMake(X
                                , 5
                                , width-X
                                , self.frame.size.height-10);
    self.textLabel.frame = textLabelFrame;
    self.textLabel.numberOfLines = 0;
    self.textLabel.textColor = [UIColor whiteColor];
    self.textLabel.font = [UIFont systemFontOfSize:13];
    
}

@end
