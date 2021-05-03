//
//  Database.m
//  HiPages
//
//  Created by roy orpiano on 20/07/2017.
//  Copyright © 2017 raorpiano. All rights reserved.
//

#import "Database.h"

@interface Database()

@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic) NSManagedObjectContext *masterManagedObjectContext;
@property (strong, nonatomic) NSManagedObjectContext *mainManagedObjectContext;
@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (strong, nonatomic) NSURL *temporaryDirectoryURL;

@end

@implementation Database

static Database * sharedDatabaseInstance = nil;

+ (Database *)sharedInstance
{
    if (sharedDatabaseInstance == nil) {
        sharedDatabaseInstance = [[super allocWithZone:NULL] init];
    }
    
    return sharedDatabaseInstance;
}

- (id)init
{
    if ((self = [super init])) {
        
    }
    
    return self;
}

#pragma mark - Core Data stack
// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"HiPages" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}


// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"HiPages.sqlite"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:[storeURL path]]) {
        
        NSString *path = [[NSBundle mainBundle] pathForResource:@"HiPages" ofType:@"sqlite"];
        
        if (path) {
        
            NSURL * preloadURL = [NSURL fileURLWithPath:path];
            
            NSError * err = nil;
            if (![[NSFileManager defaultManager] copyItemAtURL:preloadURL toURL:storeURL error:&err]) {
                NSLog(@"Oops, could not copy preloaded data");
            }
        }
    }
    
    NSError *error = nil;
    
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    
    NSDictionary * options = @{ NSMigratePersistentStoresAutomaticallyOption : @(YES),
                                NSInferMappingModelAutomaticallyOption : @(YES) };
    
    
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        
        NSFileManager *fm = [NSFileManager defaultManager];
        
        // Move Incompatible Store
        if ([fm fileExistsAtPath:[storeURL path]]) {
            NSURL *corruptURL = [[self applicationIncompatibleStoresDirectory] URLByAppendingPathComponent:[self nameForIncompatibleStore]];
            
            // Move Corrupt Store
            NSError *errorMoveStore = nil;
            [fm moveItemAtURL:storeURL toURL:corruptURL error:&errorMoveStore];
            
            if (errorMoveStore) {
                NSLog(@"Unable to move corrupt store.");
            }
        }
    }
    
    return _persistentStoreCoordinator;
}


// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)masterManagedObjectContext
{
    if (_masterManagedObjectContext != nil) {
        return _masterManagedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _masterManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [_masterManagedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _masterManagedObjectContext;
}


// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)mainManagedObjectContext
{
    if (_mainManagedObjectContext != nil) {
        return _mainManagedObjectContext;
    }
    
    _mainManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    _mainManagedObjectContext.parentContext = [self masterManagedObjectContext];
    
    return _mainManagedObjectContext;
}


- (void)contextDidSaveMainQueueContext:(NSNotification *)notification
{
    @synchronized(self) {
        [self.masterManagedObjectContext performBlock:^{
            [self.masterManagedObjectContext mergeChangesFromContextDidSaveNotification:notification];
        }];
    }
}


/* Make wait = YES if we want to save the context when the app will be going into background or terminating. */
- (void)saveContext:(BOOL)wait
{
    
    NSManagedObjectContext * moc = [self mainManagedObjectContext];
    NSManagedObjectContext * master = [self masterManagedObjectContext];
    
    if (!moc) return;
    
    void (^saveMoc) (void) = ^{
        NSError * error = nil;
        
        if (![moc save:&error])
            NSLog(@"Error saving main managed object context: %@\n%@", [error localizedDescription], [error userInfo]);
    };
    
    
    if ([moc hasChanges])
        [moc performBlockAndWait:saveMoc];
    
    
    void (^saveMaster) (void) = ^{
        NSError * error = nil;
        if (![master save:&error])
            NSLog(@"Error saving main managed object context: %@\n%@", [error localizedDescription], [error userInfo]);
    };
    
    if ([master hasChanges]) {
        if (wait) {
            [master performBlockAndWait:saveMaster];
        } else {
            [master performBlock:saveMaster];
        }
    }
    
}


- (NSURL *)temporaryDirectoryURL
{
    if (_temporaryDirectoryURL != nil) {
        return _temporaryDirectoryURL;
    }
    
    _temporaryDirectoryURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:[[NSProcessInfo processInfo] globallyUniqueString]] isDirectory:YES];
    
    NSError * error;
    [[NSFileManager defaultManager] createDirectoryAtURL:_temporaryDirectoryURL withIntermediateDirectories:YES attributes:nil error:&error];
    
    if (error) {
        NSLog(@"Failed to create temporary directory: %@", [error localizedDescription]);
    }
    
    return _temporaryDirectoryURL;
}


- (NSURL *)applicationStoresDirectory {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSURL *applicationApplicationSupportDirectory = [[fm URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
    NSURL *URL = [applicationApplicationSupportDirectory URLByAppendingPathComponent:@"Stores"];
    
    if (![fm fileExistsAtPath:[URL path]]) {
        NSError *error = nil;
        [fm createDirectoryAtURL:URL withIntermediateDirectories:YES attributes:nil error:&error];
        
        if (error) {
            NSLog(@"Unable to create directory for data stores.");
            
            return nil;
        }
    }
    
    return URL;
}


- (NSURL *)applicationIncompatibleStoresDirectory {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSURL *URL = [[self applicationStoresDirectory] URLByAppendingPathComponent:@"Incompatible"];
    
    if (![fm fileExistsAtPath:[URL path]]) {
        NSError *error = nil;
        [fm createDirectoryAtURL:URL withIntermediateDirectories:YES attributes:nil error:&error];
        
        if (error) {
            NSLog(@"Unable to create directory for corrupt data stores.");
            
            return nil;
        }
    }
    
    return URL;
}


- (NSString *)nameForIncompatibleStore {
    // Initialize Date Formatter
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    // Configure Date Formatter
    [dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
    [dateFormatter setDateFormat:@"yyyy-MM-dd-HH-mm-ss"];
    
    return [NSString stringWithFormat:@"%@.sqlite", [dateFormatter stringFromDate:[NSDate date]]];
}


#pragma mark - Application's Documents directory
// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


- (BOOL)fileExistForFilename:(NSString *)filename
{
    NSURL * recordingURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:filename];
    
    NSFileManager * fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:recordingURL.path])
        return YES;
    else {
        return NO;
    }
}


@end
