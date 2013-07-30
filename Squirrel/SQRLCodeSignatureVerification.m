//
//  SQRLCodeSignatureVerfication.m
//  Squirrel
//
//  Created by Alan Rogers on 26/07/2013.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import "SQRLCodeSignatureVerification.h"
#import <Security/Security.h>

NSSTRING_CONST(SQRLCodeSignatureVerificationErrorDomain);

const NSInteger SQRLCodeSignatureVerificationErrorCodeSigning = 1;

@implementation SQRLCodeSignatureVerification

+ (BOOL)verifyCodeSignatureOfBundle:(NSBundle *)bundle error:(NSError **)error {
    __block SecStaticCodeRef staticCode = NULL;
    @onExit {
        if (staticCode != NULL) CFRelease(staticCode);
    };
    
    OSStatus result = SecStaticCodeCreateWithPath((__bridge CFURLRef)bundle.executableURL, kSecCSDefaultFlags, &staticCode);
    if (result != noErr) {
        if (error != NULL) {
            *error = [self codeSigningErrorWithDescription:[NSString stringWithFormat:NSLocalizedString(@"Failed to get static code for bundle %@", nil), bundle.bundleURL.absoluteString] securityResult:result];
        }
        return NO;
    }
    
    CFErrorRef errorRef = NULL;
    result = SecStaticCodeCheckValidityWithErrors(staticCode, kSecCSCheckAllArchitectures | kSecCSCheckNestedCode, NULL, &errorRef);
    if (result == noErr) {
        return YES;
    } else {
        NSMutableDictionary *userInfo = [@{
            NSLocalizedDescriptionKey: [NSString stringWithFormat:NSLocalizedString(@"Code signature at URL %@ did not pass validation", nil), bundle.bundleURL.absoluteString],
        } mutableCopy];
        
        if (errorRef != NULL) {
            userInfo[NSUnderlyingErrorKey] = CFBridgingRelease(errorRef);
        }
        
        if (error != NULL) {
            *error = [NSError errorWithDomain:SQRLCodeSignatureVerificationErrorDomain code:SQRLCodeSignatureVerificationErrorCodeSigning userInfo:userInfo];
        }
    }
    return NO;
}

+ (NSError *)codeSigningErrorWithDescription:(NSString *)description securityResult:(OSStatus)result {
	NSParameterAssert(description != nil);
    
	NSMutableDictionary *userInfo = [@{
        NSLocalizedDescriptionKey: description,
    } mutableCopy];
    
	NSString *failureReason = CFBridgingRelease(SecCopyErrorMessageString(result, NULL));
	if (failureReason != nil) {
		userInfo[NSLocalizedFailureReasonErrorKey] = failureReason;
	}
    
	return [NSError errorWithDomain:SQRLCodeSignatureVerificationErrorDomain code:SQRLCodeSignatureVerificationErrorCodeSigning userInfo:userInfo];
}


@end
