//
//  ContactViewController.m
//  mobileFP
//
//  Created by Ashot Navasardyan on 12/8/14.
//  Copyright (c) 2014 FirstOnSite. All rights reserved.
//

#import "ContactViewController.h"
#import "CompanyViewController.h"

@interface ContactViewController ()

@end

@implementation ContactViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = YES;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    if (![_contact.fullName isEqual:@""]) {
        [self setTitle:_contact.fullName];
    } else {
        [self setTitle:_owner.fullName];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *title = NSLocalizedStringFromTable(@"contact_details", [UTIL getLanguage], @"");
    if (section == 1) {
        title = NSLocalizedStringFromTable(@"company_details", [UTIL getLanguage], @"");
    }
    
    return title;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger numberOfSections = 2;
    if ([_contact.fullName isEqual:@""]) {
        numberOfSections = 1;
    }
    
    return numberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    NSInteger numberOfRows = 4;
    
    if (section == 1) {
        numberOfRows = 2;
    }
    
    if ([_contact.fullName isEqual:@""] && section == 0) {
        numberOfRows = 8;
    }
    
    return numberOfRows;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat heightForRow = 44.0f;
    if ([_contact.fullName isEqual:@""]) {
        switch ([indexPath row]) {
            case 1:
                if ([_owner.email isEqual:@""]) {
                    heightForRow = 0.01f;
                }
                break;
            case 2:
                if ([_owner.email2 isEqual:@""]) {
                    heightForRow = 0.01f;
                }
                break;
            case 3:
                if ([_owner.phone isEqual:@""]) {
                    heightForRow = 0.01f;
                }
                break;
            case 4:
                if ([_owner.phone2Formatted isEqual:@""]) {
                    heightForRow = 0.01f;
                }
                break;
            case 5:
                if ([_owner.cell isEqual:@""]) {
                    heightForRow = 0.01f;
                }
                break;
            case 6:
                if ([_owner.contactName isEqual:@""] && [_owner.contactPhone isEqual:@""]) {
                    heightForRow = 0.01f;
                }
                break;
            case 7:
                if ([_owner.address.fullAddress isEqual:@""]) {
                    heightForRow = 0.01f;
                }
                break;
        }
    }
    
    return heightForRow;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    
    switch ([indexPath section]) {
        case 0:
            if (![_contact.fullName isEqual:@""]) {
                switch ([indexPath row]) {
                    case 0:
                        [cell.textLabel setText:NSLocalizedStringFromTable(@"name", [UTIL getLanguage], @"")];
                        [cell.detailTextLabel setText:_contact.fullName];
                        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                        break;
                    case 1:
                        [cell.textLabel setText:NSLocalizedStringFromTable(@"email", [UTIL getLanguage], @"")];
                        [cell.detailTextLabel setText:_contact.email];
                        if ([_contact.email isEqual:@""]) {
                            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                        }
                        break;
                    case 2:
                        [cell.textLabel setText:NSLocalizedStringFromTable(@"phone", [UTIL getLanguage], @"")];
                        [cell.detailTextLabel setText:_contact.phoneFormatted];
                        if ([_contact.phone isEqual:@""]) {
                            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                        }
                        break;
                    case 3:
                        [cell.textLabel setText:NSLocalizedStringFromTable(@"cell", [UTIL getLanguage], @"")];
                        [cell.detailTextLabel setText:_contact.cellFormatted];
                        if ([_contact.cell isEqual:@""]) {
                            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                        }
                        break;
                }
            } else {
                switch ([indexPath row]) {
                    case 0:
                        [cell.textLabel setText:NSLocalizedStringFromTable(@"name", [UTIL getLanguage], @"")];
                        [cell.detailTextLabel setText:_owner.fullName];
                        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                        break;
                    case 1:
                        if ([_owner.email isEqual:@""]) {
                            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                        } else {
                            [cell.textLabel setText:NSLocalizedStringFromTable(@"email", [UTIL getLanguage], @"")];
                            [cell.detailTextLabel setText:_owner.email];
                        }
                        break;
                    case 2:
                        if ([_owner.email2 isEqual:@""]) {
                            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                        } else {
                            [cell.textLabel setText:[NSString stringWithFormat:@"%@ 2", NSLocalizedStringFromTable(@"email", [UTIL getLanguage], @"")]];
                            [cell.detailTextLabel setText:_owner.email2];
                        }
                        break;
                    case 3:
                        if ([_owner.phone isEqual:@""]) {
                            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                        } else {
                            [cell.textLabel setText:NSLocalizedStringFromTable(@"phone", [UTIL getLanguage], @"")];
                            [cell.detailTextLabel setText:_owner.phoneFormatted];
                        }
                        break;
                    case 4:
                        if ([_owner.phone2Formatted isEqual:@""]) {
                            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                        } else {
                            [cell.textLabel setText:[NSString stringWithFormat:@"%@ 2", NSLocalizedStringFromTable(@"phone", [UTIL getLanguage], @"")]];
                            [cell.detailTextLabel setText:_owner.phone2Formatted];
                        }
                        break;
                    case 5:
                        if ([_owner.cell isEqual:@""]) {
                            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                        } else {
                            [cell.textLabel setText:NSLocalizedStringFromTable(@"cell", [UTIL getLanguage], @"")];
                            [cell.detailTextLabel setText:_owner.cellFormatted];
                        }
                        break;
                    case 6:
                        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
                        if ([_owner.contactName isEqual:@""] && [_owner.contactPhone isEqual:@""]) {
                        } else {
                            [cell.textLabel setText:NSLocalizedStringFromTable(@"additional_contact_information", [UTIL getLanguage], @"")];
                            [cell.detailTextLabel setText:[UTIL trim:[NSString stringWithFormat:@"%@ %@", _owner.contactName, _owner.contactPhone]]];
                        }
                        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                        break;
                    case 7:
                        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
                        if (![_owner.address.fullAddress isEqual:@""]) {
                            [cell.textLabel setText:NSLocalizedStringFromTable(@"address", [UTIL getLanguage], @"")];
                            [cell.detailTextLabel setText:_owner.address.fullAddress];
                        }
                        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                        break;
                }
            }
            break;
        case 1:
            switch ([indexPath row]) {
                case 0:
                    [cell.textLabel setText:NSLocalizedStringFromTable(@"name", [UTIL getLanguage], @"")];
                    [cell.detailTextLabel setText:_contact.company.fullName];
                    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
                    break;
                case 1:
                    [cell.textLabel setText:NSLocalizedStringFromTable(@"type", [UTIL getLanguage], @"")];
                    [cell.detailTextLabel setText:_contact.company.companyType];
                    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                    break;
            }
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch ([indexPath section]) {
        case 0:
            if (![_contact.fullName isEqual:@""]) {
                switch ([indexPath row]) {
                    case 1:
                        // email
                        if (![_contact.email isEqual:@""]) {
                            NSString *urlString = [NSString stringWithFormat:@"mailto:%@", _contact.email];
                            
                            NSURL* mailURL = [NSURL URLWithString:urlString];
                            if ([[UIApplication sharedApplication] canOpenURL:mailURL]) {
                                [[UIApplication sharedApplication] openURL:mailURL];
                            }
                        }
                        break;
                    case 2:
                        // phone
                        if (![_contact.phone isEqual:@""]) {
                            NSURL *phoneUrl = [NSURL URLWithString:[NSString  stringWithFormat:@"telprompt:%@", _contact.phone]];
                            
                            if ([[UIApplication sharedApplication] canOpenURL:phoneUrl]) {
                                [[UIApplication sharedApplication] openURL:phoneUrl];
                            }
                        }
                        break;
                    case 3:
                        // cell
                        if (![_contact.cell isEqual:@""]) {
                            NSURL *phoneUrl = [NSURL URLWithString:[NSString  stringWithFormat:@"telprompt:%@", _contact.cell]];
                            
                            if ([[UIApplication sharedApplication] canOpenURL:phoneUrl]) {
                                [[UIApplication sharedApplication] openURL:phoneUrl];
                            }
                        }
                        break;
                }
            } else {
                switch ([indexPath row]) {
                    case 1:
                        // email
                        if (![_owner.email isEqual:@""]) {
                            NSString *urlString = [NSString stringWithFormat:@"mailto:%@", _owner.email];
                            
                            NSURL* mailURL = [NSURL URLWithString:urlString];
                            if ([[UIApplication sharedApplication] canOpenURL:mailURL]) {
                                [[UIApplication sharedApplication] openURL:mailURL];
                            }
                        }
                        break;
                    case 2:
                        // email 2
                        if (![_owner.email2 isEqual:@""]) {
                            NSString *urlString = [NSString stringWithFormat:@"mailto:%@", _owner.email2];
                            
                            NSURL* mailURL = [NSURL URLWithString:urlString];
                            if ([[UIApplication sharedApplication] canOpenURL:mailURL]) {
                                [[UIApplication sharedApplication] openURL:mailURL];
                            }
                        }
                        break;
                    case 3:
                        // phone
                        if (![_owner.phone isEqual:@""]) {
                            NSURL *phoneUrl = [NSURL URLWithString:[NSString  stringWithFormat:@"telprompt:%@", _owner.phone]];
                            
                            if ([[UIApplication sharedApplication] canOpenURL:phoneUrl]) {
                                [[UIApplication sharedApplication] openURL:phoneUrl];
                            }
                        }
                        break;
                    case 4:
                        // phone 2
                        if (![_owner.phone2 isEqual:@""]) {
                            NSURL *phoneUrl = [NSURL URLWithString:[NSString  stringWithFormat:@"telprompt:%@", _owner.phone2]];
                            
                            if ([[UIApplication sharedApplication] canOpenURL:phoneUrl]) {
                                [[UIApplication sharedApplication] openURL:phoneUrl];
                            }
                        }
                        break;
                    case 5:
                        // cell
                        if (![_owner.cell isEqual:@""]) {
                            NSURL *phoneUrl = [NSURL URLWithString:[NSString  stringWithFormat:@"telprompt:%@", _owner.cell]];
                            
                            if ([[UIApplication sharedApplication] canOpenURL:phoneUrl]) {
                                [[UIApplication sharedApplication] openURL:phoneUrl];
                            }
                        }
                        break;
                }
            }
            
            break;
        case 1:
            if ([indexPath row] == 0) {
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
        [child setCompany:_contact.company];
    }
}

@end
