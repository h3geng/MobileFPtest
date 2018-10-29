//
//  ExpenseViewController.m
//  mobileFP
//
//  Created by Ashot Navasardyan on 2017-03-16.
//  Copyright © 2017 FirstOnSite. All rights reserved.
//

#import "ExpenseViewController.h"

@interface ExpenseViewController ()

@end

@implementation ExpenseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = YES;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self setTitle:NSLocalizedStringFromTable(@"expense", [UTIL getLanguage], @"")];
    
    // default types
    _expenseType = 0;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(collectionItemSelected:) name:@"collectionItemSelected" object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    _expenseMethodsVisible = false;
    _expenseTypesVisible = false;
    _expenseDatePickerVisible = false;
    //_expenseMethodId = 1;
    
    //_expenseDateVisible = false;
    //_expenseDate = [NSDate date];
    /*if (_expense.selfId > 0) {
        [_expense load:^(NSMutableArray *result) {
            [self->_expense initWithData:result];
            //self->_expenseDate = [UTIL formatDateString:self->_expense.dateExpense format:@"yyyy-MM-dd"];
            //self->_expenseMethodId = self->_expense.expenseMethodId;
            [self.tableView reloadData];
        }];
    }*/
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return UITableViewAutomaticDimension;
    } else {
        return 0.1f;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section != 1 && section != 2) {
        return UITableViewAutomaticDimension;
    } else {
        return 0.1f;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numberOfRows = 0;
    
    switch (section) {
        case 0:
            numberOfRows = 8;
            break;
        case 1:
            numberOfRows = 13;
            break;
        case 2:
            numberOfRows = 12;
            break;
        case 3:
            numberOfRows = 6;
            break;
        default:
            numberOfRows = 1;
            break;
    }
    
    return numberOfRows;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat heightForRow = UITableViewAutomaticDimension;
    
    switch ([indexPath section]) {
        case 0:
            switch ([indexPath row]) {
                case 1: // out of pocket vs mileage
                case 2:
                    heightForRow = _expenseMethodsVisible ? UITableViewAutomaticDimension : 0.0f;
                    break;
                case 3: // visible type when not mileage (simple vs job)
                    heightForRow = _expense.expenseMethodId != 3 ? UITableViewAutomaticDimension : 0.0f;
                    break;
                case 4:
                case 5:
                    heightForRow = _expenseTypesVisible ? UITableViewAutomaticDimension : 0.0f;
                    break;
                case 7:
                    heightForRow = _expenseDatePickerVisible ? 216.0f : 0.0f;
                    break;
            }
            break;
        case 1:
            if (_expense.expenseMethodId == 1) {
                 heightForRow = UITableViewAutomaticDimension;
            } else {
                 heightForRow = 0.0f;
            }
            break;
        case 2:
            if (_expense.expenseMethodId == 2) {
                if (([indexPath row] == 6 || [indexPath row] == 7 || [indexPath row] == 8) && _expenseType == 0) {
                    heightForRow = 0.0f;
                } else {
                    heightForRow = UITableViewAutomaticDimension;
                }
                if ([indexPath row] == 11) {
                    heightForRow = 150.0f;
                }
            } else {
                heightForRow = 0.0f;
            }
            break;
        case 3:
            if (_expense.expenseMethodId == 3) {
                if ([indexPath row] == 4 || [indexPath row] == 5) {
                    heightForRow = 150.0f;
                } else {
                    heightForRow = UITableViewAutomaticDimension;
                }
            } else {
                heightForRow = 0.0f;
            }
            break;
        case 4:
            if (_expense.expenseMethodId != 3) {
                heightForRow = UITableViewAutomaticDimension;
            } else {
                heightForRow = 0.0f;
            }
            break;
    }
    
    return heightForRow;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    UITextField *textField;
    
    switch ([indexPath section]) {
        case 0:
            switch ([indexPath row]) {
                case 0:
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
                    [cell.textLabel setText:NSLocalizedStringFromTable(@"method", [UTIL getLanguage], @"")];
                    switch (_expense.expenseMethodId) {
                        case 1:
                            [cell.detailTextLabel setText:NSLocalizedStringFromTable(@"corporate_card", [UTIL getLanguage], @"")];
                            break;
                        case 2:
                            [cell.detailTextLabel setText:NSLocalizedStringFromTable(@"out_of_pocket", [UTIL getLanguage], @"")];
                            break;
                        case 3:
                            [cell.detailTextLabel setText:NSLocalizedStringFromTable(@"mileage", [UTIL getLanguage], @"")];
                            break;
                    }
                    if (_expense.selfId == 0) {
                        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
                    }
                    break;
                case 1:
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
                    [cell.textLabel setText:NSLocalizedStringFromTable(@"mileage", [UTIL getLanguage], @"")];
                    if (_expense.expenseMethodId == 3) {
                        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
                    }
                    [cell setHidden:YES];
                    break;
                case 2:
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
                    [cell.textLabel setText:NSLocalizedStringFromTable(@"out_of_pocket", [UTIL getLanguage], @"")];
                    if (_expense.expenseMethodId == 2) {
                        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
                    }
                    [cell setHidden:YES];
                    break;
                case 3:
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
                    [cell.textLabel setText:NSLocalizedStringFromTable(@"type", [UTIL getLanguage], @"")];
                    if (_expenseType == 0) {
                        [cell.detailTextLabel setText:NSLocalizedStringFromTable(@"simple_expense", [UTIL getLanguage], @"")];
                    } else {
                        [cell.detailTextLabel setText:NSLocalizedStringFromTable(@"job_related_expense", [UTIL getLanguage], @"")];
                    }
                    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
                    [cell setHidden:_expense.expenseMethodId == 3];
                    break;
                case 4:
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
                    [cell.textLabel setText:NSLocalizedStringFromTable(@"simple_expense", [UTIL getLanguage], @"")];
                    if (_expenseType == 0) {
                        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
                    }
                    [cell setHidden:YES];
                    break;
                case 5:
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
                    [cell.textLabel setText:NSLocalizedStringFromTable(@"job_related_expense", [UTIL getLanguage], @"")];
                    if (_expenseType == 1) {
                        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
                    }
                    [cell setHidden:YES];
                    break;
                case 6:
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
                    [cell.textLabel setText:NSLocalizedStringFromTable(@"date", [UTIL getLanguage], @"")];
                    [cell.detailTextLabel setText:[UTIL formatDateOnly:[UTIL formatDateString:_expense.dateExpense format:@""] format:@""]];
                    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
                    break;
                default:
                    cell = [tableView dequeueReusableCellWithIdentifier:@"datePickerCell"];
                    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                    _pickerDate = (UIDatePicker *)[cell.contentView viewWithTag:1];
                    [_pickerDate addTarget:self action:@selector(dateIsChanged:) forControlEvents:UIControlEventValueChanged];
                    [_pickerDate setDate:[UTIL formatDateString:_expense.dateExpense format:@""]];
                    break;
            }
            break;
        case 1:
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            if (_expense.expenseMethodId == 1) {
                [cell.textLabel setText:@"CC"];
            } else {
                [cell setHidden:YES];
            }
            break;
        case 2:
            if (_expense.expenseMethodId == 2) {
                switch ([indexPath row]) {
                    case 0:
                        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
                        [cell.textLabel setText:NSLocalizedStringFromTable(@"branch", [UTIL getLanguage], @"")];
                        [cell.detailTextLabel setText:_expense.branchName];
                        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
                        break;
                    case 1:
                        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
                        [cell.textLabel setText:NSLocalizedStringFromTable(@"department", [UTIL getLanguage], @"")];
                        if (_expenseType == 1) {
                            [cell.detailTextLabel setText:_expense.jobDepartmentName];
                        } else {
                            [cell.detailTextLabel setText:_expense.departmentName];
                        }
                        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
                        break;
                    case 2:
                        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
                        [cell.textLabel setText:NSLocalizedStringFromTable(@"purchase_location", [UTIL getLanguage], @"")];
                        [cell.detailTextLabel setText:_expense.provinceName];
                        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
                        break;
                    case 3:
                        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
                        [cell.textLabel setText:NSLocalizedStringFromTable(@"merchant", [UTIL getLanguage], @"")];
                        
                        textField = [[UITextField alloc] initWithFrame:CGRectMake(cell.contentView.bounds.size.width - 160.0f, 6.2f, 140.0f, cell.contentView.bounds.size.height - 12.0f)];
                        [textField setBorderStyle:UITextBorderStyleRoundedRect];
                        [textField setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
                        [textField setTag:16];
                        
                        [textField setText:_expense.merchant];
                        [textField setDelegate:self];
                        [textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
                        
                        [cell.contentView addSubview:textField];
                        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                        break;
                    case 4:
                        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
                        [cell.textLabel setText:NSLocalizedStringFromTable(@"currency", [UTIL getLanguage], @"")];
                        if (_expense.currencyId == 1) {
                            [cell.detailTextLabel setText:@"CAD"];
                        } else {
                            [cell.detailTextLabel setText:@"USD"];
                        }
                        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
                        break;
                    case 5:
                        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
                        if (_expenseType == 1) {
                            [cell.textLabel setText:NSLocalizedStringFromTable(@"claim", [UTIL getLanguage], @"")];
                            [cell.detailTextLabel setText:_expense.claimName];
                        } else {
                            [cell.textLabel setText:NSLocalizedStringFromTable(@"category", [UTIL getLanguage], @"")];
                            [cell.detailTextLabel setText:_expense.expenseCategoryName];
                        }
                        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
                        break;
                    case 6:
                        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
                        if (_expenseType == 0) {
                            [cell setHidden:YES];
                        } else {
                            [cell.textLabel setText:NSLocalizedStringFromTable(@"phase", [UTIL getLanguage], @"")];
                            [cell.detailTextLabel setText:_expense.phaseName];
                            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
                        }
                        break;
                    case 7:
                        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
                        if (_expenseType == 0) {
                            [cell setHidden:YES];
                        } else {
                            [cell.textLabel setText:NSLocalizedStringFromTable(@"type", [UTIL getLanguage], @"")];
                            [cell.detailTextLabel setText:_expense.typeName];
                            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
                        }
                        break;
                    case 8:
                        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
                        if (_expenseType == 0) {
                            [cell setHidden:YES];
                        } else {
                            [cell.textLabel setText:NSLocalizedStringFromTable(@"cost_category", [UTIL getLanguage], @"")];
                            [cell.detailTextLabel setText:_expense.costCategoryName];
                            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
                        }
                        break;
                    case 9:
                        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
                        [cell.textLabel setText:NSLocalizedStringFromTable(@"total_amount", [UTIL getLanguage], @"")];
                        
                        textField = [[UITextField alloc] initWithFrame:CGRectMake(cell.contentView.bounds.size.width - 100.0f, 0, 80.0f, cell.contentView.bounds.size.height)];
                        [textField setAutocorrectionType:UITextAutocorrectionTypeNo];
                        [textField setKeyboardType:UIKeyboardTypeNumberPad];
                        [textField setTextAlignment:NSTextAlignmentRight];
                        [textField setBorderStyle:UITextBorderStyleNone];
                        [textField setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
                        [textField setEnablesReturnKeyAutomatically:YES];
                        [textField setTag:14];
                        
                        [textField setText:[NSString stringWithFormat:@"%.02f",_expense.totalAmount]];
                        [textField setDelegate:self];
                        [textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
                        
                        [cell.contentView addSubview:textField];
                        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                        break;
                    case 10:
                        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
                        [cell.textLabel setText:NSLocalizedStringFromTable(@"tip", [UTIL getLanguage], @"")];
                        
                        textField = [[UITextField alloc] initWithFrame:CGRectMake(cell.contentView.bounds.size.width - 100.0f, 0, 80.0f, cell.contentView.bounds.size.height)];
                        [textField setAutocorrectionType:UITextAutocorrectionTypeNo];
                        [textField setKeyboardType:UIKeyboardTypeNumberPad];
                        [textField setTextAlignment:NSTextAlignmentRight];
                        [textField setBorderStyle:UITextBorderStyleNone];
                        [textField setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
                        [textField setEnablesReturnKeyAutomatically:YES];
                        [textField setTag:15];
                        
                        [textField setText:[NSString stringWithFormat:@"%.02f",_expense.tip]];
                        [textField setDelegate:self];
                        [textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
                        
                        [cell.contentView addSubview:textField];
                        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                        break;
                    default:
                    {
                        cell = [tableView dequeueReusableCellWithIdentifier:@"commentCell"];
                        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                        
                        UILabel *lbl = (UILabel *)[cell.contentView viewWithTag:1];
                        [lbl setText:NSLocalizedStringFromTable(@"comments", [UTIL getLanguage], @"")];
                        
                        UITextView *txt = (UITextView *)[cell.contentView viewWithTag:11];
                        [txt.layer setBorderWidth:0.5f];
                        [txt.layer setBorderColor:[[UIColor grayColor] CGColor]];
                        [txt.layer setCornerRadius:4.0f];
                        [txt setText:_expense.comments];
                        [txt setDelegate:self];
                    }
                        break;
                }
            } else {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
                [cell setHidden:YES];
            }
            break;
        case 3:
            if (_expense.expenseMethodId == 3) {
                switch ([indexPath row]) {
                    case 0:
                        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
                        [cell.textLabel setText:NSLocalizedStringFromTable(@"branch", [UTIL getLanguage], @"")];
                        [cell.detailTextLabel setText:_expense.branchName];
                        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
                        break;
                    case 1:
                        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
                        [cell.textLabel setText:NSLocalizedStringFromTable(@"department", [UTIL getLanguage], @"")];
                        [cell.detailTextLabel setText:_expense.departmentName];
                        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
                        break;
                    case 2:
                        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
                        [cell.textLabel setText:NSLocalizedStringFromTable(@"distance", [UTIL getLanguage], @"")];
                        
                        textField = [[UITextField alloc] initWithFrame:CGRectMake(cell.contentView.bounds.size.width - 100.0f, 0, 80.0f, cell.contentView.bounds.size.height)];
                        [textField setAutocorrectionType:UITextAutocorrectionTypeNo];
                        [textField setKeyboardType:UIKeyboardTypeNumberPad];
                        [textField setTextAlignment:NSTextAlignmentRight];
                        [textField setBorderStyle:UITextBorderStyleNone];
                        [textField setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
                        [textField setEnablesReturnKeyAutomatically:YES];
                        [textField setTag:13];
                        
                        [textField setText:[NSString stringWithFormat:@"%d",_expense.mileage]];
                        [textField setDelegate:self];
                        [textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
                        
                        [cell.contentView addSubview:textField];
                        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                        break;
                    case 3:
                        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
                        [cell.textLabel setText:NSLocalizedStringFromTable(@"amount", [UTIL getLanguage], @"")];
                        [cell.detailTextLabel setText:[NSString stringWithFormat:@"$%.02f", _expense.totalAmount]];
                        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                        break;
                    case 4:
                    {
                        cell = [tableView dequeueReusableCellWithIdentifier:@"commentCell"];
                        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                        
                        UILabel *lbl = (UILabel *)[cell.contentView viewWithTag:1];
                        [lbl setText:NSLocalizedStringFromTable(@"details", [UTIL getLanguage], @"")];
                        
                        UITextView *txt = (UITextView *)[cell.contentView viewWithTag:11];
                        [txt.layer setBorderWidth:0.5f];
                        [txt.layer setBorderColor:[[UIColor grayColor] CGColor]];
                        [txt.layer setCornerRadius:4.0f];
                        [txt setText:_expense.comments];
                        [txt setDelegate:self];
                    }
                        break;
                    case 5:
                    {
                        cell = [tableView dequeueReusableCellWithIdentifier:@"destinationCell"];
                        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                        
                        UILabel *lbl = (UILabel *)[cell.contentView viewWithTag:1];
                        [lbl setText:NSLocalizedStringFromTable(@"destinations", [UTIL getLanguage], @"")];
                        
                        UITextView *txt = (UITextView *)[cell.contentView viewWithTag:12];
                        [txt.layer setBorderWidth:0.5f];
                        [txt.layer setBorderColor:[[UIColor grayColor] CGColor]];
                        [txt.layer setCornerRadius:4.0f];
                        [txt setText:_expense.destinations];
                        [txt setDelegate:self];
                    }
                        break;
                }
            } else {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
                [cell setHidden:YES];
            }
            break;
        default:
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            [cell.textLabel setText:NSLocalizedStringFromTable(@"receipt", [UTIL getLanguage], @"")];
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            if (_expense.expenseMethodId == 3) {
                [cell setHidden:YES];
            }
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch ([indexPath section]) {
        case 0:
            switch ([indexPath row]) {
                case 0:
                    if (_expense.selfId == 0) {
                        [self toggleMethodSelectorCell:indexPath];
                    } else {
                        [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
                    }
                    break;
                case 1:
                    _expense.expenseMethodId = 3;
                    [self toggleMethodSelectorCell:indexPath];
                    break;
                case 2:
                    _expense.expenseMethodId = 2;
                    [self toggleMethodSelectorCell:indexPath];
                    break;
                case 3:
                    [self toggleTypeSelectorCell:indexPath];
                    break;
                case 4:
                    _expenseType = 0;
                    [self toggleTypeSelectorCell:indexPath];
                    break;
                case 5:
                    _expenseType = 1;
                    [self toggleTypeSelectorCell:indexPath];
                    break;
                case 6:
                    [self toggleDatePickerCell:indexPath];
                    break;
            }
            break;
        case 1: // corporate
            break;
        case 2: // out of pocket
            switch ([indexPath row]) {
                case 0:
                    _collectionType = 5;
                    _selectedId = [NSString stringWithFormat:@"%d", _expense.branchId];
                    [self performSegueWithIdentifier:@"showCollection" sender:self];
                    break;
                case 1:
                    if (_expenseType == 1) {
                        _collectionType = 11;
                        _selectedId = _expense.jobDepartmentId;
                    } else {
                        _collectionType = 1;
                        _selectedId = [NSString stringWithFormat:@"%d", _expense.departmentId];
                    }
                    [self performSegueWithIdentifier:@"showCollection" sender:self];
                    break;
                case 2:
                    _collectionType = 2;
                    _selectedId = _expense.province;
                    [self performSegueWithIdentifier:@"showCollection" sender:self];
                    break;
                case 3:
                {
                    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
                    UITextField *txt = (UITextField *)[cell.contentView viewWithTag:16];
                    [txt becomeFirstResponder];
                }
                    break;
                case 4:
                    _collectionType = 8;
                    _selectedId = [NSString stringWithFormat:@"%d", _expense.currencyId];
                    [self performSegueWithIdentifier:@"showCollection" sender:self];
                    break;
                case 5:
                    if (_expenseType == 1) {
                        _collectionType = 6;
                        [self performSegueWithIdentifier:@"showClaims" sender:self];
                    } else {
                        _collectionType = 3;
                        _selectedId = [NSString stringWithFormat:@"%d", _expense.gpCategoryId];
                        [self performSegueWithIdentifier:@"showCollection" sender:self];
                    }
                    break;
                case 6:
                    if (_expenseType == 1) {
                        _collectionType = 7;
                        _selectedId = [NSString stringWithFormat:@"%d", _expense.claimIndx];
                        [self performSegueWithIdentifier:@"showCollection" sender:self];
                    }
                    break;
                case 7:
                    _collectionType = 9;
                    _selectedId = _expense.typeId;
                    [self performSegueWithIdentifier:@"showCollection" sender:self];
                    break;
                case 8:
                    _collectionType = 10;
                    _selectedId = _expense.costCategoryId;
                    [self performSegueWithIdentifier:@"showCollection" sender:self];
                    break;
                case 9:
                {
                    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
                    UITextField *txt = (UITextField *)[cell.contentView viewWithTag:14];
                    [txt becomeFirstResponder];
                }
                case 10:
                {
                    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
                    UITextField *txt = (UITextField *)[cell.contentView viewWithTag:15];
                    [txt becomeFirstResponder];
                }
                default:
                    break;
            }
            break;
        case 3: // mileage
            switch ([indexPath row]) {
                case 0:
                    _collectionType = 5;
                    _selectedId = [NSString stringWithFormat:@"%d", _expense.branchId];
                    [self performSegueWithIdentifier:@"showCollection" sender:self];
                    break;
                case 1:
                    _collectionType = 1;
                    _selectedId = [NSString stringWithFormat:@"%d", _expense.departmentId];
                    [self performSegueWithIdentifier:@"showCollection" sender:self];
                    break;
                case 2:
                {
                    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
                    UITextField *txt = (UITextField *)[cell.contentView viewWithTag:13];
                    [txt becomeFirstResponder];
                }
                    break;
                case 4:
                case 5:
                {
                    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
                    UITextView *txt = (UITextView *)[cell.contentView viewWithTag:11];
                    [txt becomeFirstResponder];
                    txt = (UITextView *)[cell.contentView viewWithTag:12];
                    [txt becomeFirstResponder];
                }
                    break;
            }
            break;
        case 4: // receipt
            [self performSegueWithIdentifier:@"showReceipt" sender:self];
            break;
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [textField performSelector:@selector(selectAll:) withObject:nil afterDelay:0.1];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    switch (textField.tag) {
        case 14:
            _expense.totalAmount = [textField.text doubleValue];
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:9 inSection:2]] withRowAnimation:UITableViewRowAnimationNone];
            break;
        case 15:
            _expense.tip = [textField.text doubleValue];
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:10 inSection:2]] withRowAnimation:UITableViewRowAnimationNone];
            break;
    }
}

- (void)textFieldDidChange:(UITextField *)textField {
    switch (textField.tag) {
        case 13:
            _expense.mileage = [textField.text intValue];
            _expense.totalAmount = UTIL.mileageRate1 * _expense.mileage;
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:3 inSection:3]] withRowAnimation:UITableViewRowAnimationNone];
            break;
        case 15:
            _expense.tip = [textField.text doubleValue];
            break;
        case 16:
            _expense.merchant = textField.text;
            break;
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    switch (textView.tag) {
        case 11:
            _expense.comments = textView.text;
            break;
        case 12:
            _expense.destinations = textView.text;
            break;
    }
}

- (void)statusDidChange:(UISwitch *)sender {
   // _expense.distanceType = sender.on;
}

- (void)toggleMethodSelectorCell:(NSIndexPath *)indexPath {
    if ([indexPath section] == 0) {
        _expenseMethodsVisible = !_expenseMethodsVisible;
        
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
        [cell setHidden:!_expenseMethodsVisible];
        cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
        [cell setHidden:!_expenseMethodsVisible];
        
        [UIView animateWithDuration:0.2 animations:^{
            [self.tableView beginUpdates];
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
            [self.tableView endUpdates];
        } completion:^(BOOL finished) {
            if (!self->_expenseMethodsVisible) {
                [self.tableView reloadData];
            }
            
            // hide types
            [self hideTypes];
            
            // hide date picker
            [self hideDatePicker];
        }];
    }
}

- (void)toggleTypeSelectorCell:(NSIndexPath *)indexPath {
    if ([indexPath section] == 0) {
        _expenseTypesVisible = !_expenseTypesVisible;
        
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:0]];
        [cell setHidden:!_expenseTypesVisible];
        cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:5 inSection:0]];
        [cell setHidden:!_expenseTypesVisible];
        
        [UIView animateWithDuration:0.2 animations:^{
            [self.tableView beginUpdates];
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
            [self.tableView endUpdates];
        } completion:^(BOOL finished) {
            if (!self->_expenseTypesVisible) {
                [self.tableView reloadData];
            }
            
            // hide methods
            [self hideMethods];
            
            // hide date picker
            [self hideDatePicker];
        }];
    }
}

