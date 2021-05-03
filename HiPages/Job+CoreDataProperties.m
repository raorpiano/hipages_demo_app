//
//  Job+CoreDataProperties.m
//  HiPages
//
//  Created by roy orpiano on 20/07/2017.
//  Copyright © 2017 raorpiano. All rights reserved.
//

#import "Job+CoreDataProperties.h"

@implementation Job (CoreDataProperties)

+ (NSFetchRequest<Job *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Job"];
}

@dynamic category;
@dynamic jobId;
@dynamic postedDate;
@dynamic status;
@dynamic businesses;

@end
