//
//  TaskTableViewCell.m
//  racTest
//
//  Created by weiyun on 2018/1/11.
//  Copyright © 2018年 wy. All rights reserved.
//

#import "TaskTableViewCell.h"

@implementation TaskTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.contentView.backgroundColor = [UIColor whiteColor];
        
        CGFloat btnW = 70.f;
        CGFloat btnH = 40.f;
        
        _progressView = [[UIProgressView alloc]initWithProgressViewStyle:UIProgressViewStyleDefault];
        _progressView.frame = CGRectMake(15, 45, SCREEN_WIDTH-2*btnW-4*15, 15);
        _progressView.trackTintColor = [UIColor lightGrayColor];// 进度条的底色
        _progressView.progressTintColor = [UIColor blueColor];
        _progressView.layer.masksToBounds = YES;
        _progressView.layer.cornerRadius = 2;
        [self.contentView addSubview:_progressView];
        
        _progressLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 4, 40, 40)];
        _progressLabel.textColor = [UIColor purpleColor];
        _progressLabel.clipsToBounds = YES;
        _progressLabel.text = @"0%";
        _progressLabel.textAlignment = NSTextAlignmentCenter;
        _progressLabel.layer.cornerRadius = 20;
        _progressLabel.backgroundColor = [UIColor yellowColor];
        _progressLabel.font = [UIFont systemFontOfSize:13];
        [self.contentView addSubview:_progressLabel];
        
        _downloadBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        _downloadBtn.frame = CGRectMake(SCREEN_WIDTH-2*btnW-2*15, 10, btnW, btnH);
        [_downloadBtn setBackgroundColor:[UIColor orangeColor]];
        [_downloadBtn setTitle:@"开始" forState:UIControlStateNormal];
        [_downloadBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.contentView addSubview:_downloadBtn];
        
        UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        deleteBtn.frame = CGRectMake(CGRectGetMaxX(_downloadBtn.frame)+15, CGRectGetMinY(_downloadBtn.frame), btnW, btnH);
        [deleteBtn addTarget:self action:@selector(deleteClick) forControlEvents:UIControlEventTouchUpInside];
        [deleteBtn setBackgroundColor:[UIColor orangeColor]];
        [deleteBtn setTitle:@"删除" forState:UIControlStateNormal];
        [deleteBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.contentView addSubview:deleteBtn];
    }
    return self;
}
- (void)setUrlString:(NSString *)urlString
{
    _urlString = urlString;

}
// 删除
- (void)deleteClick
{
 
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
