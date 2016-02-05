//
//  DetailViewController.m
//  Solstice
//
//  Created by Liu Di on 2/4/16.
//  Copyright © 2016 Di Liu. All rights reserved.
//

#import "DetailViewController.h"
#import "DetailTableViewCell.h"
#import "ContactObject.h"
#import "Constants.h"
#import "ViewManager.h"
static NSString * kHeaderTitles[4] = {@"Phone:", @"Address:", @"Birthday:",@"Email:"};
static NSString * longPressPrompt = @"Long press to edit";
static double kProfileBorderWidth = 3.0f;
static double kProfileCornerRadius = 10.0f;

static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 260;
static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 162;
@interface DetailViewController ()

@end

@implementation DetailViewController {
    CGFloat animatedDistance;
    UITextField *tempTextField;
    /* 1 is name 2 is company 3 is cell textfield */
    int textfieldFlag;
}
@synthesize curContact;
#pragma mark - Managing the detail item

- (void)setDetailItem:(ContactObject *)newContact {
    if (curContact != newContact) {
        curContact = newContact;
        
        // Update the view.
        [self configureView];
    }
}

- (void)configureView {
    // Update the user interface for the detail item.
    if (self.curContact) {
        self.nameLabel.tag = 11;
        self.companyLabel.tag = 12;
        [self setLabel:self.nameLabel WithText:self.curContact.name];
        [self setLabel:self.companyLabel WithText:self.curContact.company];

        [self.profileImageView sd_setImageWithURL:[NSURL URLWithString:self.curContact.largeImageUrl]
                                 placeholderImage:[UIImage imageNamed:@"blackPic.jpg"]];
        [self.favorite.titleLabel setFont:FONT_BS_Awesome(20)];
        [self.favorite setTintColor:self.view.tintColor];
        [self.favorite addTarget:self action:@selector(tapOnFavorite:) forControlEvents:UIControlEventTouchUpInside];
        if (curContact.isFavorite) {
            [self.favorite setTitle:[NSString stringWithFormat:@"%@",@"fa-star".bs_awesomeIconRepresentation] forState:UIControlStateNormal];
        }
        else {
            [self.favorite setTitle:[NSString stringWithFormat:@"%@",@"fa-star-o".bs_awesomeIconRepresentation] forState:UIControlStateNormal];
        }
        
    }
    [self setTitleLabel:self.nameTitleLabel WithText:@"Name"];
    [self setTitleLabel:self.companyTitleLabel WithText:@"Company"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.detailTable.dataSource = self;
    self.detailTable.delegate = self;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFieldDidEndEditing) name:UIKeyboardWillHideNotification object:nil];
    
    self.profileImageView.layer.borderWidth = kProfileBorderWidth;
    self.profileImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.profileImageView.layer.cornerRadius = kProfileCornerRadius;
    self.profileImageView.clipsToBounds = YES;
    // Do any additional setup after loading the view, typically from a nib.
    [self configureView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return curContact.homePhone.count+curContact.workPhone.count+curContact.mobilePhone.count;
    }
    else if (section == 1) {
        return curContact.homeAddress.count;
    }
    else if (section == 2) {
        return 1;
    }
    else if (section == 3) {
        return curContact.workEmail.count;
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    CGRect frame = tableView.frame;
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 100, 30)];
    [self setTitleLabel:title WithText:kHeaderTitles[section]];
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    [headerView setBackgroundColor:[UIColor whiteColor]];
    [headerView addSubview:title];
    if (section != 2) {
        UIButton *addButton = [[UIButton alloc] initWithFrame:CGRectMake(frame.size.width-60, 0, 30, 30)];
        [addButton setTitle:@"+" forState:UIControlStateNormal];
        [addButton setTitleColor:self.view.tintColor forState:UIControlStateNormal];
        addButton.tag = section;
        [addButton addTarget:self action:@selector(addRow:) forControlEvents:UIControlEventTouchUpInside];
        [headerView addSubview:addButton];
        
    }
    return headerView;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return kHeaderTitles[section];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DetailTableViewCell *cell = [self.detailTable dequeueReusableCellWithIdentifier:@"detailCell"];
    
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"DetailTableViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
        
    }
    
    if (indexPath.section == 0) {
        if (indexPath.row < curContact.homePhone.count) {
            [self setLabel:cell.contentLabel WithText:[curContact.homePhone objectAtIndex:indexPath.row]];
            [self setLabel:cell.categoryLabel WithText:@"Home"];
        }
        else if(indexPath.row < (curContact.mobilePhone.count+curContact.homePhone.count)) {
            
            [self setLabel:cell.contentLabel WithText:[curContact.mobilePhone objectAtIndex:indexPath.row-curContact.homePhone.count]];
            [self setLabel:cell.categoryLabel WithText:@"Mobile"];
        }
        else {
            
            [self setLabel:cell.contentLabel WithText:[curContact.workPhone objectAtIndex:indexPath.row-curContact.homePhone.count-curContact.mobilePhone.count]];
            [self setLabel:cell.categoryLabel WithText:@"Work"];
        }
    }
    else if (indexPath.section == 1) {
        [self setLabel:cell.contentLabel WithText:[curContact.homeAddress objectAtIndex:indexPath.row]];
        [self setLabel:cell.categoryLabel WithText:@"Home"];
        
    }
    else if (indexPath.section == 2) {
        NSTimeInterval timeInterval = (NSTimeInterval)curContact.birthDate;
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat: @"yyyy-MM-dd"];
        NSString *stringFromDate = [formatter stringFromDate:date];
        [self setLabel:cell.contentLabel WithText:stringFromDate];
        [self setLabel:cell.categoryLabel WithText:@" "];
    }
    else if (indexPath.section == 3) {
        
        [self setLabel:cell.contentLabel WithText:[curContact.workEmail objectAtIndex:indexPath.row]];
        [self setLabel:cell.categoryLabel WithText:@"Work"];    }
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if (indexPath.section == 0) {
            
            if (indexPath.row < curContact.homePhone.count) {
                [curContact.homePhone removeObjectAtIndex:indexPath.row];
            }
            else if(indexPath.row < (curContact.mobilePhone.count+curContact.homePhone.count)) {
                [curContact.mobilePhone removeObjectAtIndex:indexPath.row-curContact.homePhone.count];
            }
            else {
                [curContact.workPhone removeObjectAtIndex:indexPath.row-curContact.homePhone.count-curContact.mobilePhone.count];
            }
        }
        else if(indexPath.section == 1) {
            [curContact.homeAddress removeObjectAtIndex:indexPath.row];
            
        }
        else if(indexPath.section == 2) {
            
        }
        else {
            [curContact.workEmail removeObjectAtIndex:indexPath.row];
        }
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        
        
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if (indexPath.section == 1) {
        NSString *detailText = [self.curContact.homeAddress objectAtIndex:[indexPath row]];
        if([detailText length] == 0) {
            return 44;
        }
        CGSize constraint = CGSizeMake(248, 20000.0f);
        
        NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        [style setLineBreakMode:NSLineBreakByWordWrapping];
        
        // make dictionary of attributes with paragraph style
        NSDictionary *sizeAttributes = @{NSFontAttributeName:FONT_Futura_Medium(16), NSParagraphStyleAttributeName: style};
        
        CGRect frame = [detailText boundingRectWithSize:constraint options:NSStringDrawingUsesLineFragmentOrigin attributes:sizeAttributes context:nil];
//        CGRect rect = [Helper boundingRectWithFont:FONT_Yuanti_R(14) constrainedToSize:constraint lineBreakMode: andText:detailText];
        //        CGSize size = [detailText sizeWithAttributes:
        //                       @{NSFontAttributeName: FONT_Yuanti_R(12)}];
        
        // Values are fractional -- you should take the ceilf to get equivalent values
        CGSize adjustedSize = CGSizeMake(ceilf(frame.size.width), ceilf(frame.size.height));
        //        CGSize size = [detailText sizeWithFont: FONT_Yuanti_R(12) constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
        
        /* get max size between original one and new one */
        CGFloat height = MAX(adjustedSize.height+20, 44.0f);
        return height;
        
        
    }
    return 44;
}

