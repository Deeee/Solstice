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
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    [self setupSearchController];
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    self.navigationItem.rightBarButtonItem = addButton;
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    [[HudManager sharedHudManager] bindOnView:self.view];
    [[ViewManager sharedViewManager] setViewsMaster:self DetailView:self.detailViewController];
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

- (void)viewWillAppear:(BOOL)animated {
    self.clearsSelectionOnViewWillAppear = self.splitViewController.isCollapsed;
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)insertNewObject:(id)sender {
    if (!self.contactArray) {
        self.contactArray = [[NSMutableArray alloc] init];
    }
    [self.contactArray insertObject:[ContactObject new] atIndex:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:1];
    [self.contactTable scrollToRowAtIndexPath:path
                                atScrollPosition:UITableViewScrollPositionTop
                                        animated:YES];
    [[ViewManager sharedViewManager] syncContacts];
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        ContactObject *contact;

        if (indexPath.section == 0) {
            contact = self.favoriteArray[indexPath.row];
        }
        else {
            contact = self.contactArray[indexPath.row];
        }
        DetailViewController *controller = (DetailViewController *)[[segue destinationViewController] topViewController];
        [controller setCurContact:contact];
        controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
        controller.navigationItem.leftItemsSupplementBackButton = YES;
        [self.resultSearchController setActive:NO];
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return self.favoriteArray.count;
    }
    else {
        if (self.resultSearchController.active) {
            return self.searchResultArray.count;
        }
        else {
            return self.contactArray.count;
        }
    }
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    return kHeaderTitles[section];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ContactTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CONTACT_CELL_IDENTIFIER];
    ContactObject *curContact;
    
    if (indexPath.section == 0) {
        curContact = [self.favoriteArray objectAtIndex:indexPath.row];
    }
    else {
        if (self.resultSearchController.active) {
            curContact = [_searchResultArray objectAtIndex:indexPath.row];
        }
        else {
            curContact = [self.contactArray objectAtIndex:indexPath.row];
        }
    }
    cell.curContact = curContact;
    [self setTitleLabel:cell.profileNameLabel WithText:curContact.name];
    [self setLabel:cell.profilePhoneLabel WithText:[curContact.homePhone firstObject]];
        NSLog(@"url is %@",curContact.smallImageUrl);
    [cell.profileImageView sd_setImageWithURL:[NSURL URLWithString:curContact.smallImageUrl]
                      placeholderImage:[UIImage imageNamed:@"blackPic.jpg"]];
    cell.profileImageView.layer.borderWidth = kProfileBorderWidth;
    cell.profileImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    cell.profileImageView.layer.cornerRadius = cell.profileImageView.frame.size.width / 2;
    cell.profileImageView.clipsToBounds = YES;
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return NO;
    }
    else {
        return YES;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.contactArray removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [[ViewManager sharedViewManager] syncContacts];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}


#pragma mark - Search Controller

- (void) setupSearchController
{
    
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

    [[ViewManager sharedViewManager] reloadMasterViewTable];
    
    
}


#pragma mark - Convenient methods

- (void) setTitleLabel:(UILabel *)label WithText:(NSString *)text {
    label.textColor = [UIColor blackColor];
    label.font = FONT_Futura_CondenseExtraBold(16);
    label.text = text;
}
- (void) setLabel:(UILabel *)label WithText:(NSString *)text {
    label.textColor = [UIColor blackColor];
    label.font = FONT_Futura_Medium(16);
    label.text = text;
}


@end
