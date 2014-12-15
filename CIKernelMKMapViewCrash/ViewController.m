//
//  ViewController.m
//  CIKernelMKMapViewCrash
//
//  Created by Rolf Bjarne Kvinge on 15/12/14.
//  Copyright (c) 2014 me. All rights reserved.
//

#import "ViewController.h"
#import <CoreImage/CoreImage.h>
#import <MapKit/MapKit.h>

@interface CustomFilter : CIFilter
@property (nonatomic, strong) CIImage *inputImage;
@end
@implementation CustomFilter

- (CIColorKernel *)myKernel {
    static CIColorKernel *kernel = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        kernel = [CIColorKernel kernelWithString:@"kernel vec4 doNothing ( __sample s) { return s.rgba; }"];
    });
    return kernel;
}

- (CIImage *)outputImage
{
    CGRect dod = self.inputImage.extent;
    return [[self myKernel] applyWithExtent:dod
                                  arguments:@[self.inputImage]];
}

@end

@interface ViewController ()
@end

@implementation ViewController

void func ()
{
    NSString *path = [NSString stringWithFormat:@"%@/114_icon.png", [[NSBundle mainBundle] bundlePath]];
    UIImage *img =  [UIImage imageWithContentsOfFile:path];
    CustomFilter *filter = [[CustomFilter alloc] init];
    
    CIImage *ciImage = [[CIImage alloc] initWithImage: img];
    filter.inputImage = ciImage;
    
    // apply
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *outputImage = [filter outputImage];
    CGImageRef cgImage = [context createCGImage:outputImage
                                       fromRect:[outputImage extent]];
//    UIImage *image = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    
    NSLog (@"%@",[[MKMapView alloc] init]);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    dispatch_async (dispatch_get_main_queue(), ^{
        func ();
    });
    
    // Wait a second for the next one. If executed too soon, the crash doesn't occur.
    dispatch_after (dispatch_time (DISPATCH_TIME_NOW, 1000000000), dispatch_get_main_queue(), ^{
        func ();
    });
}



@end
