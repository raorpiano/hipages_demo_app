//
//  Job+CoreDataProperties.h
//  HiPages
//
//  Created by roy orpiano on 20/07/2017.
//  Copyright © 2017 raorpiano. All rights reserved.
//

#import "Job+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Job (CoreDataProperties)

+ (NSFetchRequest<Job *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *category;
@property (nonatomic) int64_t jobId;
@property (nullable, nonatomic, copy) NSDate *postedDate;
@property (nullable, nonatomic, copy) NSString *status;
@property (nullable, nonatomic, retain) NSSet<Business *> *businesses;

@end

@interface Job (CoreDataGeneratedAccessors)

- (void)addBusinessesObject:(Business *)value;
- (void)removeBusinessesObject:(Business *)value;
- (void)addBusinesses:(NSSet<Business *> *)values;
- (void)removeBusinesses:(NSSet<Business *> *)values;

@end

NS_ASSUME_NONNULL_END
