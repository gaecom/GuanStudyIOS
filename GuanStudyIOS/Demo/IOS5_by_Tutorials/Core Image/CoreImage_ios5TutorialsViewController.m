//
//  CoreImage_ios5TutorialsViewController.m
//  GuanStudyIOS
//
//  Created by macmini on 13-12-25.
//  Copyright (c) 2013 城云 官. All rights reserved.
//

#import "CoreImage_ios5TutorialsViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "UIImage+Resize.h"

@interface CoreImage_ios5TutorialsViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *ScrollView;

@end

@implementation CoreImage_ios5TutorialsViewController{
    CIContext *context;
    CIFilter *filter;
    CIImage *beginImage;
    CIImage *maskImage;
    CGContextRef cgcontext;
    NSArray * filtersArray;
    NSUInteger indx;
}

@synthesize filterTitle;
@synthesize maskModeButton;
@synthesize amountSlider;

@synthesize imgV;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)logAllFilters {
    NSArray *properties = [CIFilter filterNamesInCategory:kCICategoryBuiltIn];
    NSLog(@"%@", properties);
    for (NSString *filterName in properties) {
        CIFilter *fltr = [CIFilter filterWithName:filterName];
        NSLog(@"%@", [fltr attributes]);
    }
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.ScrollView setContentSize:CGSizeMake(self.ScrollView.frame.size.width, self.ScrollView.frame.size.height)];
}
-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    [self.ScrollView setContentSize:CGSizeMake(self.view.frame.size.width, 550)];
}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self.ScrollView setContentSize:CGSizeMake(self.view.frame.size.width, 550)];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
 
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"image" ofType:@"png"];
    NSURL *fileNameAndPath = [NSURL fileURLWithPath:filePath];
    
    beginImage = [CIImage imageWithContentsOfURL:fileNameAndPath];
    context = [CIContext contextWithOptions:nil];
    maskImage = [CIImage imageWithCGImage:[UIImage imageNamed:@"sampleMaskPng.png"].CGImage];
    
    filter = [CIFilter filterWithName:@"CISepiaTone" keysAndValues:kCIInputImageKey, beginImage, @"inputIntensity", [NSNumber numberWithFloat:0.8], nil];
    CIImage *outputImage = [filter outputImage];
    
    CGImageRef cgimg = [context createCGImage:outputImage fromRect:[outputImage extent]];
    UIImage *newImg = [UIImage imageWithCGImage:cgimg];
    
    [imgV setImage:newImg];
    CGImageRelease(cgimg);
    
//    [self logAllFilters];
    
    [self setupCGContext];
    
    CIFilter *affineTransform = [CIFilter filterWithName:@"CIAffineTransform" keysAndValues:kCIInputImageKey, beginImage, @"inputTransform", [NSValue valueWithCGAffineTransform:CGAffineTransformMake(1.0, 0.4, 0.5, 1.0, 0.0, 0.0)], nil];
    CIFilter *straightenFilter = [CIFilter filterWithName:@"CIStraightenFilter" keysAndValues:kCIInputImageKey, beginImage, @"inputAngle", [NSNumber numberWithFloat:2.0], nil];
    CIFilter *vibrance = [CIFilter filterWithName:@"CIVibrance" keysAndValues:kCIInputImageKey, beginImage, @"inputAmount", [NSNumber numberWithFloat:-0.85], nil];
    CIFilter *colorControls = [CIFilter filterWithName:@"CIColorControls" keysAndValues:kCIInputImageKey, beginImage, @"inputBrightness", [NSNumber numberWithFloat:-0.5], @"inputContrast", [NSNumber numberWithFloat:3.0], @"inputSaturation", [NSNumber numberWithFloat:1.5], nil];
    CIFilter *colorInvert = [CIFilter filterWithName:@"CIColorInvert" keysAndValues:kCIInputImageKey, beginImage, nil];
    CIFilter *highlightsAndShadows = [CIFilter filterWithName:@"CIHighlightShadowAdjust" keysAndValues:kCIInputImageKey, beginImage, @"inputShadowAmount", [NSNumber numberWithFloat:1.5], @"inputHighlightAmount", [NSNumber numberWithFloat:0.2], nil];
    
    filtersArray = [NSArray arrayWithObjects:affineTransform, straightenFilter, vibrance, colorControls, colorInvert, highlightsAndShadows, nil];
    indx = 0;

}

