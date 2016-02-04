//
//  ViewManager.m
//  Solstice
//
//  Created by Liu Di on 2/4/16.
//  Copyright © 2016 Di Liu. All rights reserved.
//

#import "ViewManager.h"
#import "MasterViewController.h"
#import "DetailViewController.h"
#import "Constants.h"
#import "ContactObject.h"
@implementation ViewManager
@synthesize masterView;
@synthesize detailView;
+ (ViewManager *) sharedViewManager {
    // Create a singleton.
    static dispatch_once_t once;
    static ViewManager *viewManager;
    dispatch_once(&once, ^ { viewManager = [[ViewManager alloc] init]; });
    return viewManager;
}
- (id) init {
    if (self = [super init]) {

    }
    return self;
}
- (void) setViewsMaster:(MasterViewController *) master DetailView:(DetailViewController*) detail {
    masterView = master;
    detailView = detail;
}
- (void) reloadMasterViewOnSuccessfulDownload {
    NSLog(@"reloading");
    [masterView.tableView reloadData];

}
- (void) fetchContacts {
    NSURL *url = [NSURL URLWithString:DOWNLOAD_URL];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:@"GET"];
    [request setTimeoutInterval:120];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@",responseObject);
        masterView.contactArray = [ContactObject parseContactJson:responseObject];
        [masterView.tableView reloadData];
        [[HudManager sharedHudManager] popTopHud];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error: %@",[error localizedDescription]);
        [[HudManager sharedHudManager] popTopHud];
        [[AlertViewManager sharedAlertViewManager] showNetworkErrorAlertTemporary];
    }];
    [[HudManager sharedHudManager] showHudWithText:@"正在载入菜单..."];
    [operation start];
}
@end
