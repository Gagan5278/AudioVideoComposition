//
//  ViewController.m
//  AudioVideoComposition
//
//  Created by Gagan on 22/05/14.
//  Copyright (c) 2014 Gagan. All rights reserved.
//

#import "ViewController.h"
#import "ParallelPlayer.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)CreateComposition:(id)sender {
    [self.activityIndicatorr startAnimating];
    self.labelWorking.hidden=NO;
    AVURLAsset *audioURLAsset=[AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle]pathForResource:@"audio" ofType:@"mp3"]] options:nil];
    AVURLAsset *videoURLAsset=[AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle]pathForResource:@"video" ofType:@"mp4"]] options:nil];
    AVMutableComposition *mixComposition=[AVMutableComposition composition];
    
    //Create Audio Composition Track
    AVMutableCompositionTrack *audioTrack=[mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid ];
    [audioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, audioURLAsset.duration) ofTrack:[[audioURLAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] atTime:kCMTimeZero error:nil];
    
    //Create Video Composition Track
    AVMutableCompositionTrack *videoTrack=[mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    [videoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoURLAsset.duration) ofTrack:[[videoURLAsset tracksWithMediaType:AVMediaTypeVideo]objectAtIndex:0] atTime:kCMTimeZero error:nil];
    
    AVAssetExportSession *exportSession=[[AVAssetExportSession alloc]initWithAsset:mixComposition presetName:AVAssetExportPresetPassthrough];
    exportSession.outputFileType=@"com.apple.quicktime-movie";
    NSString *fileName=@"OutPutMixAudioVideoFile.mov";
    NSString *outputPath=[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:fileName];
    if([[NSFileManager defaultManager]fileExistsAtPath:outputPath])  
    {
        [[NSFileManager defaultManager]removeItemAtPath:outputPath error:nil];  //Remove file if already exist
    }
    exportSession.outputURL=[NSURL fileURLWithPath:outputPath];    //Set file url as output url
    exportSession.shouldOptimizeForNetworkUse=YES;                                //movie should be optimized for network use 
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        switch ([exportSession status]) {
            case AVAssetExportSessionStatusFailed:
                NSLog(@"Failed");
                break;
            case AVAssetExportSessionStatusCancelled:
                break;
                
            case AVAssetExportSessionStatusCompleted:
                NSLog(@"Export complete");
                break;
                
            default:
                break;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.activityIndicatorr stopAnimating];
            self.labelWorking.hidden=YES;
        });
    }];
}

