//
//  AVAsset+help.h
//  video
//
//  Created by Rob Mayoff on 1/31/15.
//  Placed in the public domain by Rob Mayoff.
//

#import <AVFoundation/AVFoundation.h>

@interface AVAsset (help)

+ (instancetype)mp4AssetWithResourceName:(NSString *)name;
- (AVAssetTrack *)firstVideoTrack;

- (void)whenProperties:(NSArray *)propertyNames areReadyDo:(void (^)(void))block;

@end
