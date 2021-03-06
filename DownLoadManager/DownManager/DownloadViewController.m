//
//  DownloadViewController.m


#import "DownloadViewController.h"
#import "FilesDownManage.h"
#define OPENFINISHLISTVIEW

@implementation DownloadViewController

@synthesize downloadingTable;
@synthesize finishedTable;
@synthesize downingList;
@synthesize finishedList;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [downingList release];
    [finishedList release];
    [downloadingTable release];
    [finishedTable release];
    [_editbtn release];
    [clearallbtn release];
    [backbtn release];
    [_diskInfoLab release];
    [_bandwithLab release];
    [_noLoadsInfo release];

    [_downloadingViewBtn release];
    [_finieshedViewBtn release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (IBAction)goDownloadingView:(UIButton *)sender {
    downloadingTable.hidden = NO;
    finishedTable.hidden =YES;
    clearallbtn.hidden = YES;
    self.finieshedViewBtn.selected = NO;
    self.downloadingViewBtn.selected = YES;
    [self.downloadingTable reloadData];
}

- (IBAction)goFinishedView:(UIButton *)sender {
    downloadingTable.hidden = YES;
    finishedTable.hidden =NO;
    clearallbtn.hidden = NO;
    self.finieshedViewBtn.selected =YES;
    self.downloadingViewBtn.selected = NO;
    [self.finishedTable reloadData];
    self.noLoadsInfo.hidden = YES;
}

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)showFinished
{
    [self startFlipAnimation:0];
    self.navigationItem.rightBarButtonItem= [self makeCustomRightBarButItem:@"下载中" action:@selector(showDowning)];
}

-(void)showDowning
{
    [self startFlipAnimation:1];
    self.navigationItem.rightBarButtonItem=[self makeCustomRightBarButItem:@"已下载" action:@selector(showFinished)];
}


-(void)startFlipAnimation:(NSInteger)type
{
    CGContextRef context=UIGraphicsGetCurrentContext();
    [UIView beginAnimations:nil context:context];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:1.0f];
    UIView *lastView=[self.view viewWithTag:103];
    
    if(type==0)
    {
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:lastView cache:YES];
    }
    else
    {
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:lastView cache:YES];
    }
    
    UITableView *frontTableView=(UITableView *)[lastView viewWithTag:101];
    UITableView *backTableView=(UITableView *)[lastView viewWithTag:102];
    NSInteger frontIndex=[lastView.subviews indexOfObject:frontTableView];
    NSInteger backIndex=[lastView.subviews indexOfObject:backTableView];
    [lastView exchangeSubviewAtIndex:frontIndex withSubviewAtIndex:backIndex];
    [UIView commitAnimations];
}


-(IBAction)enterEdit:(UIButton*)sender
{
//    self.navigationItem.leftBarButtonItem=[[[UIBarButtonItem alloc]initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(leaveEdit)]autorelease];
    sender.selected = !sender.selected;
    if (!sender.selected) {
        [self.downloadingTable setEditing:NO animated:YES];
        [self.finishedTable setEditing:NO animated:YES];
        backbtn.hidden = NO;
        clearallbtn.hidden = YES;
        
    }else{
    [self.downloadingTable setEditing:YES animated:YES];
    [self.finishedTable setEditing:YES animated:YES];
        backbtn.hidden = YES;
        clearallbtn.hidden = NO;
    }
}

-(IBAction)clearlist:(UIButton *)sender{
    if ([self.finishedList count]==0)
        return;
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"删除已完成列表的所有内容，将不会删除对应的文件，确认删除吗?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
    [alert show];
    [alert release];
    return;
}
-(void)clearAction{
    if (!self.downloadingTable.hidden) {
        if ([self.downingList count]>0) {
            FilesDownManage *filedownmanage = [FilesDownManage sharedFilesDownManage];
            [filedownmanage clearAllRquests];
            [self.downingList removeAllObjects];
            [self.downloadingTable reloadData];
        }
    }else if (!self.finishedTable.hidden){
        if ([self.finishedList count]>0) {
            FilesDownManage *filedownmanage = [FilesDownManage sharedFilesDownManage];
            [filedownmanage clearAllFinished];
            [self.finishedList removeAllObjects];
            [self.finishedTable reloadData];
        }
    }
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==1) {
        [self clearAction];
    }
}
//-(UIImage *)getImage:(FileModel *)fileinfo{
//    FilesDownManage *filedownmanage = [FilesDownManage sharedFilesDownManage];
//    return [filedownmanage getImage:fileinfo];
//}
#pragma mark - View lifecycle