- (IBAction)MergeVideos:(id)sender {
    [self.activityIndicatorr startAnimating];
    self.labelWorking.hidden=NO;

    AVURLAsset *firstVideoAsset=[AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle]pathForResource:@"Charts" ofType:@"mp4"]] options:nil];
    AVURLAsset *secondVideoAsset=[AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle]pathForResource:@"video" ofType:@"mp4"]] options:nil];
    AVMutableComposition* mixComposition = [[AVMutableComposition alloc] init];
    
    //First video track
    AVMutableCompositionTrack *firstVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    [firstVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, firstVideoAsset.duration) ofTrack:[[firstVideoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:kCMTimeZero error:nil];
    //Second Video track
    AVMutableCompositionTrack *secondVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    [secondVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, secondVideoAsset.duration) ofTrack:[[secondVideoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:firstVideoAsset.duration error:nil];
    
     //Create 
    AVMutableVideoCompositionInstruction * mainInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeAdd(firstVideoAsset.duration, secondVideoAsset.duration));
    
    //Check for First video orientation 
    AVMutableVideoCompositionLayerInstruction *FirstlayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:firstVideoTrack];
    AVAssetTrack *firstVideoAssetTrack = [[firstVideoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    UIImageOrientation firstVideoAssetOrientation_  = UIImageOrientationUp;
    BOOL  isfirstVideoAssetPortrait_  = NO;
    CGAffineTransform firstTransform = firstVideoAssetTrack.preferredTransform;
    if(firstTransform.a == 0 && firstTransform.b == 1.0 && firstTransform.c == -1.0 && firstTransform.d == 0)
      {
          firstVideoAssetOrientation_= UIImageOrientationRight; isfirstVideoAssetPortrait_ = YES;
      }
    if(firstTransform.a == 0 && firstTransform.b == -1.0 && firstTransform.c == 1.0 && firstTransform.d == 0)
    {
        firstVideoAssetOrientation_ =  UIImageOrientationLeft; isfirstVideoAssetPortrait_ = YES;
    }
    if(firstTransform.a == 1.0 && firstTransform.b == 0 && firstTransform.c == 0 && firstTransform.d == 1.0)
    {
        firstVideoAssetOrientation_ =  UIImageOrientationUp;
    }
    if(firstTransform.a == -1.0 && firstTransform.b == 0 && firstTransform.c == 0 && firstTransform.d == -1.0)
    {
        firstVideoAssetOrientation_ = UIImageOrientationDown;
    }
    CGFloat firstVideoAssetScaleToFitRatio = 320.0/firstVideoAssetTrack.naturalSize.width;
    if(isfirstVideoAssetPortrait_){   //Check whether first video in potrait mode
        firstVideoAssetScaleToFitRatio = 320.0/firstVideoAssetTrack.naturalSize.height;
        CGAffineTransform firstVideoAssetScaleFactor = CGAffineTransformMakeScale(firstVideoAssetScaleToFitRatio,firstVideoAssetScaleToFitRatio);
        [FirstlayerInstruction setTransform:CGAffineTransformConcat(firstVideoAssetTrack.preferredTransform, firstVideoAssetScaleFactor) atTime:kCMTimeZero];
    }else{
        CGAffineTransform firstVideoAssetScaleFactor = CGAffineTransformMakeScale(firstVideoAssetScaleToFitRatio,firstVideoAssetScaleToFitRatio);
        [FirstlayerInstruction setTransform:CGAffineTransformConcat(CGAffineTransformConcat(firstVideoAssetTrack.preferredTransform, firstVideoAssetScaleFactor),CGAffineTransformMakeTranslation(0, 160)) atTime:kCMTimeZero];
    }
    [FirstlayerInstruction setOpacity:0.0 atTime:firstVideoAsset.duration];
    
    //Check for second video orientation
    AVMutableVideoCompositionLayerInstruction *SecondlayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:secondVideoTrack];
    AVAssetTrack *secondVideoAssetTrack = [[secondVideoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    UIImageOrientation secondVideoAssetOrientation_  = UIImageOrientationUp;
    BOOL  issecondVideoAssetPortrait_  = NO;
    CGAffineTransform secondTransform = secondVideoAssetTrack.preferredTransform;
    if(secondTransform.a == 0 && secondTransform.b == 1.0 && secondTransform.c == -1.0 && secondTransform.d == 0)
    {
        secondVideoAssetOrientation_= UIImageOrientationRight;
        issecondVideoAssetPortrait_ = YES;
    }
    if(secondTransform.a == 0 && secondTransform.b == -1.0 && secondTransform.c == 1.0 && secondTransform.d == 0)
    {
        secondVideoAssetOrientation_ =  UIImageOrientationLeft;
        issecondVideoAssetPortrait_ = YES;
    }
    if(secondTransform.a == 1.0 && secondTransform.b == 0 && secondTransform.c == 0 && secondTransform.d == 1.0)
    {
        secondVideoAssetOrientation_ =  UIImageOrientationUp;
    }
    if(secondTransform.a == -1.0 && secondTransform.b == 0 && secondTransform.c == 0 && secondTransform.d == -1.0)
    {
        secondVideoAssetOrientation_ = UIImageOrientationDown;
    }
    CGFloat secondVideoAssetScaleToFitRatio = 320.0/secondVideoAssetTrack.naturalSize.width;
    if(issecondVideoAssetPortrait_){
        secondVideoAssetScaleToFitRatio = 320.0/secondVideoAssetTrack.naturalSize.height;
        CGAffineTransform secondVideoAssetScaleFactor = CGAffineTransformMakeScale(secondVideoAssetScaleToFitRatio,secondVideoAssetScaleToFitRatio);
        [SecondlayerInstruction setTransform:CGAffineTransformConcat(secondVideoAssetTrack.preferredTransform, secondVideoAssetScaleFactor) atTime:firstVideoAsset.duration];
    }else{
        CGAffineTransform secondVideoAssetScaleFactor = CGAffineTransformMakeScale(secondVideoAssetScaleToFitRatio,secondVideoAssetScaleToFitRatio);
        [SecondlayerInstruction setTransform:CGAffineTransformConcat(CGAffineTransformConcat(secondVideoAssetTrack.preferredTransform, secondVideoAssetScaleFactor),CGAffineTransformMakeTranslation(0, 160)) atTime:firstVideoAsset.duration];
    }
    mainInstruction.layerInstructions = [NSArray arrayWithObjects:FirstlayerInstruction,SecondlayerInstruction,nil];     //Add into two layers into layerInstructions
    
    AVMutableVideoComposition *mainComposition = [AVMutableVideoComposition videoComposition];
    mainComposition.instructions = [NSArray arrayWithObject:mainInstruction];
    mainComposition.frameDuration = CMTimeMake(1, 30);
    mainComposition.renderSize = CGSizeMake(320.0, 480.0);
    
    NSString *myOutputVideo =  [[NSHomeDirectory()  stringByAppendingPathComponent:@"Documents" ]stringByAppendingPathComponent:@"mergeVideoOutput.mov"]; //Path to save file in DocumentDirectory
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetHighestQuality];
    exporter.outputURL=[NSURL fileURLWithPath:myOutputVideo];
    exporter.outputFileType = AVFileTypeQuickTimeMovie;       //Or we can set as @"com.apple.quicktime-movie";
    exporter.videoComposition = mainComposition;  //Set mainComposition to AVAssetExportSessions
    exporter.shouldOptimizeForNetworkUse = YES;
    [exporter exportAsynchronouslyWithCompletionHandler:^
     {
         switch ([exporter status]) {
             case AVAssetExportSessionStatusFailed:
                 NSLog(@"Failed");
                 break;
             case AVAssetExportSessionStatusCancelled:
                 break;
                 NSLog(@"Video Composition cancelled");
             case AVAssetExportSessionStatusCompleted:
                 NSLog(@"Export video completed");
                 break;
                 
             default:
                 break;
         }
         dispatch_async(dispatch_get_main_queue(), ^{
             [self.activityIndicatorr stopAnimating];
             self.labelWorking.hidden=YES;
         });
     }];
}

//below method used to provide text on vidoes files OR adding watermark on video files
- (IBAction)AddWaterMarkTextAndImage:(id)sender
{
    [self.activityIndicatorr startAnimating];
    self.labelWorking.hidden=NO;

    AVURLAsset* videoAsset = [[AVURLAsset alloc]initWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle]pathForResource:@"video_full" ofType:@"mp4"]]  options:nil];
    AVMutableComposition* mixComposition = [AVMutableComposition composition];
    AVMutableCompositionTrack *compositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    AVAssetTrack *clipVideoTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    [compositionVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration) ofTrack:clipVideoTrack atTime:kCMTimeZero error:nil];
    [compositionVideoTrack setPreferredTransform:[[[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] preferredTransform]];
    
    CGSize videoSize = [clipVideoTrack naturalSize];
    UIImage *myImage = [UIImage imageNamed:@"icon.png"];
    CALayer *aLayer = [CALayer layer];
    aLayer.contents = (id)myImage.CGImage;
    aLayer.frame = CGRectMake(videoSize.width - 65, videoSize.height - 75, 57, 57);
    aLayer.opacity = 0.65;
    CALayer *parentLayer = [CALayer layer];
    CALayer *videoLayer = [CALayer layer];
    parentLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
    videoLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
    [parentLayer addSublayer:videoLayer];
    [parentLayer addSublayer:aLayer];
    
    CATextLayer *titleLayer = [CATextLayer layer];
    titleLayer.string = @"Text Added on video file";
    titleLayer.font = CFBridgingRetain(@"ArialMT");
    titleLayer.fontSize = videoSize.height / 6;
    titleLayer.shadowOpacity = 0.5;
    titleLayer.alignmentMode = kCAAlignmentCenter;
    titleLayer.bounds = CGRectMake(0, 0, videoSize.width, videoSize.height / 6); //You may need to adjust this for proper display
    [parentLayer addSublayer:titleLayer]; //ONLY IF WE ADDED TEXT
    
    AVMutableVideoComposition* videoComp = [AVMutableVideoComposition videoComposition];
    videoComp.renderSize = videoSize;
    videoComp.frameDuration = CMTimeMake(1, 30);
    videoComp.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
    
    AVMutableVideoCompositionInstruction *instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    instruction.timeRange = CMTimeRangeMake(kCMTimeZero, [mixComposition duration]);
    AVAssetTrack *videoTrack = [[mixComposition tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    AVMutableVideoCompositionLayerInstruction* layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
    instruction.layerInstructions = [NSArray arrayWithObject:layerInstruction];
    videoComp.instructions = [NSArray arrayWithObject: instruction];
    
    AVAssetExportSession *assetExport = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetHighestQuality];//AVAssetExportPresetPassthrough
    assetExport.videoComposition = videoComp;
    
    NSString *myAddedWatermarkVideo =  [[NSHomeDirectory()  stringByAppendingPathComponent:@"Documents" ]stringByAppendingPathComponent:@"addedWAtermarkVideo .mp4"]; //Path to save file in DocumentDirectory
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:myAddedWatermarkVideo])
    {
        [[NSFileManager defaultManager] removeItemAtPath:myAddedWatermarkVideo error:nil];
    }
    assetExport.outputFileType = AVFileTypeQuickTimeMovie;     //Or we can set as @"com.apple.quicktime-movie";
    assetExport.outputURL = [NSURL fileURLWithPath:myAddedWatermarkVideo];   //Add export URL of file path
    assetExport.shouldOptimizeForNetworkUse = YES;
    
    //[strRecordedFilename setString: exportPath];
    
    [assetExport exportAsynchronouslyWithCompletionHandler:
     ^(void ) {
         switch ([assetExport status]) {
             case AVAssetExportSessionStatusFailed:
                 NSLog(@"Watermark Session failed");
                 break;
             case AVAssetExportSessionStatusCancelled:
                 NSLog(@"Watermark Session Cancelled");
                 break;
             case AVAssetExportSessionStatusCompleted:
                 NSLog(@"Watermark Session Completed");
                 break;
             default:
                 break;
         }
         dispatch_async(dispatch_get_main_queue(), ^{
             [self.activityIndicatorr stopAnimating];
             self.labelWorking.hidden=YES;
         });
     } ];
}



- (IBAction)MoveToParallelPlay:(id)sender {
    ParallelPlayer *object=[[ParallelPlayer alloc]init];
    [self.navigationController pushViewController:object animated:YES];
}
@end
