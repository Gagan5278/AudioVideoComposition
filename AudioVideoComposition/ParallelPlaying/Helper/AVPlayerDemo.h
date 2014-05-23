//AVPlayerDemo.h
//  AudioVideoComposition
//
//  Created by Gagan on 22/05/14.
//  Copyright (c) 2014 Gagan. All rights reserved.
//
#import <UIKit/UIKit.h>

@class AVPlayer;

@interface AVPlayerDemo : UIView

@property (nonatomic, retain) AVPlayer* player;

- (void)setPlayer:(AVPlayer*)player;
- (void)setVideoFillMode:(NSString *)fillMode;

@end
