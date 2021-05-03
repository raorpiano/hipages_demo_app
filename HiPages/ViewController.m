//
//  ViewController.m
//  HiPages
//
//  Created by roy orpiano on 20/07/2017.
//  Copyright © 2017 raorpiano. All rights reserved.
//

#import "ViewController.h"
#import "TableViewCell.h"
#import "CollectionViewCell.h"
#import "Database.h"
#import "CoreDataHelper.h"
#import "IndexedCollectionView.h"
#import "NSString+FileUrlFromString.h"
#import "Download.h"
#import "DataForDownload.h"

@interface ViewController () <UITableViewDelegate, UITableViewDataSource, UICollectionViewDataSource, UICollectionViewDelegate, NSURLSessionDownloadDelegate, TableViewCellDelegate>

@property (strong, nonatomic) IBOutlet UIButton *openJobsButton;
@property (strong, nonatomic) IBOutlet UIButton *closedJobsButton;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) BOOL viewingOpenJobs;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSFetchedResultsController * fetchedResultsController;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;

@property (strong, nonatomic) NSURLSessionTask *dataTask;
@property (strong, nonatomic) NSURLSession *defaultSession;
@property (strong, nonatomic) NSMutableDictionary *activeDownloads;
@property (strong, nonatomic) NSURLSession *downloadsSession;

@end

@implementation ViewController

- (NSURLSession *)downloadsSession {
    
    if (_downloadsSession != nil) {
        return _downloadsSession;
    }
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"bgSessionConfiguration"];
    
    _downloadsSession = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    
    return _downloadsSession;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _viewingOpenJobs = YES;
    
    _activeDownloads = [[NSMutableDictionary alloc] init];
    _defaultSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    _downloadsSession = [self downloadsSession];
    
    _managedObjectContext = [[Database sharedInstance] mainManagedObjectContext];
    
    _dateFormatter = [[NSDateFormatter alloc] init];
    _dateFormatter.dateStyle = NSDateFormatterShortStyle;
    _dateFormatter.dateFormat = @"YYYY-MM-dd";
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.estimatedRowHeight = 324;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tableView.bounds.size.width, 1.0f)];
    
    [self doFetch];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)displayClosedJobs:(id)sender {
    _viewingOpenJobs = NO;
    [self doFetch];
}
- (IBAction)displayOpenJobs:(id)sender {
    _viewingOpenJobs = YES;
    [self doFetch];
}


- (NSFetchedResultsController *)fetchedResultsController {
    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    
    NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] init];
    NSManagedObjectContext *context = _managedObjectContext;
    
    NSEntityDescription * entity = [NSEntityDescription entityForName:@"Job" inManagedObjectContext:context];
    
    [fetchRequest setEntity:entity];
    
    NSPredicate * filterPredicate = nil;
    
    if (_viewingOpenJobs)
        filterPredicate = [NSPredicate predicateWithFormat:@"status CONTAINS[cd] 'In Progress'"];
    else
        filterPredicate = [NSPredicate predicateWithFormat:@"status CONTAINS[cd] 'Closed'"];
    
    [fetchRequest setPredicate:filterPredicate];
    
    NSSortDescriptor *sortByCategory = [[NSSortDescriptor alloc] initWithKey:@"category" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortByCategory, nil]];
    
    
    [fetchRequest setPredicate:filterPredicate];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    
    
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                    managedObjectContext:context
                                                                      sectionNameKeyPath:@"category"
                                                                               cacheName:nil];
    
    
    return _fetchedResultsController;
}

- (void)doFetch
{
    self.fetchedResultsController = nil;
    
    [[[self fetchedResultsController] managedObjectContext] performBlock:^{
        
        NSError * error = nil;
        
        if (![[self fetchedResultsController] performFetch:&error]) {
            NSLog(@"Error performing fetch: %@", [error localizedFailureReason]);
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }
        
    }];
    
}


