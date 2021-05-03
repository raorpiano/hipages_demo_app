//
//  Business+CoreDataProperties.h
//  HiPages
//
//  Created by roy orpiano on 20/07/2017.
//  Copyright © 2017 raorpiano. All rights reserved.
//

#import "Business+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Business (CoreDataProperties)

+ (NSFetchRequest<Business *> *)fetchRequest;

@property (nonatomic) int64_t businessId;
@property (nonatomic) BOOL isHired;
@property (nullable, nonatomic, copy) NSString *thumbnail;
@property (nullable, nonatomic, retain) Job *job;

@end

NS_ASSUME_NONNULL_END
