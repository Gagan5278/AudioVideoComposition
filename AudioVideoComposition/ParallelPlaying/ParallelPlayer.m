//
//  ParallelPlayer.m
//  AudioVideoComposition
//
//  Created by Gagan on 22/05/14.
//  Copyright (c) 2014 Gagan. All rights reserved.
//

#import "ParallelPlayer.h"
#import "AVPlayerDemo.h"
@interface ParallelPlayer ()

@end

@implementation ParallelPlayer
@synthesize mPlaybackView;
@synthesize mPlayer;
static void *AVPlayerDemoPlaybackViewControllerStatusObservationContext = &AVPlayerDemoPlaybackViewControllerStatusObservationContext;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:NO];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self MergeVideosAndPlay];
    [super viewWillAppear:animated];
}

- (void)MergeVideosAndPlay{
    //Here where load our movie Assets using AVURLAsset
    AVURLAsset* firstAsset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource: @"video_full" ofType: @"mp4"]] options:nil];
    AVURLAsset * secondAsset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource: @"video" ofType: @"mp4"]] options:nil];
    
    //Create AVMutableComposition Object.This object will hold our multiple AVMutableCompositionTrack.
    AVMutableComposition* mixComposition = [[AVMutableComposition alloc] init];
    
    //Here we are creating the first AVMutableCompositionTrack.See how we are adding a new track to our AVMutableComposition.
    AVMutableCompositionTrack *firstTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    //Now we set the length of the firstTrack equal to the length of the firstAsset and add the firstAsset to out newly created track at kCMTimeZero so video plays from the start of the track.
    [firstTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, firstAsset.duration) ofTrack:[[firstAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:kCMTimeZero error:nil];
    
    //Now we repeat the same process for the 2nd track as we did above for the first track.
    AVMutableCompositionTrack *secondTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    [secondTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, secondAsset.duration) ofTrack:[[secondAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:kCMTimeZero error:nil];
    
    //We are creating AVMutableVideoCompositionInstruction object.This object will contain the array of our AVMutableVideoCompositionLayerInstruction objects.Set  duration of the layer.You should add the lenght equal to the lingth of the longer asset in terms of duration.
    AVMutableVideoCompositionInstruction * MainInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    MainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, firstAsset.duration);
    
    //Create 2 AVMutableVideoCompositionLayerInstruction objects.Each for our 2 AVMutableCompositionTrack.Now create AVMutableVideoCompositionLayerInstruction for out first track.Use of Affinetransform to move and scale our First Track.so it is displayed at the bottom of the screen in smaller size.(First track in the one that remains on top).
    AVMutableVideoCompositionLayerInstruction *FirstlayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:firstTrack];
    CGAffineTransform Scale = CGAffineTransformMakeScale(0.25f,0.25f);
    CGAffineTransform Move = CGAffineTransformMakeTranslation(230,230);
    [FirstlayerInstruction setTransform:CGAffineTransformConcat(Scale,Move) atTime:kCMTimeZero];
    
    //Here we are creating AVMutableVideoCompositionLayerInstruction for out second track.see how we make use of Affinetransform to move and scale our second Track.
    AVMutableVideoCompositionLayerInstruction *SecondlayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:secondTrack];
    CGAffineTransform SecondScale = CGAffineTransformMakeScale(1.2f,1.5f);
    CGAffineTransform SecondMove = CGAffineTransformMakeTranslation(0,0);
    [SecondlayerInstruction setTransform:CGAffineTransformConcat(SecondScale,SecondMove) atTime:kCMTimeZero];
    
    //Now we add our 2 created AVMutableVideoCompositionLayerInstruction objects to our AVMutableVideoCompositionInstruction in form of an array.
    MainInstruction.layerInstructions = [NSArray arrayWithObjects:FirstlayerInstruction,SecondlayerInstruction,nil];;
    
    //Now we create AVMutableVideoComposition object.We can add mutiple AVMutableVideoCompositionInstruction to this object.We have only one AVMutableVideoCompositionInstruction object in our example.You can use multiple AVMutableVideoCompositionInstruction objects to add multiple layers of effects such as fade and transition but make sure that time ranges of the AVMutableVideoCompositionInstruction objects dont overlap.
    AVMutableVideoComposition *MainCompositionInst = [AVMutableVideoComposition videoComposition];
    MainCompositionInst.instructions = [NSArray arrayWithObject:MainInstruction];
    MainCompositionInst.frameDuration = CMTimeMake(1, 30);
    MainCompositionInst.renderSize = CGSizeMake(640, 480);
    
    //Finally just add the newly created AVMutableComposition with multiple tracks to an AVPlayerItem and play it using AVPlayer.
    AVPlayerItem * newPlayerItem = [AVPlayerItem playerItemWithAsset:mixComposition];
    newPlayerItem.videoComposition = MainCompositionInst;
    self.mPlayer = [AVPlayer playerWithPlayerItem:newPlayerItem];
    [mPlayer addObserver:self forKeyPath:@"status" options:0 context:AVPlayerDemoPlaybackViewControllerStatusObservationContext];
    
    ///---------------------------------------------------------------------------------------------------Below code would not work in this case---------------------------------------------------------------------
     NSString *myOutputVideo =  [[NSHomeDirectory()  stringByAppendingPathComponent:@"Documents" ]stringByAppendingPathComponent:@"mergeVideoParallelOutput.mov"];
    if([[NSFileManager defaultManager]fileExistsAtPath:myOutputVideo])
    {
        [[NSFileManager defaultManager] removeItemAtPath:myOutputVideo error:nil];
    }
     NSURL *url = [NSURL fileURLWithPath:myOutputVideo];
          AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetHighestQuality];
     exporter.outputURL=url;
     [exporter setVideoComposition:MainCompositionInst];
     exporter.outputFileType = AVFileTypeQuickTimeMovie;
     [exporter exportAsynchronouslyWithCompletionHandler:^
     {
         switch ([exporter status]) {
             case AVAssetExportSessionStatusCompleted:
                 NSLog(@"Completed");
                 break;
             case AVAssetExportSessionStatusFailed:
                 NSLog(@"Failed");
                 break;
             case AVAssetExportSessionStatusCancelled:
                 NSLog(@"Cancelled");
                 break;
             default:
                 break;
         }
     }];
}


- (void)observeValueForKeyPath:(NSString*) path ofObject:(id)object change:(NSDictionary*)change context:(void*)context
{
    if (mPlayer.status == AVPlayerStatusReadyToPlay) {
        [self.mPlaybackView setPlayer:self.mPlayer];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.mPlayer play];
            self.mPlayer.rate=1.0;
        });
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    self.mPlayer.rate=0.0;
    [self.mPlayer pause];
    [mPlayer removeObserver:self forKeyPath:@"status" context:AVPlayerDemoPlaybackViewControllerStatusObservationContext];
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
