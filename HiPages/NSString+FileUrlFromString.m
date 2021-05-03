//
//  NSString+FileUrlFromString.m
//  HiPages
//
//  Created by roy orpiano on 21/07/2017.
//  Copyright © 2017 raorpiano. All rights reserved.
//

#import "NSString+FileUrlFromString.h"

@implementation NSString (FileUrlFromString)

- (NSURL *)localFilePathForUrlString
{
    NSString *documentsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true)[0];
    
    NSString *url = self;
    if (url) {
        NSString *lastPathComponent = url.lastPathComponent;
        NSString *fullPath = [documentsPath stringByAppendingPathComponent:lastPathComponent];
        
        return [NSURL fileURLWithPath:fullPath];
    }
    
    return nil;
}

- (BOOL)isLocalFileExistsForUrlString
{
    NSURL *localUrl = [self localFilePathForUrlString];
    if (localUrl.path) {
        
        BOOL isDir = NO;
        return [[NSFileManager defaultManager] fileExistsAtPath:localUrl.path isDirectory:&isDir];
    }
    
    return NO;
}

@end
