//
//  TaskTableViewCell.h
//  racTest
//
//  Created by weiyun on 2018/1/11.
//  Copyright © 2018年 wy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIUtil.h"

@interface TaskTableViewCell : UITableViewCell

@property (nonatomic , strong) UIProgressView *progressView;
@property (nonatomic , strong) UIButton *downloadBtn;
@property (nonatomic , strong) UILabel *progressLabel;
@property (nonatomic , copy) NSString *urlString;

@end
