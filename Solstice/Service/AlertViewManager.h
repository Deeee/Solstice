//
//  AlertViewManager.h
//  Solstice
//
//  Created by Liu Di on 2/4/16.
//  Copyright © 2016 Di Liu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <TSMessage.h>
@interface AlertViewManager : NSObject
@property id bindedView;
+ (AlertViewManager *)sharedAlertViewManager;
- (void) bindOnView:(UIView *)view;
- (void) showNetworkErrorAlertEndless;
- (void) showNetworkErrorAlertTemporary;
- (void) showNetworkReconnectAlert;
- (void) showCustomSuccessAlertWithTitle:(NSString *) title subtitle:(NSString *)subTitle;
- (void) showCustomFailAlertWithTitle:(NSString *) title subtitle:(NSString *)subTitle;
- (void) showCustomMessageAlertWithTitleEndless:(NSString *)title subtitle:(NSString *)subTitle;
- (void) showCustomWarningAlertWithTitleTemporary:(NSString *)title subtitle:(NSString *)subTitle;
@end
