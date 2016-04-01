//
//  NSURLSession+NSUrlSession_SynchronousRequest.h
//
//  Created by aroth on 1/04/2016.
//  Copyright © 2016 aroth. All rights reserved.
//
//  Inspired by:  http://stackoverflow.com/questions/21198404/nsurlsession-with-nsblockoperation-and-queues

#import <Foundation/Foundation.h>

@interface NSURLSession (SynchronousRequest)

+ (NSData*) sendSynchronousRequest:(NSURLRequest*)request returningResponse:(NSURLResponse**)response error:(NSError**)error;
+ (NSData*) sendSynchronousRequest:(NSURLRequest*)request inSession:(NSURLSession*)session returningResponse:(NSURLResponse**)response error:(NSError**)error;
+ (NSData*) sendSynchronousRequestToUrlFromString:(NSString*)urlString returningResponse:(NSURLResponse**)response error:(NSError**)error;
+ (NSData*) sendSynchronousRequestToUrlFromString:(NSString*)urlString inSession:(NSURLSession*)session returningResponse:(NSURLResponse**)response error:(NSError**)error;
+ (NSData*) sendSynchronousRequestToUrl:(NSURL*)url returningResponse:(NSURLResponse**)response error:(NSError**)error;
+ (NSData*) sendSynchronousRequestToUrl:(NSURL*)url inSession:(NSURLSession*)session returningResponse:(NSURLResponse**)response error:(NSError**)error;
+ (void) setAllowAnySSLCert:(BOOL)allow;

@end
