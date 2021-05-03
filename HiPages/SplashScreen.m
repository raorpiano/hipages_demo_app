//
//  SplashScreen.m
//  HiPages
//
//  Created by roy orpiano on 20/07/2017.
//  Copyright © 2017 raorpiano. All rights reserved.
//

#import "SplashScreen.h"
#import "Database.h"
#import "ViewController.h"
#import "CoreDataHelper.h"

@interface SplashScreen ()

@end

@implementation SplashScreen

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = YES;
    
    //////////////////////////////////////////
    /* should be a nsurlsessiontask/nsurlsession or nsurlconnection */
    NSString *path = [[NSBundle mainBundle] pathForResource:@"jobs" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSDictionary *collectionJSON = [[NSDictionary alloc] initWithDictionary:[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil]];
    
    NSArray *jobs = collectionJSON[@"jobs"];
    
    NSManagedObjectContext *managedObjectContext = [[Database sharedInstance] mainManagedObjectContext];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = NSDateFormatterShortStyle;
    dateFormatter.dateFormat = @"YYYY-MM-dd";
    
    for (NSDictionary *j in jobs) {
        
        /* Should add checking if the record already exists */
        Job *job;
        
        NSArray *searchResult1 = [CoreDataHelper searchObjectsForEntity:@"Job" withPredicate:[NSPredicate predicateWithFormat:@"jobId = %ld", [j[@"jobId"] integerValue]] andSortKey:nil andSortAscending:NO andContext:managedObjectContext];
        
        if (searchResult1.count) {
            job = (Job *)[searchResult1 firstObject];
        } else {
            job = (Job *)[NSEntityDescription insertNewObjectForEntityForName:@"Job" inManagedObjectContext:managedObjectContext];
        }
        
        job.jobId = [j[@"jobId"] integerValue];
        job.category = j[@"category"];
        job.postedDate = [dateFormatter dateFromString:j[@"postedDate"]];
        job.status = j[@"status"];
        
        NSArray *businesses = j[@"connectedBusinesses"];
        
        if ([businesses isEqual:[NSNull null]]) continue;
        
        for (NSDictionary *b in businesses) {
            /* Should add checking if the record already exists */
            Business *business;
            
            NSArray *searchResult2 = [CoreDataHelper searchObjectsForEntity:@"Business" withPredicate:[NSPredicate predicateWithFormat:@"businessId = %ld", [b[@"businessId"] integerValue]] andSortKey:nil andSortAscending:NO andContext:managedObjectContext];
            
            if (searchResult2.count) {
                business = (Business *)[searchResult2 firstObject];
            } else {
                business = (Business *)[NSEntityDescription insertNewObjectForEntityForName:@"Business" inManagedObjectContext:managedObjectContext];
                
                business.job = job;
            }
            
            business.businessId = [b[@"businessId"] integerValue];
            business.thumbnail = b[@"thumbnail"];
            business.isHired = [b[@"isHired"] boolValue];
        }
    }

    [[Database sharedInstance] saveContext:YES];
    
    ////////////////////////////////////////
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ViewController *vc = [storyboard instantiateViewControllerWithIdentifier:kViewControllerIdentifier];
    [self showViewController:vc sender:self];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