-(void)viewWillAppear:(BOOL)animated
{
    // self.navigationController.navigationBar.hidden = YES;
    FilesDownManage *filedownmanage = [FilesDownManage sharedFilesDownManage];
    
    [filedownmanage startLoad];
    self.downingList=filedownmanage.downinglist;
    [self.downloadingTable reloadData];
    
    self.finishedList=filedownmanage.finishedlist;
    [self.finishedTable reloadData];

}
-(void)viewWillDisappear:(BOOL)animated{
    // self.navigationController.navigationBar.hidden = NO;
    FilesDownManage *filedownmanage = [FilesDownManage sharedFilesDownManage];
    [filedownmanage saveFinishedFile];
}
- (void)viewDidLoad
{
    self.title = @"下载管理";
    [super viewDidLoad];
 
     version =[[[UIDevice currentDevice] systemVersion] floatValue];
\
    
    [FilesDownManage sharedFilesDownManage].downloadDelegate = self;

    downloadingTable.hidden = NO;
    finishedTable.hidden =YES;
    self.finieshedViewBtn.selected = NO;
    self.downloadingViewBtn.selected = YES;
    clearallbtn.hidden = YES;
    self.diskInfoLab.text = [CommonHelper getDiskSpaceInfo];
   
}

- (void)viewDidUnload
{

    [self setDownloadingViewBtn:nil];
    [self setFinieshedViewBtn:nil];
    
    [self setEditbtn:nil];
    [clearallbtn release];
    clearallbtn = nil;
    [backbtn release];
    backbtn = nil;
    [self setDiskInfoLab:nil];
    [self setBandwithLab:nil];
    [self setNoLoadsInfo:nil];
   
    self.downloadingTable=nil;
    self.finishedTable=nil;
     [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
-(UIBarButtonItem*)makeCustomRightBarButItem:(NSString *)titlestr action:(SEL)action{
    CGRect frame_1= CGRectMake(0, 0, 45, 27);
    UIImage* image= [UIImage imageNamed:@"顶部按钮背景.png"];
    UIButton* showfinishbtn= [[UIButton alloc] initWithFrame:frame_1];
    [showfinishbtn setBackgroundImage:image forState:UIControlStateNormal];
    [showfinishbtn setTitle:titlestr forState:UIControlStateNormal];
    [showfinishbtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    showfinishbtn.titleLabel.font=[UIFont systemFontOfSize:14];
    [showfinishbtn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem* showFinishedBarButtonItem= [[[UIBarButtonItem alloc] initWithCustomView:showfinishbtn]autorelease];
    [showfinishbtn release];
    return showFinishedBarButtonItem;
}
#pragma mark ---UITableView Delegate---

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView==self.downloadingTable)
    {
        if (self.downingList.count==0) {
            if (self.downloadingTable.hidden) {
                self.noLoadsInfo.hidden = YES;
            }else
            self.noLoadsInfo.hidden = NO;
        }else
            self.noLoadsInfo.hidden = YES;
        return [self.downingList count];
    }
    else
    {
        return [self.finishedList count];
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView==self.downloadingTable)//正在下载的文件列表
    {
        static NSString *downCellIdentifier=@"DownloadCell";
        DownloadCell *cell=(DownloadCell *)[tableView dequeueReusableCellWithIdentifier:downCellIdentifier];
        cell.delegate = self;
        [cell.progress1 setTrackImage:[UIImage imageNamed:@"下载管理进度条背景.png"]];
        [cell.progress1 setProgressImage:[UIImage imageNamed:@"下载管理进度背景点九.png"]];


        ASIHTTPRequest *theRequest=[self.downingList objectAtIndex:indexPath.row];
        if (theRequest==nil) {
            return cell=Nil;
        }
        FileModel *fileInfo=[theRequest.userInfo objectForKey:@"File"];
        NSString *currentsize = [CommonHelper getFileSizeString:fileInfo.fileReceivedSize];
        NSString *totalsize = [CommonHelper getFileSizeString:fileInfo.fileSize];
        cell.fileName.text=fileInfo.fileName;
        cell.fileCurrentSize.text=currentsize;
        if ([totalsize longLongValue]<=0) {
            cell.fileSize.text=@"未知";
        }else
        cell.fileSize.text=[NSString stringWithFormat:@"大小:%@",totalsize];
       // cell.sizeinfoLab.text = [NSString stringWithFormat:@"%@/%@",currentsize,totalsize];
        cell.fileInfo=fileInfo;
        cell.request=theRequest;
        cell.fileTypeLab.text  =[NSString stringWithFormat:@"格式:%@",fileInfo.fileType] ;
        cell.timelable.text =[NSString stringWithFormat:@"%@",fileInfo.time] ;
        cell.timelable.hidden = YES;
        cell.fileImage.image = fileInfo.fileimage;//[self getImage:fileInfo];

        if ([currentsize longLongValue]==0) {
            [cell.progress1 setProgress:0.0f];
        }else
        [cell.progress1 setProgress:[CommonHelper getProgress:[fileInfo.fileSize longLongValue] currentSize:[fileInfo.fileReceivedSize longLongValue]]];
        cell.sizeinfoLab.text =[NSString stringWithFormat:@"%0.0f%@",100*(cell.progress1.progress),@"%"];
       // NSLog(@"process:%@",cell.sizeinfoLab.text);
        if(fileInfo.isDownloading)//文件正在下载
        {
            [cell.operateButton setBackgroundImage:[UIImage imageNamed:@"下载管理-暂停按钮.png"] forState:UIControlStateNormal];
        }
        else if(!fileInfo.isDownloading && !fileInfo.willDownloading&&!fileInfo.error)
        {
            [cell.operateButton setBackgroundImage:[UIImage imageNamed:@"下载管理-开始按钮.png"] forState:UIControlStateNormal];
            cell.sizeinfoLab.text = @"暂停";
        }else if(!fileInfo.isDownloading && fileInfo.willDownloading&&!fileInfo.error)
        {
            [cell.operateButton setBackgroundImage:[UIImage imageNamed:@"下载管理-开始按钮.png"] forState:UIControlStateNormal];
            cell.sizeinfoLab.text = @"等待";
        }else if (fileInfo.error)
        {
            [cell.operateButton setBackgroundImage:[UIImage imageNamed:@"下载管理-开始按钮.png"] forState:UIControlStateNormal];
            cell.sizeinfoLab.text = @"错误";
        }
        return cell;
    }

    else if(tableView==self.finishedTable)//已完成下载的列表
    {
      
        static NSString *finishedCellIdentifier=@"FinishedCell";
        FinishedCell *cell=(FinishedCell *)[self.finishedTable dequeueReusableCellWithIdentifier:finishedCellIdentifier];
          cell.delegate = self;

        FileModel *fileInfo=[self.finishedList objectAtIndex:indexPath.row];
        cell.fileName.text=fileInfo.fileName;
        
        cell.fileSize.text=[CommonHelper getFileSizeString:fileInfo.fileSize];
        cell.fileInfo=fileInfo;
        cell.fileTypeLab.text  =[NSString stringWithFormat:@"格式:%@",fileInfo.fileType] ;
        cell.timelable.text =[NSString stringWithFormat:@"%@",fileInfo.time] ;
        cell.fileImage.image = fileInfo.fileimage;
        return cell;
    }

    return nil;
    
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return NO;
}
//-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return 80;
//}
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除任务";
}
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(editingStyle==UITableViewCellEditingStyleDelete)//点击了删除按钮,注意删除了该视图列表的信息后，还要更新UI和APPDelegate里的列表
    {
        if(tableView.tag==101)//正在下载的表格
        {
            ASIHTTPRequest *theRequest=[self.downingList objectAtIndex:indexPath.row];
            [[FilesDownManage sharedFilesDownManage] deleteRequest:theRequest];
            [self.downingList removeObjectAtIndex:indexPath.row];
            [self.downloadingTable reloadData];
        }
#ifdef OPENFINISHLISTVIEW
        else//已经完成下载的表格
        {
            FileModel *selectFile=[self.finishedList objectAtIndex:indexPath.row];
            [[FilesDownManage sharedFilesDownManage]  deleteFinishFile:selectFile];
            [self.finishedTable reloadData];
        }
#endif
    }
}