#pragma mark -- tableview delegates
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger count = [[self.fetchedResultsController sections] count];
    
    return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    
    NSInteger count = [sectionInfo numberOfObjects];
    
    return count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *v = [UIView new];
    [v setBackgroundColor:[UIColor clearColor]];
    return v;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    if (!cell) {
        cell = [[TableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(TableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    Job *job = [_fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.jobTitle.text = job.category;
    cell.status.text = job.status;
    cell.datePosted.text = [_dateFormatter stringFromDate:job.postedDate];
    cell.indexPath = indexPath;
    cell.delegate = self;
    
    if (_viewingOpenJobs)
        cell.closedButton.hidden = NO;
    else
        cell.closedButton.hidden = YES;
    
    
    NSInteger numBusinesses = [[job businesses] allObjects].count;
    if (numBusinesses) {
        cell.connectedMessageLabel.text = [NSString stringWithFormat:@"You have hired %ld businesses", numBusinesses];
    } else {
        cell.connectedMessageLabel.text = @"Connecting you with businesses";
    }
    
    [cell setCollectionViewDataSourceDelegate:self indexPath:indexPath];
}

////////////////////////////////////////////////////////////////////////////
#pragma mark - Thumbnail download methods
- (void)pauseDownload:(DataForDownload *)dataForDownload
{
    NSString *urlString = dataForDownload.thumnailUrl;
    Download *download = _activeDownloads[urlString];
    if (download) {
        if (download.isDownloading) {
            [download.downloadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
                if (resumeData != nil) {
                    download.resumeData = resumeData;
                    download.isDownloading = NO;
                }
            }];
        }
    }
}

- (void)resumDownload:(DataForDownload *)dataForDownload
{
    NSString *urlString = dataForDownload.thumnailUrl;
    Download *download = _activeDownloads[urlString];
    NSData *resumeData = download.resumeData;
    if (resumeData != nil) {
        download.downloadTask = [_downloadsSession downloadTaskWithResumeData:resumeData];
        [download.downloadTask resume];
        download.isDownloading = YES;
    } else {
        NSURL *url = [NSURL URLWithString:download.url];
        if (url) {
            download.downloadTask = [_downloadsSession downloadTaskWithURL:url];
            [download.downloadTask resume];
            download.isDownloading = YES;
        }
    }
}

- (void)startDownload:(DataForDownload *)dataForDownload
{
    if (dataForDownload.thumnailUrl) {
        NSURL *url = [NSURL URLWithString:dataForDownload.thumnailUrl];
        
        Download *download = [[Download alloc] init:dataForDownload.thumnailUrl];
        download.downloadTask = [_downloadsSession downloadTaskWithURL:url];
        download.indexPath = dataForDownload.indexPath;
        
        [download.downloadTask resume];
        download.isDownloading = YES;
        
        _activeDownloads[download.url] = download;
    }
    
}


#pragma mark -- UICollectionViewCell delegates

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    Job *job = [_fetchedResultsController objectAtIndexPath:[(IndexedCollectionView *)collectionView indexPath]];
    
    NSArray *businesses = [CoreDataHelper searchObjectsForEntity:@"Business" withPredicate:[NSPredicate predicateWithFormat:@"job == %@", job] andSortKey:nil andSortAscending:NO andContext:_managedObjectContext];
    
    
    return businesses.count;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(nonnull UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    NSInteger numItems = [self collectionView:collectionView numberOfItemsInSection:section];
    CGFloat totalCellWidth = 50 * numItems;
    CGFloat totalSpacingWidth = 10 * (numItems - 1);
    CGFloat leftInset = (collectionView.bounds.size.width - (totalCellWidth + totalSpacingWidth)) / 2;
    CGFloat rightInset = leftInset;
    UIEdgeInsets sectionInset = UIEdgeInsetsMake(0, leftInset, 0, rightInset);
    return sectionInset;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"collectionViewCell" forIndexPath:indexPath];
    
//    cell.imageView.image = [UIImage imageNamed:@"sampleAvatar"];
    
    Job *job = [_fetchedResultsController objectAtIndexPath:[(IndexedCollectionView *)collectionView indexPath]];
    
    NSArray *businesses = [CoreDataHelper searchObjectsForEntity:@"Business" withPredicate:[NSPredicate predicateWithFormat:@"job == %@", job] andSortKey:nil andSortAscending:NO andContext:_managedObjectContext];
    
    if (businesses.count) {
        Business *business = (Business *)[businesses objectAtIndex:indexPath.row];
        cell.status.text = business.isHired ? @"Hired" : @"Open";
        
        if ([business.thumbnail isLocalFileExistsForUrlString]) {
            NSURL *thumbnaildUrL = [business.thumbnail localFilePathForUrlString];
            cell.imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:thumbnaildUrL]];
        } else {
            DataForDownload *dataForDownload = [[DataForDownload alloc] init];
            dataForDownload.thumnailUrl = business.thumbnail;
            dataForDownload.indexPath = [(IndexedCollectionView *)collectionView indexPath];
            [self startDownload:dataForDownload];
        }
    }
    
    return cell;
}

#pragma mark - NSURLSessionDelegate methods
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    NSLog(@"Finished downloading");
    
    NSString *originalURL = [downloadTask.originalRequest.URL absoluteString];
    NSURL *destinationURL = [originalURL localFilePathForUrlString];
    NSLog(@"Destination url: %@", destinationURL);
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    @try {
        [fileManager removeItemAtURL:destinationURL error:nil];
    } @catch (NSException *exception) {
        //
    } @finally {
        @try {
            [fileManager copyItemAtURL:location toURL:destinationURL error:nil];
        } @catch (NSException *exception) {
            NSLog(@"Could not copy file to disk");
        } @finally {
            //
        }
    }
    
    NSString *url = [downloadTask.originalRequest.URL absoluteString];
    if (url) {
        Download *download = _activeDownloads[url];
        
        NSIndexPath *indexPath = download.indexPath;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (indexPath)
                [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            
            
        });
        
        _activeDownloads[url] = nil;
    }
    
}

#pragma mark -- TableViewCellDelegate
- (void)cellCloseButtonPressedAtIndexPath:(NSIndexPath *)indexPath
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"Are you sure you want to close this job?" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *close = [UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        Job *job = [_fetchedResultsController objectAtIndexPath:indexPath];
        job.status = @"Closed";
        [_managedObjectContext save:nil];
        [[Database sharedInstance] saveContext:YES];
        [self doFetch];
    }];
    [alert addAction:close];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:nil];
}




@end