- (void)toggleDatePickerCell:(NSIndexPath *)indexPath {
    _expenseDatePickerVisible = !_expenseDatePickerVisible;
    _pickerDate.hidden = !_expenseDatePickerVisible;
    
    [UIView animateWithDuration:0.2 animations:^{
        [self.tableView beginUpdates];
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        [self.tableView endUpdates];
    } completion:^(BOOL finished) {
        // hide methods
        [self hideMethods];
        
        // hide types
        [self hideTypes];
    }];
    
    /*if ([indexPath section] == 0 && [indexPath row] == 3) {
        _expenseDateVisible = !_expenseDateVisible;
        _pickerDate.hidden = !_expenseDateVisible;
        
     
    }*/
}

- (void)hideMethods {
    if (self->_expenseMethodsVisible) {
        self->_expenseMethodsVisible = false;
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
        [cell setHidden:!self->_expenseMethodsVisible];
        cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
        [cell setHidden:!self->_expenseMethodsVisible];
        
        [UIView animateWithDuration:0.2 animations:^{
            [self.tableView beginUpdates];
            [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:YES];
            [self.tableView endUpdates];
        }];
    }
}

- (void)hideTypes {
    if (self->_expenseTypesVisible) {
        self->_expenseTypesVisible = false;
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:0]];
        [cell setHidden:!self->_expenseMethodsVisible];
        cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:5 inSection:0]];
        [cell setHidden:!self->_expenseMethodsVisible];
        
        [UIView animateWithDuration:0.2 animations:^{
            [self.tableView beginUpdates];
            [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0] animated:YES];
            [self.tableView endUpdates];
        }];
    }
}