-(void)updateCellOnMainThread:(FileModel *)fileInfo
{
//    self.bandwithLab.text = [NSString stringWithFormat:@"%@/S",[CommonHelper getFileSizeString:[NSString stringWithFormat:@"%lu",[ASIHTTPRequest averageBandwidthUsedPerSecond]]]] ;
    NSArray* cellArr = [self.downloadingTable visibleCells];
    for(id obj in cellArr)
    {
        if([obj isKindOfClass:[DownloadCell class]])
        {
            DownloadCell *cell=(DownloadCell *)obj;
            if([cell.fileInfo.fileURL isEqualToString: fileInfo.fileURL])
            {
                NSString *currentsize;
                if (fileInfo.post) {
                    currentsize = fileInfo.fileUploadSize;
                    
                }else
                   currentsize = fileInfo.fileReceivedSize;
                NSString *totalsize = [CommonHelper getFileSizeString:fileInfo.fileSize];
                cell.fileCurrentSize.text=[CommonHelper getFileSizeString:currentsize];;
                cell.fileSize.text = [NSString stringWithFormat:@"大小:%@",totalsize];
//                cell.sizeinfoLab.text = [NSString stringWithFormat:@"%@/%@",currentsize,totalsize];
//                NSLog(@"%@",cell.sizeinfoLab.text);
                
                [cell.progress1 setProgress:[CommonHelper getProgress:[fileInfo.fileSize floatValue] currentSize:[currentsize floatValue]]];
                NSLog(@"%f",cell.progress1 .progress);

                 cell.sizeinfoLab.text =[NSString stringWithFormat:@"%.0f%@",100*(cell.progress1.progress),@"%"];
//                cell.averagebandLab.text =[NSString stringWithFormat:@"%@/s",[CommonHelper getFileSizeString:[NSString stringWithFormat:@"%lu",[ASIHTTPRequest averageBandwidthUsedPerSecond]]]] ;
                if(fileInfo.isDownloading)//文件正在下载
                {
                    [cell.operateButton setBackgroundImage:[UIImage imageNamed:@"下载管理-暂停按钮.png"] forState:UIControlStateNormal];
                }
                else if(!fileInfo.isDownloading && !fileInfo.willDownloading&&!fileInfo.error)
                {
                    [cell.operateButton setBackgroundImage:[UIImage imageNamed:@"下载管理-开始按钮.png"] forState:UIControlStateNormal];
                    cell.sizeinfoLab.text = @"暂停";
                }else if(!fileInfo.isDownloading && fileInfo.willDownloading&&!fileInfo.error)
                {
                    [cell.operateButton setBackgroundImage:[UIImage imageNamed:@"下载管理-开始按钮.png"] forState:UIControlStateNormal];
                    cell.sizeinfoLab.text = @"等待";
                }else if (fileInfo.error)
                {
                    [cell.operateButton setBackgroundImage:[UIImage imageNamed:@"下载管理-开始按钮.png"] forState:UIControlStateNormal];
                    cell.sizeinfoLab.text = @"错误";
                }
            }
        }
    }
}

