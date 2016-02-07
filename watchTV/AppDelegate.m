//
//  AppDelegate.m
//  watchTV
//
//  Created by Fabio Dela Antonio on 2/7/16.
//  Copyright © 2016 bluenose. All rights reserved.
//

#import "AppDelegate.h"
#import "IRRequest.h"
#import <WatchConnectivity/WatchConnectivity.h>

@interface AppDelegate () <IRRequestDelegate, WCSessionDelegate>
@property (nonatomic, retain) IRRequest * request;

@property (nonatomic, assign) BOOL hasReplyHandler;
@property (nonatomic, copy) void (^replyHandler)(NSDictionary<NSString *, id> *replyMessage);

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    if([WCSession isSupported]) {
        
        WCSession * session = [WCSession defaultSession];
        session.delegate = self;
        [session activateSession];
    }
    
    return YES;
}

- (void)irRequest:(IRRequest *)request didFinishWithSuccess:(BOOL)success {
    
    if(_hasReplyHandler) {
        
        _replyHandler(@{@"success":@(success)});
    }
}

- (void)session:(WCSession *)session didReceiveMessage:(NSDictionary<NSString *,id> *)message replyHandler:(void (^)(NSDictionary<NSString *,id> * _Nonnull))replyHandler {
    
    if(message[@"irCode"]) {
    
        self.replyHandler = replyHandler;
        _hasReplyHandler = YES;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [_request release], _request = nil;
            _request = [[IRRequest irRequestWithCode:[message[@"irCode"] unsignedLongValue] delegate:self] retain];
        });
    }
}

- (void)dealloc {
    
    [_replyHandler release];
    _hasReplyHandler = NO;
    [super dealloc];
}

@end
