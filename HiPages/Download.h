//
//  Download.h
//  HiPages
//
//  Created by roy orpiano on 21/07/2017.
//  Copyright © 2017 raorpiano. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Download : NSObject

@property (nullable, nonatomic, copy) NSString *url;
@property (nullable, nonatomic, copy) NSIndexPath *indexPath;
@property (nonatomic) BOOL isDownloading;
@property (nonatomic) float progress;
@property (nullable, nonatomic, copy) NSURLSessionDownloadTask *downloadTask;
@property (nullable, nonatomic, copy) NSData *resumeData;

- (id _Nonnull )init:(NSString *_Nullable)url;

@end
