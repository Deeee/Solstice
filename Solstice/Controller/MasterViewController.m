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
@interface MasterViewController ()

@property NSMutableArray *objects;
@end

@implementation MasterViewController {
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    self.navigationItem.rightBarButtonItem = addButton;
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    [[HudManager sharedHudManager] bindOnView:self.view];
    [[ViewManager sharedViewManager] setViewsMaster:self DetailView:self.detailViewController];
    [[ViewManager sharedViewManager] fetchContacts];
}

- (void)viewWillAppear:(BOOL)animated {
    self.clearsSelectionOnViewWillAppear = self.splitViewController.isCollapsed;
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)insertNewObject:(id)sender {
    if (!self.objects) {
        self.objects = [[NSMutableArray alloc] init];
    }
    [self.objects insertObject:[NSDate date] atIndex:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSDate *object = self.objects[indexPath.row];
        DetailViewController *controller = (DetailViewController *)[[segue destinationViewController] topViewController];
        [controller setDetailItem:object];
        controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
        controller.navigationItem.leftItemsSupplementBackButton = YES;
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"rows :%ld",self.contactArray.count);
    return self.contactArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ContactTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CONTACT_CELL_IDENTIFIER];
    
    ContactObject *curContact = [self.contactArray objectAtIndex:indexPath.row];
    cell.curContact = curContact;
    cell.profileNameLabel.text = curContact.name;
    cell.profilePhoneLabel.text = curContact.homePhone;
    cell.profileImageView.image = nil; // or cell.poster.image = [UIImage imageNamed:@"placeholder.png"];
    
//    NSURL *url = [NSURL URLWithString:curContact.smallImageUrl];
    NSLog(@"url is %@",curContact.smallImageUrl);
    [cell.profileImageView sd_setImageWithURL:[NSURL URLWithString:curContact.smallImageUrl]
                      placeholderImage:[UIImage imageNamed:@"blackPic.jpg"]];
//    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//        if (data) {
//            UIImage *image = [UIImage imageWithData:data];
//            if (image) {
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    ContactTableViewCell *updateCell = (id)[tableView cellForRowAtIndexPath:indexPath];
//                    if (updateCell)
//                        updateCell.profileImageView.image = image;
//                });
//            }
//        }
//    }];
//    [task resume];

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.objects removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

@end