- (void)hideDatePicker {
    if (self->_expenseDatePickerVisible) {
        self->_expenseDatePickerVisible = false;
        self->_pickerDate.hidden = !self->_expenseDatePickerVisible;
        
        [UIView animateWithDuration:0.2 animations:^{
            [self.tableView beginUpdates];
            [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:5 inSection:0] animated:YES];
            [self.tableView endUpdates];
        }];
    }
}

- (void)dateIsChanged:(id)sender{
    _expense.dateExpense = [UTIL formatDateOnly:_pickerDate.date format:@"yyyy-MM-dd HH:mm:ss"];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:3 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
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

- (void)collectionItemSelected:(NSNotification *)note {
    NSMutableArray *notificationObjects = [[note userInfo] valueForKey:@"collectionItem"];
    
    int type = [[notificationObjects objectAtIndex:0] intValue];
    GenericObject *item = [notificationObjects objectAtIndex:1];
    
    switch (type) {
        case 5: // branch
            _expense.branchId = [item.genericId intValue];
            _expense.branchName = item.value;
            
            _expense.departmentId = 0;
            _expense.departmentName = @"";
            break;
        case 1: // department
            _expense.departmentId = [item.genericId intValue];
            _expense.departmentName = item.value;
            break;
        case 2: // provinces
            _expense.province = item.genericId;
            _expense.provinceName = item.value;
            break;
        case 3: // categories
            _expense.gpCategoryId = [item.genericId intValue];
            _expense.expenseCategoryName = item.value;
            break;
        case 6: // job
        {
            Claim *claim = [notificationObjects objectAtIndex:1];
            _expense.claimIndx = claim.claimIndx;
            _expense.claimName = claim.claimNumber;
        }
            break;
        case 7: // phase
            _expense.phaseIndx = [item.genericId intValue];
            _expense.phaseName = item.value;
            break;
        case 8: // currency
            _expense.currencyId = [item.genericId intValue];
            break;
        case 9: // type
            _expense.typeId = item.genericId;
            _expense.typeName = item.value;
            break;
        case 10: // cost category
            _expense.costCategoryId = item.genericId;
            _expense.costCategoryName = item.value;
            break;
        case 11: // job departments
            _expense.jobDepartmentId = item.genericId;
            _expense.jobDepartmentName = item.value;
            break;
    }
    
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 3)] withRowAnimation:UITableViewRowAnimationFade];
}

 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
     // Get the new view controller using [segue destinationViewController].
     // Pass the selected object to the new view controller.
     
     [self hideMethods];
     [self hideTypes];
     [self hideDatePicker];
     
     if ([[segue identifier] isEqualToString:@"showCollection"]) {
         ExpenseCollectionsViewController *child = (ExpenseCollectionsViewController *)[segue destinationViewController];
         [child setCollectionType:_collectionType];
         [child setSelectedId:_selectedId];
         
         GenericObject *br = [ALLBRANCHES getBranchById:_expense.branchId];
         [child setRegionId:[br.parentId intValue]];
         [child setBranchId:_expense.branchId];
         
         [child setDepartmentId:_expense.jobDepartmentId];
         [child setJobCostTypeId:_expense.typeId];
         
         if (_expense.expenseMethodId == 3) {
             [child setCategoryId:15];
         } else {
             [child setCategoryId:_expense.gpCategoryId];
         }
     }
     if ([[segue identifier] isEqualToString:@"showReceipt"]) {
         ReceiptViewController *child = (ReceiptViewController *)[segue destinationViewController];
         [child setExpenseId:_expense.selfId];
     }
}

