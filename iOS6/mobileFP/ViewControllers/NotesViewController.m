//
//  NotesViewController.m
//  mobileFP
//
//  Created by Ashot Navasardyan on 12/6/14.
//  Copyright (c) 2014 FirstOnSite. All rights reserved.
//

#import "NotesViewController.h"
#import "NoteDetailsViewController.h"
#import "ClaimNoteViewController.h"

@interface NotesViewController ()

@end

@implementation NotesViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Custom initialization
        self.claim = [[Claim alloc] init];
        self.notes = [[NSMutableArray alloc] init];
        self.notesLoaded = false;
        self.reload = false;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = YES;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self setTitle:NSLocalizedStringFromTable(@"notes", [UTIL getLanguage], @"")];
    
    _notesLoaded = false;
    
    [UTIL showActivity:NSLocalizedStringFromTable(@"loading_notes", [UTIL getLanguage], @"")];
    [self performSelector:@selector(loadNotes) withObject:nil afterDelay:0.1f];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (_reload) {
        _reload = false;
        [UTIL showActivity:NSLocalizedStringFromTable(@"loading_notes", [UTIL getLanguage], @"")];
        [self performSelector:@selector(loadNotes) withObject:nil afterDelay:0.1f];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadNotes {
    _notes = [[NSMutableArray alloc] init];
    [API getJobNotes:USER.sessionId regionId:USER.regionId claimIndex:_claim.claimIndx phaseIndex:0 departmentCode:@"" page:1 completion:^(NSMutableArray *result) {
        [UTIL hideActivity];
        
        NSString *error = @"";
        if ([result valueForKey:@"error"]) {
            error = [NSString stringWithFormat:@"%@", [result valueForKey:@"error"]];
        }
        
        if ([error isEqualToString: @""]) {
            NSMutableArray *responseData = [result valueForKey:@"get_JobNotesResult"];
            if ([responseData valueForKey:@"items"] && [responseData valueForKey:@"items"] != [NSNull null]) {
                NSMutableArray *itemsData = [responseData valueForKey:@"items"];
                for (id item in itemsData) {
                    Note *note = [[Note alloc] init];
                    [note initWithData:item];
                    [self->_notes addObject:note];
                }
            }
        } else {
            [ALERT alertWithTitle:NSLocalizedStringFromTable(@"error", [UTIL getLanguage], @"") message:error];
        }
        
        self->_notesLoaded = true;
        [self.tableView reloadData];
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return _notes.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *title = @"";
    
    if ([_notes count] == 0 && _notesLoaded) {
        title = [NSString stringWithFormat:NSLocalizedStringFromTable(@"no_notes_for_", [UTIL getLanguage], @""), _claim.claimNumber];
    }
    
    return title;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"noteItem" forIndexPath:indexPath];
    
    Note *note = [_notes objectAtIndex:[indexPath row]];
    
    NSRange range = [note.note rangeOfString:@"\r\n"];
    NSString *replacedString = note.note;
    if (range.length > 0) {
        replacedString = [note.note stringByReplacingCharactersInRange:range withString:@""];
    }
    
    NSString *details = [NSString stringWithFormat:@"%@\n%@", [UTIL trim:note.dateCreated], [UTIL trim:replacedString]];
    if (![note.phase.phaseCode isEqual: @""]) {
        details = [NSString stringWithFormat:@"%@ (%@)\n%@", [UTIL trim:note.dateCreated], [UTIL trim:note.phase.phaseCode], [UTIL trim:replacedString]];
    }
    
    UILabel *lbl = (UILabel *)[cell.contentView viewWithTag:1];
    [lbl setText:note.enteredBy.fullName];
    
    lbl = (UILabel *)[cell.contentView viewWithTag:2];
    [lbl setText:details];
    
    /*[cell.textLabel setText:note.enteredBy.fullName];
    [cell.detailTextLabel setNumberOfLines:1];
    [cell.detailTextLabel setText:details];
    
    [cell.detailTextLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [cell.detailTextLabel sizeToFit];*/
    
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    _selectedNote = [_notes objectAtIndex:[indexPath row]];
    [self performSegueWithIdentifier:@"showDetails" sender:self];
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
    if ([[segue identifier] isEqualToString:@"showDetails"]) {
        NoteDetailsViewController *child = (NoteDetailsViewController *)[segue destinationViewController];
        _selectedNote.claim = _claim;
        [child setNote:_selectedNote];
    }
    if ([[segue identifier] isEqualToString:@"showNew"]) {
        ClaimNoteViewController *child = (ClaimNoteViewController *)[segue destinationViewController];
        [child setClaim:_claim];
    }
}

- (IBAction)addPressed:(id)sender {
    [self performSegueWithIdentifier:@"showNew" sender:self];
}

@end
