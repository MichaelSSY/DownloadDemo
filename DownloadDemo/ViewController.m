//
//  ViewController.m
//  DownloadDemo
//
//  Created by weiyun on 2018/1/12.
//  Copyright © 2018年 wy. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource,NSURLSessionDataDelegate>

@property (nonatomic , strong) NSMutableArray *urlArray;
@property (nonatomic , strong) UITableView *tableView;
@property (nonatomic , copy) NSString *urlString;
@property (nonatomic , strong) NSOutputStream *stream;
@property (nonatomic , strong) NSURLSessionDataTask *task;
@property (nonatomic , assign) NSInteger totalLength;
//****** AFNetworking ******//
@property (nonatomic , strong) AFURLSessionManager *manager;
@property (nonatomic , strong) NSURLSessionDataTask *downloadTask;
@property (nonatomic , assign) NSInteger currentLength;
@property (nonatomic , strong) NSFileHandle *fileHandle;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"%@", NSHomeDirectory());
    self.currentLength = 0;
    self.totalLength = 0;
    [self.view addSubview:self.tableView];
}
// 懒加载tableView
- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [UIView new];
        _tableView.rowHeight = 60.f;
    }
    return _tableView;
}

// 视频地址数据源
- (NSMutableArray *)urlArray
{
    if (!_urlArray) {
        _urlArray = [[NSMutableArray alloc]initWithCapacity:16];
        for (int i = 1; i < 17; i++) {
            NSString *urlString = [NSString stringWithFormat:@"http://120.25.226.186:32812/resources/videos/minion_0%d.mp4",i];
            [_urlArray addObject:urlString];
        }
    }
    return _urlArray;
}

#pragma mark - UITableViewDelegate,UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.urlArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * identifier = @"Cell";
    TaskTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[TaskTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.urlString = self.urlArray[indexPath.row];
    cell.downloadBtn.tag = indexPath.row;
    [cell.downloadBtn addTarget:self action:@selector(downloadClick:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

/**
 * manager的懒加载
 */
- (AFURLSessionManager *)manager {
    if (!_manager) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        // 1. 创建会话管理者
        _manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    }
    return _manager;
}
//******************** AFNetworking下载请求 *********************//

- (void)downloadClick:(UIButton *)sender
{
    if ([sender.titleLabel.text isEqualToString:@"开始"]) { // [开始下载/继续下载]
       [sender setTitle:@"暂停" forState:UIControlStateNormal];
//        // 沙盒文件路径
//        NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"111222333"];
//        NSInteger currentLength = [self fileLengthForPath:path];
//        if (currentLength > 0) {  // [继续下载]
//            self.currentLength = currentLength;
//        }
//
        [self.downloadTask resume];
        
    }else {
        [sender setTitle:@"开始" forState:UIControlStateNormal];
        [self.downloadTask suspend];
        self.downloadTask = nil;
    }
}
/**
* 获取已下载的文件大小
*/
- (NSInteger)fileLengthForPath:(NSString *)path {
    NSInteger fileLength = 0;
    NSFileManager *fileManager = [[NSFileManager alloc] init]; // default is not thread safe
    if ([fileManager fileExistsAtPath:path]) {
        NSError *error = nil;
        NSDictionary *fileDict = [fileManager attributesOfItemAtPath:path error:&error];
        if (!error && fileDict) {
            fileLength = [fileDict fileSize];
        }
    }
    return fileLength;
}

/**
 * downloadTask的懒加载
 */
- (NSURLSessionDataTask *)downloadTask {
    if (!_downloadTask) {
        // 创建下载URL
        NSURL *url = [NSURL URLWithString:@"http://120.25.226.186:32812/resources/videos/minion_01.mp4"];
        
        // 2.创建request请求
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        
        // 设置HTTP请求头中的Range
        NSString *range = [NSString stringWithFormat:@"bytes=%zd-", self.currentLength];
        [request setValue:range forHTTPHeaderField:@"Range"];
        
        __weak typeof(self) weakSelf = self;
        
        _downloadTask = [self.manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
            
            // 下载完成回调block
            NSLog(@"完成");
            
            // 清空长度
            weakSelf.currentLength = 0;
            weakSelf.totalLength = 0;
            
            // 关闭fileHandle
            [weakSelf.fileHandle closeFile];
            weakSelf.fileHandle = nil;
            
        }];
        
        [self.manager setDataTaskDidReceiveResponseBlock:^NSURLSessionResponseDisposition(NSURLSession * _Nonnull session, NSURLSessionDataTask * _Nonnull dataTask, NSURLResponse * _Nonnull response) {
            NSLog(@"启动任务");
            // 每次唤醒task的时候会回调这个block
            
            // 获得下载文件的总长度：请求下载的文件长度 + 当前已经下载的文件长度
            weakSelf.totalLength = response.expectedContentLength + self.currentLength;
            
            // 沙盒文件路径
            NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"111222333"];
            
            //NSLog(@"File downloaded to: %@",path);
            
            // 创建一个空的文件到沙盒中
            NSFileManager *manager = [NSFileManager defaultManager];
            
            if (![manager fileExistsAtPath:path]) {
                // 如果没有下载文件的话，就创建一个文件。如果有下载文件的话，则不用重新创建(不然会覆盖掉之前的文件)
                [manager createFileAtPath:path contents:nil attributes:nil];
            }
            
            // 创建文件句柄
            weakSelf.fileHandle = [NSFileHandle fileHandleForWritingAtPath:path];
            
            // 允许处理服务器的响应，才会继续接收服务器返回的数据
            return NSURLSessionResponseAllow;
        }];
        
        [self.manager setDataTaskDidReceiveDataBlock:^(NSURLSession * _Nonnull session, NSURLSessionDataTask * _Nonnull dataTask, NSData * _Nonnull data) {
            //NSLog(@"setDataTaskDidReceiveDataBlock");
            // 一直回调，直到下载完成
            
            // 指定数据的写入位置 -- 文件内容的最后面
            [weakSelf.fileHandle seekToEndOfFile];
            
            // 向沙盒写入数据
            [weakSelf.fileHandle writeData:data];
            
            // 拼接文件总长度
            weakSelf.currentLength += data.length;
            
            // 获取主线程，不然无法正确显示进度。
            NSOperationQueue* mainQueue = [NSOperationQueue mainQueue];
            [mainQueue addOperationWithBlock:^{
                // 下载进度
                NSLog(@"当前下载进度:%.2f%%",100.0 * weakSelf.currentLength / weakSelf.totalLength);
            }];
        }];
    }
    return _downloadTask;
}


