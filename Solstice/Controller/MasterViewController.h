//
//  MasterViewController.h
//  Solstice
//
//  Created by Liu Di on 2/4/16.
//  Copyright © 2016 Di Liu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailViewController;
@class MJRefreshNormalHeader;
@interface MasterViewController : UITableViewController <UISearchResultsUpdating, UITableViewDelegate, UITableViewDataSource,UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITableView *contactTable;
@property (strong, nonatomic) DetailViewController *detailViewController;
@property NSMutableArray *contactArray;
@property NSMutableArray *searchResultArray;
@property NSMutableArray *favoriteArray;
@property (strong, nonatomic) UISearchController *resultSearchController;

@end

