//
//  ViewController.h
//  AudioVideoComposition
//
//  Created by Gagan on 22/05/14.
//  Copyright (c) 2014 Gagan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import <QuartzCore/QuartzCore.h>
@interface ViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *labelWorking;
@property (weak, nonatomic) IBOutlet UIButton *payAndCreateButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorr;
- (IBAction)CreateComposition:(id)sender;
- (IBAction)MergeVideos:(id)sender;
- (IBAction)MoveToParallelPlay:(id)sender;
- (IBAction)AddWaterMarkTextAndImage:(id)sender;
@end
