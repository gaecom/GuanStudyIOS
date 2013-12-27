//
//  Main_iPhoneTableViewController.m
//  GuanStudyIOS
//
//  Created by macmini on 13-12-24.
//  Copyright (c) 2013 城云 官. All rights reserved.
//

#import "Main_iPhoneTableViewController.h"
#import "FlowViewController.h"

@interface Main_iPhoneTableViewController ()

@end

@implementation Main_iPhoneTableViewController
@synthesize items_All;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self setTitle:NSLocalizedString(@"Main_iPhone", nil)];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Main_iPhoneTableViewController.plist" ofType:nil];
    self.items_All = [NSArray arrayWithContentsOfFile:path];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.items_All count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    NSDictionary *dic = self.items_All[indexPath.row];
    cell.textLabel.text = dic[@"name"];
    cell.imageView.image = [UIImage imageNamed:dic[@"type"]];
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *str_type = self.items_All[indexPath.row][@"type"];
   
    if ([str_type isEqualToString:@"pdfStudy"]) {
         [self performSegueWithIdentifier:@"classflow" sender:nil];
    }
}

#pragma mark - Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"classflow"]) {
        NSIndexPath *path = [self.tableView indexPathForSelectedRow];
        NSDictionary *dic = self.items_All[path.row];
        NSMutableArray *mutItems = [@[] mutableCopy];
        mutItems = dic[@"items"];
        if ([mutItems count]>0) {
            NSString *title = dic[@"name"];
            FlowViewController *vc = (FlowViewController *)segue.destinationViewController;
            [vc setTitle:title];
            [vc setItems:mutItems];
        }
    }
}


-(void)didSelecTypePdfStudy:(NSString *)name{
    if ([name isEqualToString:@"iOS5_by_Tutorials.pdf"]) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"iOS5_by_Tutorials" bundle:nil];
        [self.navigationController pushViewController:storyboard.instantiateInitialViewController animated:YES];
    }else if([name isEqualToString:@"iOS7_by_Tutorials.pdf"]){
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"iOS6_by_Tutorials" bundle:nil];
        [self.navigationController pushViewController:storyboard.instantiateInitialViewController animated:YES];
    }else if([name isEqualToString:@"iOS7_by_Tutorials.pdf"]){
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"iOS7_by_Tutorials" bundle:nil];
        [self.navigationController pushViewController:storyboard.instantiateInitialViewController animated:YES];
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