- (IBAction)actionsPressed:(id)sender {
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:NSLocalizedStringFromTable(@"choose_action", [UTIL getLanguage], @"") message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    
    if (_expense.expStatus == 1) {
        UIAlertAction *actionSave = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"save", [UTIL getLanguage], @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            [self saveExpense];
        }];
        [actionSheet addAction:actionSave];
        
        UIAlertAction *actionSaveAndRelease = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"save_and_release", [UTIL getLanguage], @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            
        }];
        [actionSheet addAction:actionSaveAndRelease];
        
        if (_expense.selfId > 0 && _expense.expenseMethodId != 1) {
            UIAlertAction *actionDelete = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"delete", [UTIL getLanguage], @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                
            }];
            [actionDelete setValue:[UTIL darkRedColor] forKey:@"titleTextColor"];
            [actionSheet addAction:actionDelete];
        }
    }
    
    if (_expense.selfId == 0 && _expense.expenseMethodId == 2) {
        UIAlertAction *actionSplit = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"split", [UTIL getLanguage], @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            
        }];
        [actionSheet addAction:actionSplit];
    }
    
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"cancel", [UTIL getLanguage], @"") style:UIAlertActionStyleCancel handler:nil];
    [actionCancel setValue:[UTIL darkRedColor] forKey:@"titleTextColor"];
    [actionSheet addAction:actionCancel];
    
    if (IS_IPAD()) {
        UIPopoverPresentationController *popoverPresentationController = [actionSheet popoverPresentationController];
        popoverPresentationController.barButtonItem = _actionsButton;
        [actionSheet setModalPresentationStyle:UIModalPresentationPopover];
    }
    
    [self presentViewController:actionSheet animated:YES completion:nil];
}

- (void)saveExpense {
    [UTIL showActivity:@""];
    
    [_expense save:^(NSMutableArray *result) {
        [UTIL hideActivity];
        NSString *error = ([result valueForKey:@"error"]) ? [NSString stringWithFormat:@"%@", [result valueForKey:@"error"]] : @"";
        
        if ([error isEqualToString: @""]) {
            NSMutableArray *responseData = [result valueForKey:@"saveExpenseResult"];
            if (responseData == nil) {
                [ALERT alertWithTitle:NSLocalizedStringFromTable(@"error", [UTIL getLanguage], @"") message:NSLocalizedStringFromTable(@"error_save_expense", [UTIL getLanguage], @"")];
            } else {
                [self.navigationController popViewControllerAnimated:YES];
            }
        } else {
            [ALERT alertWithTitle:NSLocalizedStringFromTable(@"error", [UTIL getLanguage], @"") message:error];
        }
    }];
}

@end
