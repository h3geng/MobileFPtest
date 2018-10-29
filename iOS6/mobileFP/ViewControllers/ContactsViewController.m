//
//  ContactsViewController.m
//  mobileFP
//
//  Created by Ashot Navasardyan on 12/8/14.
//  Copyright (c) 2014 FirstOnSite. All rights reserved.
//

#import "ContactsViewController.h"
#import "CompanyViewController.h"
#import "ContactViewController.h"

@interface ContactsViewController ()

@end

@implementation ContactsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = YES;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self setTitle:NSLocalizedStringFromTable(@"contacts", [UTIL getLanguage], @"")];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *title = @"";
    switch (section) {
        case 0:
            title = NSLocalizedStringFromTable(@"owner", [UTIL getLanguage], @"");
            break;
        case 1:
            title = NSLocalizedStringFromTable(@"adjusting_company", [UTIL getLanguage], @"");
            break;
        case 2:
            title = NSLocalizedStringFromTable(@"adjuster", [UTIL getLanguage], @"");
            break;
        case 3:
            title = NSLocalizedStringFromTable(@"insurer", [UTIL getLanguage], @"");
            break;
    }
    
    return title;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    
    switch ([indexPath section]) {
        case 0:
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            if (![_claim.claimOwner.fullName isEqual: @""]) {
                [cell.textLabel setText:_claim.claimOwner.fullName];
                [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            } else {
                [cell.textLabel setText:@"None"];
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            }
            break;
        case 1:
            if (_claim.adjCompany.companyId > 0) {
                [cell.textLabel setText:_claim.adjCompany.fullName];
                [cell.detailTextLabel setText:[NSString stringWithFormat:@"%@", _claim.adjCompany.address.fullAddress]];
                [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            } else {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
                [cell.textLabel setText:@"None"];
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            }
            break;
        case 2:
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            if (_claim.adjuster.contactId > 0) {
                [cell.textLabel setText:_claim.adjuster.fullName];
                [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            } else {
                [cell.textLabel setText:@"None"];
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            }
            break;
        case 3:
            if (_claim.insurer.companyId > 0) {
                [cell.textLabel setText:[NSString stringWithFormat:@"%@", _claim.insurer.fullName]];
                [cell.detailTextLabel setText:[NSString stringWithFormat:@"%@", _claim.insurer.address.fullAddress]];
                [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            } else {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
                [cell.textLabel setText:@"None"];
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            }
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch ([indexPath section]) {
        case 0:
            if (![_claim.claimOwner.fullName isEqual: @""]) {
                [self performSegueWithIdentifier:@"showOwner" sender:self];
            }
            break;
        case 1:
            if (_claim.adjCompany.companyId > 0) {
                _company = _claim.adjCompany;
                [self performSegueWithIdentifier:@"showCompany" sender:self];
            }
            break;
        case 2:
            if (_claim.adjuster.contactId > 0) {
                [self performSegueWithIdentifier:@"showContact" sender:self];
            }
            break;
        case 3:
            if (_claim.insurer.companyId > 0) {
                _company = _claim.insurer;
                [self performSegueWithIdentifier:@"showCompany" sender:self];
            }
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
    if ([[segue identifier] isEqualToString:@"showCompany"]) {
        CompanyViewController *child = (CompanyViewController *)[segue destinationViewController];
        [child setCompany:_company];
    }
    if ([[segue identifier] isEqualToString:@"showOwner"]) {
        ContactViewController *child = (ContactViewController *)[segue destinationViewController];
        [child setContact:[[Contact alloc] init]];
        [child setOwner:_claim.claimOwner];
    }
    if ([[segue identifier] isEqualToString:@"showContact"]) {
        ContactViewController *child = (ContactViewController *)[segue destinationViewController];
        [child setContact:_claim.adjuster];
        [child setOwner:[[ClaimOwner alloc] init]];
    }
}

@end
