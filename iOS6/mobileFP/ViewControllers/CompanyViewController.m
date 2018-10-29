//
//  CompanyViewController.m
//  mobileFP
//
//  Created by Ashot Navasardyan on 12/8/14.
//  Copyright (c) 2014 FirstOnSite. All rights reserved.
//

#import "CompanyViewController.h"
#import "TextReaderViewController.h"

@interface CompanyViewController ()

@end

@implementation CompanyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = YES;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self setTitle:_company.fullName];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    NSInteger numberOfRows = 4;
    if (section == 1) {
        numberOfRows = 1;
    }
    
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    
    if ([indexPath section] == 0) {
        switch ([indexPath row]) {
            case 0:
                [cell.textLabel setText:NSLocalizedStringFromTable(@"name", [UTIL getLanguage], @"")];
                [cell.detailTextLabel setText:_company.fullName];
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                break;
            case 1:
                [cell.textLabel setText:NSLocalizedStringFromTable(@"address", [UTIL getLanguage], @"")];
                [cell.detailTextLabel setText:_company.address.fullAddress];
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                break;
            case 2:
                [cell.textLabel setText:NSLocalizedStringFromTable(@"phone", [UTIL getLanguage], @"")];
                [cell.detailTextLabel setText:_company.phoneFormatted];
                if ([_company.phone isEqual:@""]) {
                    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                }
                break;
            case 3:
                [cell.textLabel setText:NSLocalizedStringFromTable(@"company_type", [UTIL getLanguage], @"")];
                [cell.detailTextLabel setText:_company.companyType];
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                break;
        }
    } else {
        [cell.textLabel setText:NSLocalizedStringFromTable(@"profile", [UTIL getLanguage], @"")];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch ([indexPath section]) {
        case 0:
            if (![_company.phone isEqual:@""] && [indexPath row] == 2) {
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
                NSURL *phoneUrl = [NSURL URLWithString:[NSString  stringWithFormat:@"telprompt:%@",_company.phone]];
                if ([[UIApplication sharedApplication] canOpenURL:phoneUrl]) {
                    [[UIApplication sharedApplication] openURL:phoneUrl];
                }
            }
            break;
        default:
            [self performSegueWithIdentifier:@"showProfile" sender:self];
            break;
    }
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
    if ([[segue identifier] isEqualToString:@"showProfile"]) {
        TextReaderViewController *child = (TextReaderViewController *)[segue destinationViewController];
        [child setHeaderTitle:NSLocalizedStringFromTable(@"profile", [UTIL getLanguage], @"")];
        [child setText:_company.profile];
    }
}

@end