//******************** 原生下载请求 *********************//

- (void)download:(UIButton *)button
{
    if ([button.titleLabel.text isEqualToString:@"开始"]) {
        
        [button setTitle:@"暂停" forState:UIControlStateNormal];
        
        NSString *url = self.urlArray[0];
        self.urlString = url;
        
        // 创建缓存目录文件
        [UIUtil creatCachesPath];
        
        NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
        
        // 创建流
        _stream = [NSOutputStream outputStreamToFileAtPath:[UIUtil getFileDataPathWithUrl:@"1122aabb"] append:YES];
        
        // 创建请求
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
        
        // 设置请求头
        NSString *range = [NSString stringWithFormat:@"bytes=%zd-", [UIUtil getDownloadFileLengthPathWithUrl:url]];
        [request setValue:range forHTTPHeaderField:@"Range"];
        
        // 创建一个Data任务
        _task = [session dataTaskWithRequest:request];
        
        [_task resume];
        
    }else if ([button.titleLabel.text isEqualToString:@"暂停"]){
        [button setTitle:@"继续" forState:UIControlStateNormal];
        [_task suspend];
    }else if ([button.titleLabel.text isEqualToString:@"继续"]){
        [_task resume];
        [button setTitle:@"暂停" forState:UIControlStateNormal];
    }
    
}

#pragma mark - NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSHTTPURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    // 打开流
    [_stream open];
 
    // 获得服务器这次请求 返回数据的总长度
    self.totalLength = [response.allHeaderFields[@"Content-Length"] integerValue];
    
    // 接收这个请求，允许接收服务器的数据
    completionHandler(NSURLSessionResponseAllow);
}

/**
 * 接收到服务器返回的数据，一直回调，直到下载完成
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    // 写入数据
    [_stream write:data.bytes maxLength:data.length];
    
    // 下载进度
    NSUInteger receivedSize = [UIUtil getDownloadFileLengthPathWithUrl:@"1122aabb"];
    CGFloat progress = 1.0 * receivedSize / self.totalLength;
    
    NSLog(@"%.f%%",progress*100);
}

/**
 * 请求完毕（成功|失败）
 */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    // 关闭流
    [_stream close];
    _stream = nil;
    NSLog(@"来了一次");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
