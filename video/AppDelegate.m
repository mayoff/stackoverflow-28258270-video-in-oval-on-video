//
//  AppDelegate.m
//  video
//
//  Created by Rob Mayoff on 1/31/15.
//  Placed in the public domain by Rob Mayoff.
//

#import "AppDelegate.h"
#import "AVAsset+help.h"

@interface AppDelegate ()

@end

@implementation AppDelegate {
    AVAsset *backAsset;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self loadBackAsset];
    return YES;
}

- (void)makeVideo {
    AVMutableComposition *composition = [AVMutableComposition composition];
    AVMutableCompositionTrack *videoTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    AVAssetTrack *backVideoTrack = backAsset.firstVideoTrack;
    [videoTrack insertTimeRange:backVideoTrack.timeRange ofTrack:backVideoTrack atTime:kCMTimeZero error:nil];

    AVMutableVideoComposition *videoComposition = [AVMutableVideoComposition videoComposition];
    videoComposition.renderSize = backVideoTrack.naturalSize;
    videoComposition.frameDuration = CMTimeMakeWithSeconds(1.0 / backVideoTrack.nominalFrameRate, backVideoTrack.naturalTimeScale);

    AVMutableVideoCompositionInstruction *instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    instruction.timeRange = videoTrack.timeRange;
    AVMutableVideoCompositionLayerInstruction *layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:backVideoTrack];
    instruction.layerInstructions = @[ layerInstruction ];

    videoComposition.instructions = @[ instruction ];

    CALayer *backVideoLayer = [CALayer layer];
    backVideoLayer.frame = (CGRect){ .origin = CGPointZero, .size = backVideoTrack.naturalSize };
    CALayer *compositeLayer = [CALayer layer];
    compositeLayer.frame = backVideoLayer.frame;
    [compositeLayer addSublayer:backVideoLayer];
    videoComposition.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayers:@[ backVideoLayer ] inLayer:compositeLayer];

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

- (void)loadBackAsset {
    backAsset = [AVAsset mp4AssetWithResourceName:@"test 1"];
    [backAsset whenProperties:@[ @"tracks" ] isReadyDo:^{
        [self makeVideo];
    }];
}

- (NSURL *)outputURL {
    NSURL *url = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:nil];
    url = [url URLByAppendingPathComponent:@"export.mp4"];
    return url;
}

@end
