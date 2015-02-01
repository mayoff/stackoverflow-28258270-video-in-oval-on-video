//
//  AVAsset+help.m
//  video
//
//  Created by Rob Mayoff on 1/31/15.
//  Placed in the public domain by Rob Mayoff.
//

#import "AVAsset+help.h"

@implementation AVAsset (help)

+ (instancetype)mp4AssetWithResourceName:(NSString *)name {
    NSURL *url = [[NSBundle mainBundle] URLForResource:name withExtension:@"mp4"];
    return [self assetWithURL:url];
}

- (AVAssetTrack *)firstVideoTrack {
    NSArray *tracks = [self tracksWithMediaType:AVMediaTypeVideo];
    return [tracks firstObject];
}

- (void)whenProperties:(NSArray *)names isReadyDo:(void (^)(void))block {
    [self loadValuesAsynchronouslyForKeys:names completionHandler:^{
        NSMutableArray *pendingNames;
        for (NSString *name in names) {
            switch ([self statusOfValueForKey:name error:nil]) {
                case AVKeyValueStatusLoaded:
                case AVKeyValueStatusFailed:
                    break;
                default:
                    if (pendingNames ==  nil) {
                        pendingNames = [NSMutableArray array];
                    }
                    [pendingNames addObject:name];
            }
        }

        if (pendingNames == nil) {
            block();
        } else {
            [self whenProperties:pendingNames isReadyDo:block];
        }
    }];
}

@end
