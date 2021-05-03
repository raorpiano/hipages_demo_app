//
//  Database.h
//  HiPages
//
//  Created by roy orpiano on 20/07/2017.
//  Copyright © 2017 raorpiano. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "Job+CoreDataClass.h"
#import "Business+CoreDataClass.h"

@interface Database : NSObject

- (NSManagedObjectContext *)mainManagedObjectContext;
+ (Database *)sharedInstance;
- (void)saveContext:(BOOL)wait;

@end
