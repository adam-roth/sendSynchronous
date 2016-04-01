//
//  NSURLSession+NSUrlSession_SynchronousRequest.m
//
//  Created by aroth on 1/04/2016.
//  Copyright © 2016 aroth. All rights reserved.
//
//  Inspired by:  http://stackoverflow.com/questions/21198404/nsurlsession-with-nsblockoperation-and-queues

#import "NSURLSession+SynchronousRequest.h"

@interface InsecureSessionDelegate : NSObject <NSURLSessionDelegate>
+ (void) setAllowAnySSLCert:(BOOL)allow;
- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler;
@end

@implementation InsecureSessionDelegate

static BOOL allowAnySSL = NO;

+ (void) setAllowAnySSLCert:(BOOL)allow {
    if (allow) {
        NSLog(@"WARN:  Allowing connections to invalid SSL certificates is a security risk, and should never be enabled in a production application!");
    }
    allowAnySSL = allow;
}

- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler {
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust] && allowAnySSL) {
        NSURLCredential* credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
        completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
    }
}

@end

@implementation NSURLSession (SynchronousRequest)

+ (void) setAllowAnySSLCert:(BOOL)allow {
    [InsecureSessionDelegate setAllowAnySSLCert:allow];
}

+ (NSData*) sendSynchronousRequest:(NSURLRequest*)request returningResponse:(NSURLResponse**)response error:(NSError**)error {
    NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession* session = [NSURLSession sessionWithConfiguration:config delegate:[[InsecureSessionDelegate alloc] init] delegateQueue:nil];
    
    return [self sendSynchronousRequest:request inSession:session returningResponse:response error:error];
}

+ (NSData*) sendSynchronousRequest:(NSURLRequest*)request inSession:(NSURLSession*)session returningResponse:(NSURLResponse**)response error:(NSError**)error {
    if ([NSThread isMainThread]) {
        //do not allow calls from main
        NSLog(@"ERROR:  Synchronous I/O should never be performed on the main thread!  Please consider delegating your synchronous API requests to a background thread/queue, or use asynchronous I/O instead.  The offending call originated from:\n%@",
              [NSThread callStackSymbols]);
        
        NSError* errMessage = [[NSError alloc] initWithDomain:@"MAIN_THREAD_SYNC_ID" code:-0x31337 userInfo:@{NSLocalizedDescriptionKey: @"'sendSynchronousRequest' cannot be called from the main thread."}];
        *error = errMessage;
        
        return nil;
    }
    
    //fields for capturing the returned results
    __block NSData* retData = nil;
    __block NSURLResponse* retResponse = nil;
    __block NSError* retError = nil;
    
    //fire off request
    dispatch_semaphore_t lock = dispatch_semaphore_create(0);
    NSURLSessionTask* task = [session dataTaskWithRequest:request completionHandler:^(NSData* data, NSURLResponse* response, NSError* error) {
        retData = data;
        retResponse = response;
        retError = error;
        
        dispatch_semaphore_signal(lock);
    }];
    [task resume];
    
    //wait for request to complete
    dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
    
    //write outputs, if present
    if (retResponse) {
        *response = retResponse;
    }
    if (retError) {
        *error = retError;
    }
    
    //return the data
    return retData;
}

+ (NSData*) sendSynchronousRequestToUrlFromString:(NSString*)urlString returningResponse:(NSURLResponse**)response error:(NSError**)error {
    NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession* session = [NSURLSession sessionWithConfiguration:config delegate:[[InsecureSessionDelegate alloc] init] delegateQueue:nil];
    
    return [self sendSynchronousRequestToUrlFromString:urlString inSession:session returningResponse:response error:error];
}

+ (NSData*) sendSynchronousRequestToUrlFromString:(NSString*)urlString inSession:(NSURLSession*)session returningResponse:(NSURLResponse**)response error:(NSError**)error {
    return [self sendSynchronousRequestToUrl:[NSURL URLWithString:urlString] inSession:session returningResponse:response error:error];
}

+ (NSData*) sendSynchronousRequestToUrl:(NSURL*)url returningResponse:(NSURLResponse**)response error:(NSError**)error {
    NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession* session = [NSURLSession sessionWithConfiguration:config delegate:[[InsecureSessionDelegate alloc] init] delegateQueue:nil];
    
    return [self sendSynchronousRequestToUrl:url inSession:session returningResponse:response error:error];
}

+ (NSData*) sendSynchronousRequestToUrl:(NSURL*)url inSession:(NSURLSession*)session returningResponse:(NSURLResponse**)response error:(NSError**)error {
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    return [self sendSynchronousRequest:request inSession:session returningResponse:response error:error];
}

@end
