//
//  SQRLInstaller.h
//  Squirrel
//
//  Created by Alan Rogers on 30/07/2013.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const SQRLInstallerErrorDomain;

extern const NSInteger SQRLInstallerFailedErrorCode;

@interface SQRLInstaller : NSObject

@property (nonatomic, strong) NSURL *targetBundleURL;
@property (nonatomic, strong) NSURL *updateBundleURL;
@property (nonatomic, strong) NSURL *backupURL;

- (id)initWithTargetBundleURL:(NSURL *)targetBundleURL updateBundleURL:(NSURL *)updateBundleURL backupURL:(NSURL *)backupURL;

- (BOOL)installUpdateWithError:(NSError **)errorRef;

@end
