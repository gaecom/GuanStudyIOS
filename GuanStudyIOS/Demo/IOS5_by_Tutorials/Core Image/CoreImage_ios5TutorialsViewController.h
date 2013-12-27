//
//  CoreImage_ios5TutorialsViewController.h
//  GuanStudyIOS
//
//  Created by macmini on 13-12-25.
//  Copyright (c) 2013 城云 官. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface CoreImage_ios5TutorialsViewController : BaseViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate,UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imgV;
- (IBAction)changeValue:(UISlider *)sender;
- (IBAction)loadPhoto:(id)sender;
@property (weak, nonatomic) IBOutlet UISlider *amountSlider;
- (IBAction)savePhoto:(id)sender;
- (IBAction)maskMode:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *maskModeButton;

-(CIImage *)addBackgroundLayer:(CIImage *)inputImage;
-(void)setupCGContext;
@property (weak, nonatomic) IBOutlet UILabel *filterTitle;
- (IBAction)rotateFilter:(id)sender;
- (IBAction)autoEnhance:(id)sender;

@end