#pragma mark - Keyboard text editing
- (void) dismissKeyboard
{
    UIWindow *mainWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
    [mainWindow endEditing:YES];
}

- (void) resignKeyboard:(id)sender
{
    [self dismissKeyboard];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    tempTextField = textField;
    
    CGRect textFieldRect =
    [self.view.window convertRect:textField.bounds fromView:textField];
    CGRect viewRect =
    [self.view.window convertRect:self.view.bounds fromView:self.view];
    
    CGFloat midline = textFieldRect.origin.y + 0.5 * textFieldRect.size.height;
    CGFloat numerator =
    midline - viewRect.origin.y
    - MINIMUM_SCROLL_FRACTION * viewRect.size.height;
    CGFloat denominator =
    (MAXIMUM_SCROLL_FRACTION - MINIMUM_SCROLL_FRACTION)
    * viewRect.size.height;
    CGFloat heightFraction = numerator / denominator;
    
    if (heightFraction < 0.0)
    {
        heightFraction = 0.0;
    }
    else if (heightFraction > 1.0)
    {
        heightFraction = 1.0;
    }
    
    UIInterfaceOrientation orientation =
    [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationPortrait ||
        orientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        animatedDistance = floor(PORTRAIT_KEYBOARD_HEIGHT * heightFraction);
    }
    else
    {
        animatedDistance = floor(LANDSCAPE_KEYBOARD_HEIGHT * heightFraction);
    }
    
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y -= animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
}

- (void)textFieldDidBeginEditingForName:(UITextField *)textField
{
    
    textfieldFlag = 1;
    [self textFieldDidBeginEditing:textField];
}

