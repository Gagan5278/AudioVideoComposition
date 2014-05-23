//
//  ParallelPlayer.h
//  AudioVideoComposition
//
//  Created by Gagan on 22/05/14.
//  Copyright (c) 2014 Gagan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <CoreMedia/CoreMedia.h>
@class AVPlayerDemo;
@interface ParallelPlayer : UIViewController
@property (readwrite, retain) AVPlayer* mPlayer;
@property (nonatomic, retain) IBOutlet AVPlayerDemo *mPlaybackView;
- (void)observeValueForKeyPath:(NSString*) path ofObject:(id)object change:(NSDictionary*)change context:(void*)context;
- (void)MergeVideosAndPlay;
@end
