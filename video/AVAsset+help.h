//
//  AVAsset+help.h
//  video
//
//  Created by Rob Mayoff on 1/31/15.
//  Copyright (c) 2015 Rob Mayoff. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

@interface AVAsset (help)

+ (instancetype)mp4AssetWithResourceName:(NSString *)name;
- (AVAssetTrack *)firstVideoTrack;

- (void)whenProperties:(NSArray *)propertyNames isReadyDo:(void (^)(void))block;

@end
