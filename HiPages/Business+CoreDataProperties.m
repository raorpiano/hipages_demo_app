//
//  Business+CoreDataProperties.m
//  HiPages
//
//  Created by roy orpiano on 20/07/2017.
//  Copyright © 2017 raorpiano. All rights reserved.
//

#import "Business+CoreDataProperties.h"

@implementation Business (CoreDataProperties)

+ (NSFetchRequest<Business *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Business"];
}

@dynamic businessId;
@dynamic isHired;
@dynamic thumbnail;
@dynamic job;

@end
