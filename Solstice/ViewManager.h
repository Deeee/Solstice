//
//  ViewManager.h
//  Solstice
//
//  Created by Liu Di on 2/4/16.
//  Copyright © 2016 Di Liu. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MasterViewController;
@class DetailViewController;
@interface ViewManager : NSObject
@property MasterViewController *masterView;
@property DetailViewController *detailView;
+(ViewManager *) sharedViewManager;
- (void) reloadMasterViewOnSuccessfulDownload;
- (void) reloadMasterViewOnFailedDownload;
- (void) fetchContacts;
- (void) setViewsMaster:(MasterViewController *) master DetailView:(DetailViewController*) detail;
@end
