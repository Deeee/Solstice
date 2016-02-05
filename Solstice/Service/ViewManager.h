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
@class ContactObject;
@interface ViewManager : NSObject
@property MasterViewController *masterView;
@property DetailViewController *detailView;
+(ViewManager *) sharedViewManager;
- (void) reloadMasterViewTable;
- (void) reExtractFavoriteOnTappingFavorite;

- (void) syncContacts;
- (void) fetchContacts;
- (void) fetchContactsDetailsOnContact:(ContactObject *)contact;

- (void) setViewsMaster:(MasterViewController *) master DetailView:(DetailViewController*) detail;
@end
