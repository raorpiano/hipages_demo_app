//
//  CoreDataHelper.m
//  HiPages
//
//  Created by roy orpiano on 20/07/2017.
//  Copyright © 2017 raorpiano. All rights reserved.
//

#import "CoreDataHelper.h"


@implementation CoreDataHelper

// Fetch objects with a predicate
+(NSMutableArray *)searchObjectsForEntity:(NSString*)entityName withPredicate:(NSPredicate *)predicate andSortKey:(NSString*)sortKey andSortAscending:(BOOL)sortAscending andContext:(NSManagedObjectContext *)managedObjectContext
{
    // Create fetch request
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:managedObjectContext];
    [request setEntity:entity];
    
    // If a predicate was specified then use it in the request
    if (predicate != nil)
        [request setPredicate:predicate];
    
    // If a sort key was passed then use it in the request
    if (sortKey != nil) {
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortKey ascending:sortAscending];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
        [request setSortDescriptors:sortDescriptors];
    }
    
    // Execute the fetch request
    NSError *error = nil;
    NSMutableArray *mutableFetchResults = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    
    // If the returned array was nil then there was an error
    if (mutableFetchResults == nil)
        NSLog(@"Couldn't get objects for entity %@", entityName);
    
    // Return the results
    return mutableFetchResults;
}

@end
