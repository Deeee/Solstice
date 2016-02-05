//
//  DetailViewController.h
//  Solstice
//
//  Created by Liu Di on 2/4/16.
//  Copyright © 2016 Di Liu. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ContactObject;
@interface DetailViewController : UIViewController<UITableViewDelegate, UITableViewDataSource,UITextFieldDelegate>

@property (strong, nonatomic) ContactObject * curContact;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *companyTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *companyLabel;
@property (weak, nonatomic) IBOutlet UITableView *detailTable;
@property (weak, nonatomic) IBOutlet UIButton *favorite;

@end

