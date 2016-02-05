//
//  HudManager.m
//  Solstice
//
//  Created by Liu Di on 2/4/16.
//  Copyright © 2016 Di Liu. All rights reserved.
//

#import "HudManager.h"

@implementation HudManager
+ (instancetype) sharedHudManager {
    static dispatch_once_t once;
    static HudManager *hudManager;
    dispatch_once(&once, ^ { hudManager = [[HudManager alloc] init]; });
    return hudManager;
}

- (id) init {
    if (self = [super init]) {
        self.hudsStack = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void) bindOnView:(UIView *) view {
    self.bindedView = view;
}

- (void) popTopHud {
    if ([self.hudsStack count] == 0) {
        NSLog(@"ERROR HuD Stack Has no hud!");
        return;
    }
    MBProgressHUD * topHud = [self.hudsStack lastObject];
    [topHud hide:YES];
    [self.hudsStack removeLastObject];
}

- (void) showHudWithText:(NSString *)text withTask:(HudTask)task {
    UIView *topView = [UIApplication sharedApplication].keyWindow.rootViewController.view;
    MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:topView animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = text;
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        task();
        
        [MBProgressHUD hideHUDForView:topView animated:YES];
    });
    
}

- (void) showHudWithText:(NSString *) text{
    if(text == nil || [text length] == 0) {
        return;
    }
    NSLog(@"showing log with text %@",text);
    NSArray *allHuds = [MBProgressHUD allHUDsForView:self.bindedView];
    if ([allHuds count] != 0) {
        MBProgressHUD *hud = [allHuds objectAtIndex:0];
        hud.labelText = text;
    }
    else {
        MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.bindedView animated:YES];
        hud.mode = MBProgressHUDModeText;
        [hud setDimBackground:YES];
        hud.labelText = text;
        [self.hudsStack addObject:hud];
    }
    
}

- (void) hideAllHudsOnStack {
    for (MBProgressHUD *hud in self.hudsStack) {
        [hud hide:YES];
    }
    [self.hudsStack removeAllObjects];
}

- (void) hideAllHuds {    
    [MBProgressHUD hideAllHUDsForView:self.bindedView animated:YES];
    [self.hudsStack removeAllObjects];
    
}
@end
