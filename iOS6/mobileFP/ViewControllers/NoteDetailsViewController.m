//
//  NoteDetailsViewController.m
//  mobileFP
//
//  Created by Ashot Navasardyan on 12/13/14.
//  Copyright (c) 2014 FirstOnSite. All rights reserved.
//

#import "NoteDetailsViewController.h"
#import "NoteShareViewController.h"

@interface NoteDetailsViewController ()

@end

@implementation NoteDetailsViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Custom initialization
        self.note = [[Note alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = YES;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self setTitle:NSLocalizedStringFromTable(@"note_details", [UTIL getLanguage], @"")];
    
    if (_readOnly) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(stopPressed:)];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 44.0f;
    if ([indexPath section] == 1) {
        height = 180.0f;
    }
    
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 44.0f;
    
    switch ([indexPath section]) {
        case 1:
            height = 180.0f;
            break;
        case 2:
            height = 56.0f;
            break;
        default:
            height = 44.0f;
            break;
    }
    
    return height;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger numberOfSections = 2;
    
    if (_note.customerGatewayVisible == 1) {
        numberOfSections = 3;
    }
    
    return numberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    NSInteger numberOfRows = 1;
    if (section == 0) {
        numberOfRows = 3;
    }
    
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    UITextView *details;
    
    switch ([indexPath section]) {
        case 0:
            switch ([indexPath row]) {
                case 0:
                    [cell.textLabel setText:NSLocalizedStringFromTable(@"claim", [UTIL getLanguage], @"")];
                    [cell.detailTextLabel setText:[NSString stringWithFormat:@"%@ - %@ (%@)", _note.claim.claimNumber, _note.phase.phaseCode, _note.departmentId]];
                    break;
                case 1:
                    [cell.textLabel setText:NSLocalizedStringFromTable(@"date", [UTIL getLanguage], @"")];
                    [cell.detailTextLabel setText:_note.dateCreated];
                    break;
                case 2:
                    [cell.textLabel setText:NSLocalizedStringFromTable(@"entered_by", [UTIL getLanguage], @"")];
                    [cell.detailTextLabel setText:_note.enteredBy.fullName];
                    break;
            }
            break;
        case 1:
            cell = [tableView dequeueReusableCellWithIdentifier:@"NotesCell" forIndexPath:indexPath];
            details = (UITextView *)[cell viewWithTag:100];
            [details setText:_note.note];
            break;
        default:
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            [cell.textLabel setText:NSLocalizedStringFromTable(@"visible_customer_gateway", [UTIL getLanguage], @"")];
            [cell.textLabel setNumberOfLines:-1];
            [cell.textLabel setLineBreakMode:NSLineBreakByWordWrapping];
            
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            break;
    }
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"shareNote"]) {
        NoteShareViewController *child = (NoteShareViewController *)[segue destinationViewController];
        [child setNote:_note];
    }
}

- (IBAction)sharePressed:(id)sender {
    [self performSegueWithIdentifier:@"shareNote" sender:self];
}

- (void)stopPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"noteDismissed" object:nil userInfo:nil];
    }];
}

@end