- (IBAction)changeValue:(UISlider *)sender {
    float slideValue = sender.value;
    
    [filter setValue:[NSNumber numberWithFloat:slideValue] forKey:@"inputIntensity"];
    CIImage *outputImage = [filter outputImage];
    
    if ([maskModeButton.titleLabel.text isEqualToString:@"Mask Mode Off"]) {
        CIFilter *maskFilter = [CIFilter filterWithName:@"CISourceAtopCompositing" keysAndValues:kCIInputImageKey, outputImage, @"inputBackgroundImage", maskImage, nil];
        outputImage = maskFilter.outputImage;
    }
    
    outputImage = [self addBackgroundLayer:outputImage];
    CGImageRef cgimg = [context createCGImage:outputImage fromRect:[outputImage extent]];
    UIImage *newImg = [UIImage imageWithCGImage:cgimg];
    [imgV setImage:newImg];
    CGImageRelease(cgimg);
    
    [filterTitle setText:@"Sepia Tone Composite"];
}

- (IBAction)loadPhoto:(id)sender {
    UIImagePickerController *pickerC = [[UIImagePickerController alloc] init];
    pickerC.delegate = self;
    [self presentViewController:pickerC animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [self dismissViewControllerAnimated:YES completion:nil];
    UIImage *gotImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    gotImage = [gotImage scaleToSize:[beginImage extent ].size];
    beginImage = [CIImage imageWithCGImage:gotImage.CGImage];
    [filter setValue:beginImage forKey:kCIInputImageKey];
    [self performSelectorInBackground:@selector(hasFace:) withObject:beginImage];
    [self changeValue:amountSlider];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)savePhoto:(id)sender {
    CIImage *saveToSave = [filter outputImage];
    CGImageRef cgImg = [context createCGImage:saveToSave fromRect:[saveToSave extent]];
    ALAssetsLibrary* library = [[ALAssetsLibrary alloc] init];
    [library writeImageToSavedPhotosAlbum:cgImg metadata:[saveToSave properties] completionBlock:^(NSURL *assetURL, NSError *error) {
        CGImageRelease(cgImg);
    }];
}

- (IBAction)maskMode:(id)sender {
    
    CIFilter *maskFilter = [CIFilter filterWithName:@"CISourceAtopCompositing" keysAndValues:kCIInputImageKey, [filter outputImage], @"inputBackgroundImage", maskImage, nil];
    
    CIImage *outputImage = [maskFilter outputImage];
    
    if ([maskModeButton.titleLabel.text isEqualToString:@"Mask Mode Off"]) {
        [maskModeButton setTitle:@"Mask Mode" forState:UIControlStateNormal];
        outputImage = [filter outputImage];
    } else {
        [maskModeButton setTitle:@"Mask Mode Off" forState:UIControlStateNormal];
    }
    
    outputImage = [self addBackgroundLayer:outputImage];
    CGImageRef cgImg = [context createCGImage:outputImage fromRect:[outputImage extent]];
    
    [imgV setImage:[UIImage imageWithCGImage:cgImg]];
    CGImageRelease(cgImg);
}

-(CIImage *)addBackgroundLayer:(CIImage *)inputImage {
    CIImage *bg = [CIImage imageWithCGImage:[UIImage imageNamed:@"bryce.png"].CGImage];
    CIFilter *sourceOver = [CIFilter filterWithName:@"CISourceOverCompositing" keysAndValues:kCIInputImageKey, inputImage, @"inputBackgroundImage", bg, nil];
    return sourceOver.outputImage;
}

-(void)setupCGContext {
    NSUInteger width = 320;
    NSUInteger height = 213;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    cgcontext = CGBitmapContextCreate(NULL, width, height, bitsPerComponent, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    CGColorSpaceRelease(colorSpace);
}

-(CGImageRef)drawMyCircleMask:(CGPoint)location reset:(BOOL)reset {
    if (reset) {
        CGContextClearRect(cgcontext, CGRectMake(0, 0, 320, 213));
    }
    
    CGContextSetRGBFillColor(cgcontext, 1, 1, 1, .7);
    CGContextFillEllipseInRect(cgcontext, CGRectMake(location.x - 25, location.y - 25, 50.0, 50.0));
    
    CGImageRef cgImg = CGBitmapContextCreateImage(cgcontext);
    
    return cgImg;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    CGPoint loc = [[touches anyObject] locationInView:imgV];
    if (loc.y <= 213 && loc.y >= 0) {
        loc = CGPointMake(loc.x, imgV.frame.size.height - loc.y);
        CGImageRef cgimg = [self drawMyCircleMask:loc reset:YES];
        maskImage = [CIImage imageWithCGImage:cgimg];
        [self changeValue:amountSlider];
        CGImageRelease(cgimg);
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    CGPoint loc = [[touches anyObject] locationInView:imgV];
    if (loc.y <= 213 && loc.y >= 0) {
        loc = CGPointMake(loc.x, imgV.frame.size.height - loc.y);
        CGImageRef cgimg = [self drawMyCircleMask:loc reset:NO];
        maskImage = [CIImage imageWithCGImage:cgimg];
        [self changeValue:amountSlider];
        CGImageRelease(cgimg);
    }
}

-(CIImage *)createBox:(CGPoint)loc color:(CIColor *)color {
    CIImage *colorFil = [CIFilter filterWithName:@"CIConstantColorGenerator" keysAndValues:@"inputColor", color, nil].outputImage;
    return [CIFilter filterWithName:@"CICrop" keysAndValues:kCIInputImageKey, colorFil, @"inputRectangle", [CIVector vectorWithCGRect:CGRectMake(loc.x - 3, loc.y - 3, 6, 6)], nil].outputImage;
}

- (void)filteredFace:(NSArray *)features {
    
    CIImage *outputImage = beginImage;
    for (CIFaceFeature *f in features) {
        if (f.hasLeftEyePosition) {
            outputImage = [CIFilter filterWithName:@"CISourceAtopCompositing" keysAndValues:kCIInputImageKey, [self createBox:CGPointMake(f.leftEyePosition.x, f.leftEyePosition.y) color:[CIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.7]], kCIInputBackgroundImageKey, outputImage, nil].outputImage;
        }
        if (f.hasRightEyePosition) {
            outputImage = [CIFilter filterWithName:@"CISourceAtopCompositing" keysAndValues:kCIInputImageKey, [self createBox:CGPointMake(f.rightEyePosition.x, f.rightEyePosition.y) color:[CIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.7]], kCIInputBackgroundImageKey, outputImage, nil].outputImage;
        }
        if (f.hasMouthPosition) {
            outputImage = [CIFilter filterWithName:@"CISourceAtopCompositing" keysAndValues:kCIInputImageKey, [self createBox:CGPointMake(f.mouthPosition.x, f.mouthPosition.y) color:[CIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:0.7]], kCIInputBackgroundImageKey, outputImage, nil].outputImage;
        }
    }
    
    [filter setValue:outputImage forKey:kCIInputImageKey];
    [self changeValue:amountSlider];
}

- (void)hasFace:(CIImage *)image {
    CIDetector *faceDetector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:[NSDictionary dictionaryWithObjectsAndKeys:CIDetectorAccuracyHigh, CIDetectorAccuracy, nil]];
    NSArray *features = [faceDetector featuresInImage:image];
    [self filteredFace:features];
}

- (IBAction)rotateFilter:(id)sender {;
    CIFilter *filt = [filtersArray objectAtIndex:indx];
    CGImageRef imgRef = [context createCGImage:[filt outputImage] fromRect:[[filt outputImage] extent]];
    [imgV setImage:[UIImage imageWithCGImage:imgRef]];
    CGImageRelease(imgRef);
    indx = (indx + 1) % [filtersArray count];
    [filterTitle setText:[[filt attributes ] valueForKey:@"CIAttributeFilterDisplayName"]];
}

- (IBAction)autoEnhance:(id)sender {
    CIImage *outputImage = beginImage;
    NSArray *ar = [beginImage autoAdjustmentFilters];
    for (CIFilter *fil in ar) {
        [fil setValue:outputImage forKey:kCIInputImageKey];
        outputImage = fil.outputImage;
        NSLog(@"%@", [[fil attributes] valueForKey:@"CIAttributeFilterDisplayName"]);
    }
    [filter setValue:outputImage forKey:kCIInputImageKey];
    [self changeValue:amountSlider];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
