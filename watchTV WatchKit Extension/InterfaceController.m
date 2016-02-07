//
//  InterfaceController.m
//  watchTV WatchKit Extension
//
//  Created by Fabio Dela Antonio on 2/7/16.
//  Copyright © 2016 bluenose. All rights reserved.
//

#import "InterfaceController.h"
#import <WatchConnectivity/WatchConnectivity.h>

@interface InterfaceController() <WCSessionDelegate>
@property (retain, nonatomic) IBOutlet WKInterfaceImage * activityIndicator;
@property (retain, nonatomic) IBOutlet WKInterfaceGroup * buttonsGroup;
@property (nonatomic, assign) BOOL loading;
@end

@implementation InterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];

    if([WCSession isSupported]) {
        
        WCSession * session = [WCSession defaultSession];
        session.delegate = self;
        [session activateSession];
    }
}

- (void)setLoading:(BOOL)loading {
    
    if(_loading != loading) {
        
        _loading = loading;
        
        if(loading) {
            
            [self.buttonsGroup setHidden:YES];
            [self.activityIndicator setHidden:NO];
            [self.activityIndicator setImageNamed:@"ai"];
            [self.activityIndicator startAnimatingWithImagesInRange:NSMakeRange(0, 4) duration:0.6f repeatCount:0];
        }
        
        else {
            
            [self.activityIndicator stopAnimating];
            [self.activityIndicator setHidden:YES];
            [self.buttonsGroup setHidden:NO];
        }
    }
}

- (void)willActivate {
    
    [super willActivate];
    [self setLoading:NO];
}

- (IBAction)powerAction {
    
    [self sendCode:3772793023];
}

- (IBAction)chUpAction {
    
    [self sendCode:3772795063];
}

- (IBAction)chDownAction {

    [self sendCode:3772778743];
}

- (IBAction)volumeUpAction {
    
    [self sendCode:3772833823];
}

- (IBAction)volumeDownAction {
    
    [self sendCode:3772829743];
}

- (void)sendCode:(unsigned long)code {
    
    [self setLoading:YES];
    
    [[WCSession defaultSession] sendMessage:@{@"irCode":@(code)} replyHandler:^(NSDictionary<NSString *,id> * _Nonnull replyMessage) {
        
        [self setLoading:NO];
        
        if(![replyMessage[@"success"] boolValue]) {
            
            [self errorAlert];
        }
        
    } errorHandler:^(NSError * _Nonnull error) {
        
        [self setLoading:NO];
        [self errorAlert];
    }];
}

- (void)errorAlert {
    
    [self presentAlertControllerWithTitle:@"Error" message:@"" preferredStyle:WKAlertControllerStyleAlert actions:@[[WKAlertAction actionWithTitle:@"OK" style:WKAlertActionStyleCancel handler:^{
    }]]];
}

- (void)didDeactivate {
    [super didDeactivate];
}

- (void)dealloc {
    [_activityIndicator release];
    [_buttonsGroup release];
    [super dealloc];
}
@end



