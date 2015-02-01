//
//  AppDelegate.m
//  video
//
//  Created by Rob Mayoff on 1/31/15.
//  Placed in the public domain by Rob Mayoff.
//

#import "AppDelegate.h"
#import "CustomVideoCompositor.h"
#import "AVAsset+help.h"

@interface AppDelegate ()

@end

@implementation AppDelegate {
    AVAsset *backAsset;
    AVAsset *frontAsset;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self loadBackAsset];
    [self loadFrontAsset];
    return YES;
}

- (void)makeVideo {
    if (!backAsset || !frontAsset) {
        return;
    }

    AVMutableComposition *composition = [AVMutableComposition composition];
    [self addAsset:frontAsset toComposition:composition withTrackID:1];
    [self addAsset:backAsset toComposition:composition withTrackID:2];

    AVAssetTrack *backVideoTrack = backAsset.firstVideoTrack;
    AVMutableVideoComposition *videoComposition = [AVMutableVideoComposition videoComposition];
    videoComposition.renderSize = backVideoTrack.naturalSize;
    videoComposition.frameDuration = CMTimeMakeWithSeconds(1.0 / backVideoTrack.nominalFrameRate, backVideoTrack.naturalTimeScale);

    AVMutableVideoCompositionInstruction *instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    instruction.timeRange = [composition.tracks.firstObject timeRange];
    AVMutableVideoCompositionLayerInstruction *frontLayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstruction];
    frontLayerInstruction.trackID = 1;
    AVMutableVideoCompositionLayerInstruction *backLayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstruction];
    backLayerInstruction.trackID = 2;
    instruction.layerInstructions = @[ frontLayerInstruction, backLayerInstruction ];

    videoComposition.instructions = @[ instruction ];

    videoComposition.customVideoCompositorClass = [CustomVideoCompositor class];

    AVAssetExportSession *exporter = [AVAssetExportSession exportSessionWithAsset:composition presetName:AVAssetExportPreset960x540];
    exporter.outputURL = [self outputURL];
    exporter.outputFileType = AVFileTypeQuickTimeMovie;
    exporter.shouldOptimizeForNetworkUse = YES;
    exporter.videoComposition = videoComposition;
    [[NSFileManager defaultManager] removeItemAtURL:exporter.outputURL error:nil];
    [exporter exportAsynchronouslyWithCompletionHandler:^{
            NSLog(@"done! URL = %@", exporter.outputURL);
    }];
}

- (void)addAsset:(AVAsset *)asset toComposition:(AVMutableComposition *)composition withTrackID:(CMPersistentTrackID)trackID {
    AVMutableCompositionTrack *videoTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:trackID];
    CMTimeRange timeRange = CMTimeRangeFromTimeToTime(kCMTimeZero, CMTimeMake(3, 1));
    AVAssetTrack *assetVideoTrack = asset.firstVideoTrack;
    [videoTrack insertTimeRange:timeRange ofTrack:assetVideoTrack atTime:kCMTimeZero error:nil];
}

- (void)loadBackAsset {
    AVAsset *asset = [AVAsset mp4AssetWithResourceName:@"test 1"];
    [asset whenProperties:@[ @"tracks" ] areReadyDo:^{
        backAsset = asset;
        [self makeVideo];
    }];
}

- (void)loadFrontAsset {
    AVAsset *asset = [AVAsset mp4AssetWithResourceName:@"test 2"];
    [asset whenProperties:@[ @"tracks" ] areReadyDo:^{
        frontAsset = asset;
        [self makeVideo];
    }];
}

- (NSURL *)outputURL {
    NSURL *url = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:nil];
    url = [url URLByAppendingPathComponent:@"export.mp4"];
    return url;
}

- (CALayer *)maskLayerWithFrame:(CGRect)frame {
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectInset(frame, frame.size.width / 10, frame.size.height / 10)];
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.frame = frame;
    layer.path = path.CGPath;
    layer.backgroundColor = [UIColor clearColor].CGColor;
    layer.strokeColor = nil;
    layer.fillColor = [UIColor whiteColor].CGColor;
    return layer;
}

@end
