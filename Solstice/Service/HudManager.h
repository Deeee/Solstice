//
//  HudManager.h
//  Solstice
//
//  Created by Liu Di on 2/4/16.
//  Copyright © 2016 Di Liu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MBProgressHUD.h>
typedef void (^HudTask)();

@interface HudManager : NSObject

@property NSMutableArray *hudsStack;
+ (instancetype)sharedHudManager;
- (void) showHudWithText:(NSString *) text;
//- (void) hideAllHuds;
- (void) bindOnView:(UIView *) view;
- (void) showHudWithText:(NSString *)text withTask:(HudTask) task;
- (void) popTopHud;
//- (void) hideAllHudsOnStack;

@property UIView *bindedView;
@end
