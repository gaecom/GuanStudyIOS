//
//  FlowViewController.m
//  StudyiOS
//
//  Created by ZhangYiCheng on 12-12-6.
//  Copyright (c) 2012年 ZhangYiCheng. All rights reserved.
//

#import "FlowViewController.h"
#import "FlowViewCell.h"
#import "DefineViewController.h"

@interface FlowViewController ()

@end

@implementation FlowViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _items = @[];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.backgroundColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1.0];
    
//    CGFloat width = [[self.items[indexPath.row] objectForKey:@"width"] floatValue];
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
    return [self.items count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [FlowViewCell heightForCell:self.items[indexPath.row]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    FlowViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    [cell setCell:[self.items objectAtIndex:[indexPath row]]];
    cell.flowViewCellDelegate = self;
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - FlowViewCellDelegate
- (void)flowViewCell:(FlowViewCell *)cell startDemo:(NSString *)demoUUID Introduction:(NSString *)introduction{
    BaseViewController *Xib_VC = nil;
    BOOL isAnimate = YES;
    if ([demoUUID isEqualToString:@"Core Image"]) {
        Xib_VC = [[CoreImage_ios5TutorialsViewController alloc]initWithNibName:@"CoreImage_ios5TutorialsViewController" bundle:nil];
    }else if([demoUUID isEqualToString:@"MapKit_ios6"]){
        Xib_VC = [[MapKit_ios6ViewController alloc]initWithNibName:@"MapKit_ios6ViewController" bundle:nil];
    }
   
    if (Xib_VC) {
        if ([[[[UIDevice currentDevice] systemVersion] substringToIndex:1] intValue] >= 6) {
            Xib_VC.title = demoUUID;
            Xib_VC.Introduction = introduction;
            [self.navigationController pushViewController:Xib_VC animated:isAnimate];
        }
        return;
    }
   
    UIStoryboard *storyboard = nil;
    if ([demoUUID isEqualToString:@"Theme_ios6"]) {
        storyboard = [UIStoryboard storyboardWithName:@"Theme_ios6" bundle:nil];
    }
    if (storyboard) {
        [self.navigationController pushViewController:storyboard.instantiateInitialViewController animated:YES];
        
    }
}



@end