#pragma mark --- updateUI delegate ---
-(void)startDownload:(ASIHTTPRequest *)request;
{
    NSLog(@"-------开始下载!");
}

-(void)updateCellProgress:(ASIHTTPRequest *)request;
{
    FileModel *fileInfo=[request.userInfo objectForKey:@"File"];
    [self performSelectorOnMainThread:@selector(updateCellOnMainThread:) withObject:fileInfo waitUntilDone:YES];
}

-(void)finishedDownload:(ASIHTTPRequest *)request;
{

   // [self.downingList removeObject:request];
    [self.downloadingTable reloadData];
     self.bandwithLab.text = @"0.00K/S";

    [self.finishedTable reloadData];

}
- (void)deleteFinishedFile:(FileModel *)selectFile
{
    self.finishedList = [FilesDownManage sharedFilesDownManage].finishedlist;
    [self.finishedTable reloadData];
}
-(void)ReloadDownLoadingTable
{
    self.downingList =[FilesDownManage sharedFilesDownManage].downinglist;
    [self.downloadingTable reloadData];
}
//-(BOOL) respondsToSelector:(SEL)aSelector {
//    printf("SELECTOR: %s\n", [NSStringFromSelector(aSelector) UTF8String]);
//    return [super respondsToSelector:aSelector];
//}
@end
