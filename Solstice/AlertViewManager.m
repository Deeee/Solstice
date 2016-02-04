//
//  AlertViewManager.m
//  Solstice
//
//  Created by Liu Di on 2/4/16.
//  Copyright © 2016 Di Liu. All rights reserved.
//

#import "AlertViewManager.h"
#import "ViewManager.h"
#import "MasterViewController.h"

@implementation AlertViewManager
+ (AlertViewManager *) sharedAlertViewManager {
    // Create a singleton.
    static dispatch_once_t once;
    static AlertViewManager *alertViewManager;
    dispatch_once(&once, ^ { alertViewManager = [[AlertViewManager alloc] init]; });
    return alertViewManager;
}

+ (void) dismissAllAlertViews {
    [TSMessage dismissActiveNotification];
}

- (void) bindOnView:(UIViewController *)viewController {
    self.bindedView = viewController;
}

- (void) showNetworkErrorAlertEndless {
    if ([TSMessage isNotificationActive]) {
        [TSMessage dismissActiveNotificationWithCompletion:^ {
            [TSMessage showNotificationInViewController:[ViewManager sharedViewManager].masterView title:@"Network Error" subtitle:nil type:TSMessageNotificationTypeError duration:TSMessageNotificationDurationEndless];
        }];
    }
    else {
        [TSMessage showNotificationInViewController:[ViewManager sharedViewManager].masterView title:@"Network Error" subtitle:nil type:TSMessageNotificationTypeError duration:TSMessageNotificationDurationEndless];
    }
    
    
}

- (void) showNetworkErrorAlertTemporary {
    if ([TSMessage isNotificationActive]) {
        [TSMessage dismissActiveNotificationWithCompletion:^ {
            [TSMessage showNotificationInViewController:[ViewManager sharedViewManager].masterView title:@"Network Error" subtitle:nil type:TSMessageNotificationTypeError duration:TSMessageNotificationDurationAutomatic];
        }];
    }
    else {
        [TSMessage showNotificationInViewController:[ViewManager sharedViewManager].masterView title:@"Network Error" subtitle:nil type:TSMessageNotificationTypeError duration:TSMessageNotificationDurationAutomatic];
    }
    
    
}

- (void) showNetworkReconnectAlert {
    //    [TSMessage dismissActiveNotification];
    if ([TSMessage isNotificationActive]) {
        [TSMessage dismissActiveNotificationWithCompletion:^ {
            [TSMessage showNotificationWithTitle:@"Connection Success"
                                        subtitle:@"Connection has been restored"
                                            type:TSMessageNotificationTypeSuccess];
        }];
    }
    else {
        [TSMessage showNotificationWithTitle:@"Connection Success"
                                    subtitle:@"Connection has been restored"
                                        type:TSMessageNotificationTypeSuccess];
    }
    
    
}


- (void) showCustomSuccessAlertWithTitle:(NSString *)title subtitle:(NSString *)subTitle {
    if ([TSMessage isNotificationActive]) {
        [TSMessage dismissActiveNotificationWithCompletion:^ {
            [TSMessage showNotificationWithTitle:title
                                        subtitle:subTitle
                                            type:TSMessageNotificationTypeSuccess];
        }];
    }
    else {
        [TSMessage showNotificationWithTitle:title
                                    subtitle:subTitle
                                        type:TSMessageNotificationTypeSuccess];
    }
    
    
}

- (void) showCustomFailAlertWithTitle:(NSString *)title subtitle:(NSString *)subTitle {
    if ([TSMessage isNotificationActive]) {
        [TSMessage dismissActiveNotificationWithCompletion:^ {
            [TSMessage showNotificationInViewController:[ViewManager sharedViewManager].masterView title:title subtitle:nil type:TSMessageNotificationTypeError duration:TSMessageNotificationDurationAutomatic];
        }];
    }
    else {
        [TSMessage showNotificationInViewController:[ViewManager sharedViewManager].masterView title:title subtitle:nil type:TSMessageNotificationTypeError duration:TSMessageNotificationDurationAutomatic];
    }
    
}

- (void) showCustomWarningAlertWithTitleTemporary:(NSString *)title subtitle:(NSString *)subTitle {
    if ([TSMessage isNotificationActive]) {
        [TSMessage dismissActiveNotificationWithCompletion:^ {
            [TSMessage showNotificationInViewController:[ViewManager sharedViewManager].masterView title:title subtitle:subTitle type:TSMessageNotificationTypeWarning duration:TSMessageNotificationDurationAutomatic];
        }];
    }
    else {
        [TSMessage showNotificationInViewController:[ViewManager sharedViewManager].masterView title:title subtitle:subTitle type:TSMessageNotificationTypeWarning duration:TSMessageNotificationDurationAutomatic];
    }
    
    
    
}

- (void) showCustomMessageAlertWithTitleEndless:(NSString *)title subtitle:(NSString *)subTitle {
    if([TSMessage isNotificationActive]) {
        [TSMessage dismissActiveNotificationWithCompletion:^ {
            [TSMessage showNotificationInViewController:[ViewManager sharedViewManager].masterView title:title subtitle:subTitle type:TSMessageNotificationTypeMessage duration:TSMessageNotificationDurationEndless];
        }];
    }
    else {
        [TSMessage showNotificationInViewController:[ViewManager sharedViewManager].masterView title:title subtitle:subTitle type:TSMessageNotificationTypeMessage duration:TSMessageNotificationDurationEndless];
    }
    
    
}

@end