- (void)textFieldDidBeginEditingForCompany:(UITextField *)textField
{
    textfieldFlag = 2;
    [self textFieldDidBeginEditing:textField];
}

- (void)textFieldDidBeginEditingForCell:(UITextField *)textField
{
    
    textfieldFlag = 3;
    [self textFieldDidBeginEditing:textField];
}

-(void)textFieldDidEndEditing
{
    
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y += animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
    
    /* sync with model */
    if (textfieldFlag == 1) {
        curContact.name = tempTextField.text;
    }
    else if (textfieldFlag == 2){
        curContact.company = tempTextField.text;
    }
    else if (textfieldFlag == 3){
        DetailTableViewCell *textFieldRowCell = (DetailTableViewCell *) tempTextField.superview.superview.superview;
        NSIndexPath *indexPath = [self.detailTable indexPathForCell:textFieldRowCell];
        if (indexPath.section == 0) {
            
            if (indexPath.row < curContact.homePhone.count) {
                [curContact.homePhone removeObjectAtIndex:indexPath.row];
                [curContact.homePhone insertObject:tempTextField.text atIndex:indexPath.row];
                
            }
            else if(indexPath.row < (curContact.mobilePhone.count+curContact.homePhone.count)) {
                [curContact.mobilePhone removeObjectAtIndex:indexPath.row-curContact.homePhone.count];
                [curContact.mobilePhone insertObject:tempTextField.text atIndex:indexPath.row-curContact.homePhone.count];
            }
            else {
                [curContact.workPhone removeObjectAtIndex:indexPath.row-curContact.homePhone.count-curContact.mobilePhone.count];
                [curContact.workPhone insertObject:tempTextField.text atIndex:indexPath.row-curContact.homePhone.count-curContact.mobilePhone.count];
            }
        }
        else if(indexPath.section == 1) {
            [curContact.homeAddress removeObjectAtIndex:indexPath.row];
            [curContact.homeAddress insertObject:tempTextField.text atIndex:indexPath.row];
            
        }
        else if(indexPath.section == 2) {
            
        }
        else if(indexPath.section == 3) {
            [curContact.workEmail removeObjectAtIndex:indexPath.row];
            [curContact.workEmail insertObject:tempTextField.text atIndex:indexPath.row];
        }
        else {
            
        }
        [self.detailTable reloadData];
        
    }
    [[ViewManager sharedViewManager] syncContacts];
    [[ViewManager sharedViewManager] reloadMasterViewTable];

    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
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
    KIInPlaceEditOptions *options = [KIInPlaceEditOptions longPressAndPromptToEdit];
    
    label.userInteractionEnabled = YES;
    
    [label ipe_enableInPlaceEdit:options];
    if (label.tag == 11) {
        [options setTarget:self action:@selector(textFieldDidBeginEditingForName:) forControlEvents:UIControlEventEditingDidBegin];
        
    }
    else if (label.tag == 12) {
        [options setTarget:self action:@selector(textFieldDidBeginEditingForCompany:) forControlEvents:UIControlEventEditingDidBegin];
        
    }
    else {
        [options setTarget:self action:@selector(textFieldDidBeginEditingForCell:) forControlEvents:UIControlEventEditingDidBegin];
        
    }
}

#pragma mark - Actions

- (IBAction) addRow:(UIButton *)sender {
    NSIndexPath *indexPath;
    if (sender.tag == 0) {
        indexPath = [NSIndexPath indexPathForRow:curContact.homePhone.count+curContact.mobilePhone.count+curContact.workPhone.count inSection:sender.tag];
        [curContact.workPhone insertObject:longPressPrompt atIndex:curContact.workPhone.count];
        
    }
    else if (sender.tag == 1) {
        indexPath = [NSIndexPath indexPathForRow:curContact.homeAddress.count inSection:sender.tag];
        [curContact.homeAddress insertObject:longPressPrompt atIndex:curContact.homeAddress.count];
    }
    else if (sender.tag == 2) {
        
    }
    else {
        indexPath = [NSIndexPath indexPathForRow:curContact.workEmail.count inSection:sender.tag];
        
        [curContact.workEmail insertObject:longPressPrompt atIndex:curContact.workEmail.count];
    }
    
    [self.detailTable insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [[ViewManager sharedViewManager] syncContacts];
    [[ViewManager sharedViewManager] reloadMasterViewTable];
}

- (IBAction)tapOnFavorite:(id)sender {
    if (curContact.isFavorite == false) {
        curContact.isFavorite = true;
            [self.favorite setTitle:[NSString stringWithFormat:@"%@",@"fa-star".bs_awesomeIconRepresentation] forState:UIControlStateNormal];
    }
    else {
        curContact.isFavorite = false;
                    [self.favorite setTitle:[NSString stringWithFormat:@"%@",@"fa-star-o".bs_awesomeIconRepresentation] forState:UIControlStateNormal];
    }
    [[ViewManager sharedViewManager] reExtractFavoriteOnTappingFavorite];
}

@end
