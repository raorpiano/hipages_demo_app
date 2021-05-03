//
//  NSString+FileUrlFromString.h
//  HiPages
//
//  Created by roy orpiano on 21/07/2017.
//  Copyright © 2017 raorpiano. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (FileUrlFromString)

- (NSURL *)localFilePathForUrlString;

- (BOOL)isLocalFileExistsForUrlString;

@end
