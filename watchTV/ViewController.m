//
//  ViewController.m
//  watchTV
//
//  Created by Fabio Dela Antonio on 2/7/16.
//  Copyright © 2016 bluenose. All rights reserved.
//

#import "ViewController.h"
#import "IRRequest.h"

@interface ViewController () <IRRequestDelegate>

@property (retain, nonatomic) IBOutlet UIView * loadingView;
@property (nonatomic, retain) IRRequest * request;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)setLoading:(BOOL)loading {
    
    self.loadingView.hidden = !loading;
}

- (IBAction)powerAction:(id)sender {
    
    [self sendCode:3772793023];
}

- (IBAction)chUpAction:(id)sender {
    
    [self sendCode:3772795063];
}

- (IBAction)chDownAction:(id)sender {
    
    [self sendCode:3772778743];
}

- (IBAction)volumeUpAction:(id)sender {
    
    [self sendCode:3772833823];
}

- (IBAction)volumeDownAction:(id)sender {
    
    [self sendCode:3772829743];
}

- (void)sendCode:(unsigned long)code {
    
    [_request release], _request = nil;
    _request = [[IRRequest irRequestWithCode:code delegate:self] retain];
    [self setLoading:YES];
}

- (void)irRequest:(IRRequest *)request didFinishWithSuccess:(BOOL)success {
    
    if(!success) {
        
        [[[[UIAlertView alloc] initWithTitle:@"Error!" message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease] show];
    }
    
    [self setLoading:NO];
}

- (void)dealloc {
    [_request release], _request = nil;
    [_loadingView release], _loadingView = nil;
    [super dealloc];
}

@end
