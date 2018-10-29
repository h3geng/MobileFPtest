//
//  PhotoNotesViewController.m
//  mobileFP
//
//  Created by Ashot Navasardyan on 2017-06-01.
//  Copyright © 2017 FirstOnSite. All rights reserved.
//

#import "PhotoNotesViewController.h"

@interface PhotoNotesViewController ()

@end

@implementation PhotoNotesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setTitle:NSLocalizedStringFromTable(@"description", [UTIL getLanguage], @"")];
    
    // init db manager
    _dbManager = [[DBManager alloc] initWithDatabaseFilename:@"pendingdb.sql"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    @try {
        NSString *query = [NSString stringWithFormat:@"select photo from photoInfo where selfId=%d", _selfId];
        NSArray *arrPhotoInfo = [[NSArray alloc] initWithArray:[_dbManager loadDataFromDB:query]];
        
        for (id dbItem in arrPhotoInfo) {
            NSInteger indexOfPhoto = [_dbManager.arrColumnNames indexOfObject:@"photo"];
            [_imageView setImage:[UTIL loadImage:[dbItem objectAtIndex:indexOfPhoto]]];
            [_textView setText:_notes];
        }
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
    
    [_textView becomeFirstResponder];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)donePressed:(id)sender {
    /*UIViewController *parent = [APP_DELEGATE getPreviousScreen];
    
    ClaimNewPhotosViewController *child = (ClaimNewPhotosViewController *)parent;
    [child.selectedPhoto setPhotoDescription:_textView.text];*/
    
    NSString *query = [NSString stringWithFormat:@"update photoInfo set photoDescription='%@' where selfId=%d", _textView.text, _selfId];
    [_dbManager executeQuery:query];
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
