//
//  MasterViewController.m
//  Solstice
//
//  Created by Liu Di on 2/4/16.
//  Copyright © 2016 Di Liu. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "ViewManager.h"
#import "Constants.h"
#import "ContactTableViewCell.h"
#import "ContactObject.h"

static NSString * kHeaderTitles[2] = {@"Favorites:", @"Contacts:"};
static double kProfileBorderWidth = 3.0f;
@interface MasterViewController ()

@property NSMutableArray *objects;
@end

@implementation MasterViewController {
     MJRefreshNormalHeader * header;

}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self configureView];
}


- (void)viewWillAppear:(BOOL)animated {
    self.clearsSelectionOnViewWillAppear = self.splitViewController.isCollapsed;
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

/* insert a new contact into table */
- (void)insertNewObject:(id)sender {
    if (!self.contactArray) {
        self.contactArray = [[NSMutableArray alloc] init];
    }
    [self.contactArray insertObject:[ContactObject new] atIndex:0];
    NSIndexPath *indexPath;
    
    /* insert based on search controller's activity */
    if (self.resultSearchController.active) {
        indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    }
    else {
        indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
    }
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    /* scroll to where the row is inserted */
    [self.contactTable scrollToRowAtIndexPath:indexPath
                             atScrollPosition:UITableViewScrollPositionTop
                                     animated:YES];
    [[ViewManager sharedViewManager] syncContacts];
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        ContactObject *contact;
        /* set detail view controller based on search controller's activity */
        if (self.resultSearchController.active) {
            contact = [_searchResultArray objectAtIndex:indexPath.row];
        }
        else {
            if (indexPath.section == 0) {
                contact = [self.favoriteArray objectAtIndex:indexPath.row];
            }
            else {
                contact = [self.contactArray objectAtIndex:indexPath.row];
            }
        }
        
        /* instanciate detail view controller */
        DetailViewController *controller = (DetailViewController *)[[segue destinationViewController] topViewController];
        [controller setCurContact:contact];
        controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
        controller.navigationItem.leftItemsSupplementBackButton = YES;
        [self.resultSearchController setActive:NO];
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.resultSearchController.active) {
        return 1;
    }
    else {
        return 2;
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.resultSearchController.active) {
        return self.searchResultArray.count;
    }
    else {
        if (section == 0) {
            return self.favoriteArray.count;
        }
        else {
            return self.contactArray.count;
        }
    }
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (self.resultSearchController.active) {
        return kHeaderTitles[1];
    }
    else {
        return kHeaderTitles[section];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ContactTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CONTACT_CELL_IDENTIFIER];
    ContactObject *curContact;
    
    /* set cell based on search controller's activity */
    if (self.resultSearchController.active) {
        curContact = [_searchResultArray objectAtIndex:indexPath.row];
    }
    else {
        if (indexPath.section == 0) {
            curContact = [self.favoriteArray objectAtIndex:indexPath.row];
        }
        else {
            curContact = [self.contactArray objectAtIndex:indexPath.row];
        }
    }
    cell.curContact = curContact;
    
    /* set text on cell */
    [[ViewManager sharedViewManager] setTitleLabel:cell.profileNameLabel WithText:curContact.name];
    [[ViewManager sharedViewManager] setLabel:cell.profilePhoneLabel WithText:[curContact.homePhone firstObject]];
    
    /* set profile image on cell */
    [cell.profileImageView sd_setImageWithURL:[NSURL URLWithString:curContact.smallImageUrl]
                             placeholderImage:[UIImage imageNamed:@"blackPic.jpg"]];
    /* configure profile image */
    cell.profileImageView.layer.borderWidth = kProfileBorderWidth;
    cell.profileImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    cell.profileImageView.layer.cornerRadius = cell.profileImageView.frame.size.width / 2;
    cell.profileImageView.clipsToBounds = YES;
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.resultSearchController.active) {
        return YES;
    }
    else {
        if (indexPath.section == 0) {
            return NO;
        }
        else {
            return YES;
        }
    }
    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        /* edit table based on search controller's activity */
        if (self.resultSearchController.active) {
            ContactObject *contactObj = [self.searchResultArray objectAtIndex:indexPath.row];
            
            [self.contactArray removeObject:contactObj];
            
            [self.searchResultArray removeObjectAtIndex:indexPath.row];
        }
        else {
            if (indexPath.section == 0) {
                return;
            }
            else {
                [self.contactArray removeObjectAtIndex:indexPath.row];
            }
        }
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        /* sync with local after editing */
        [[ViewManager sharedViewManager] reExtractFavoriteOnTappingFavorite];
        [[ViewManager sharedViewManager] syncContacts];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}


#pragma mark - Search Controller

- (void) setupSearchController
{
    /* init and setup search controller */
    self.resultSearchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.resultSearchController.searchResultsUpdater = self;
    self.resultSearchController.dimsBackgroundDuringPresentation = false;
    self.resultSearchController.searchBar.barTintColor = [UIColor whiteColor];
    self.resultSearchController.searchBar.tintColor = [UIColor redColor];
    [self.resultSearchController.searchBar sizeToFit];
    self.contactTable.tableHeaderView = self.resultSearchController.searchBar;
    
}


- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    // update the filtered array based on the search text
    NSString *searchText = searchController.searchBar.text;
    NSMutableArray *searchResults = [self.contactArray mutableCopy];
    
    // strip out all the leading and trailing spaces
    NSString *strippedString = [searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    // break up the search terms (separated by spaces)
    NSArray *searchItems = nil;
    if (strippedString.length > 0) {
        searchItems = [strippedString componentsSeparatedByString:@" "];
    }
    
    NSMutableArray *andMatchPredicates = [NSMutableArray array];
    
    for (NSString *searchString in searchItems) {
        NSMutableArray *searchItemsPredicate = [NSMutableArray array];
        
        // name field matching
        NSExpression *lhs = [NSExpression expressionForKeyPath:@"name"];
        NSExpression *rhs = [NSExpression expressionForConstantValue:searchString];
        NSPredicate *finalPredicate = [NSComparisonPredicate
                                       predicateWithLeftExpression:lhs
                                       rightExpression:rhs
                                       modifier:NSDirectPredicateModifier
                                       type:NSContainsPredicateOperatorType
                                       options:NSCaseInsensitivePredicateOption];
        [searchItemsPredicate addObject:finalPredicate];
        
        // phone field matching
        lhs = [NSExpression expressionForKeyPath:@"homePhone"];
        finalPredicate = [NSComparisonPredicate
                          predicateWithLeftExpression:lhs
                          rightExpression:rhs
                          modifier:NSDirectPredicateModifier
                          type:NSContainsPredicateOperatorType
                          options:NSCaseInsensitivePredicateOption];
        [searchItemsPredicate addObject:finalPredicate];
        // at this OR predicate to our master AND predicate
        NSCompoundPredicate *orMatchPredicates = [NSCompoundPredicate orPredicateWithSubpredicates:searchItemsPredicate];
        [andMatchPredicates addObject:orMatchPredicates];
        
    }
    
    NSCompoundPredicate *finalCompoundPredicate =
    [NSCompoundPredicate andPredicateWithSubpredicates:andMatchPredicates];
    searchResults = [[searchResults filteredArrayUsingPredicate:finalCompoundPredicate] mutableCopy];
    _searchResultArray = [NSMutableArray arrayWithArray:searchResults];
    
    // reload view after result is fetched
    [[ViewManager sharedViewManager] reloadMasterViewTable];
    
    
}

#pragma mark - Pull to Refresh Controller

- (void) setPullToRefreshForMasterView {
    /* pull to refresh header setup */
    self.contactTable.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        
    }];
    header = [MJRefreshNormalHeader headerWithRefreshingTarget:[ViewManager sharedViewManager] refreshingAction:@selector(fetchContacts)];
    
    [header setTitle:@"Pull to refresh" forState:MJRefreshStateIdle];
    [header setTitle:@"Release to refresh" forState:MJRefreshStatePulling];
    [header setTitle:@"Refreshing" forState:MJRefreshStateRefreshing];
    
    /* set font */
    header.stateLabel.font = FONT_Futura_Medium(14);
    header.lastUpdatedTimeLabel.font = FONT_Futura_Medium(14);
    
    /* set color */
    header.stateLabel.textColor = self.view.tintColor;
    header.lastUpdatedTimeLabel.textColor = self.view.tintColor;
    
    header.lastUpdatedTimeText =  ^(NSDate * date) {
        NSString *text;
        if (date) {
            /* get date */
            NSCalendar *calendar = [NSCalendar currentCalendar];
            NSUInteger unitFlags = NSCalendarUnitYear| NSCalendarUnitMonth | NSCalendarUnitDay |NSCalendarUnitHour |NSCalendarUnitMinute;
            NSDateComponents *cmp1 = [calendar components:unitFlags fromDate:date];
            NSDateComponents *cmp2 = [calendar components:unitFlags fromDate:[NSDate date]];
            
            /* format date */
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            BOOL isToday = false;
            if ([cmp1 day] == [cmp2 day]) { /* if today */
                isToday = true;
                formatter.dateFormat = @"HH:mm";
            } else if ([cmp1 year] == [cmp2 year]) { /* if this year */
                formatter.dateFormat = @"MM-dd HH:mm";
            } else {
                formatter.dateFormat = @"yyyy-MM-dd HH:mm";
            }
            NSString *time = [formatter stringFromDate:date];
            NSLog(@"date time is %@",time);
            /* display dates */
            if (isToday) {
                text = [NSString stringWithFormat:@"%@: %@ %@",@"Last Updated",@"Today", time];
            }
            else {
                text = [NSString stringWithFormat:@"%@: %@",@"Last Updated", time];
            }
        } else {
            text = [NSString stringWithFormat:@"%@: %@",@"Last Updated", @"No Record"];
        }
        
        return text;
    };
    self.contactTable.mj_header = header;
}

#pragma -mark view configuration 
- (void)configureView {
    /* navigation bar setup */
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    self.navigationItem.rightBarButtonItem = addButton;
    
    /* setup search controller */
    [self setupSearchController];
    /* setup refresh header */
    [self setPullToRefreshForMasterView];
    /* create blank view for table background */
    self.contactTable.backgroundView = [[UIView alloc] init];
    
    
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    /* view manager setup */
    [[HudManager sharedHudManager] bindOnView:self.view];
    [[ViewManager sharedViewManager] setViewsMaster:self DetailView:self.detailViewController];
    
    /* get cache data */
    NSMutableArray *contactsArray = [JNKeychain loadValueForKey:KEY_FOR_CONTACTS];
    if (contactsArray == nil) {
        [[ViewManager sharedViewManager] fetchContacts];
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [[ViewManager sharedViewManager] reExtractFavoriteOnTappingFavorite];
        });
        
    }
    else {
        self.contactArray = contactsArray;
        [[ViewManager sharedViewManager] reExtractFavoriteOnTappingFavorite];
        
    }
}


@end
