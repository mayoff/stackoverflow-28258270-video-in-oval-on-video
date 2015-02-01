//
//  CustomVideoCompositor.m
//  video
//
//  Created by Rob Mayoff on 2/1/15.
//  Copyright (c) 2015 Rob Mayoff. All rights reserved.
//

#import "CustomVideoCompositor.h"

@implementation CustomVideoCompositor

- (instancetype)init {
    return self;
}

- (void)startVideoCompositionRequest:(AVAsynchronousVideoCompositionRequest *)request {
    CVPixelBufferRef buffer = [request sourceFrameByTrackID:[request.sourceTrackIDs.firstObject intValue]];
    if (buffer) {
        CVBufferRetain(buffer);
    } else {
        buffer = [request.renderContext newPixelBuffer];
    }
    [request finishWithComposedVideoFrame:buffer];
    CVBufferRelease(buffer);
}

- (void)renderContextChanged:(AVVideoCompositionRenderContext *)newRenderContext {
}

- (NSDictionary *)requiredPixelBufferAttributesForRenderContext {
    return @{ (__bridge NSString *)kCVPixelBufferPixelFormatTypeKey : @[ @(kCVPixelFormatType_32BGRA) ] };
}

- (NSDictionary *)sourcePixelBufferAttributes {
    return @{ (__bridge NSString *)kCVPixelBufferPixelFormatTypeKey : @[ @(kCVPixelFormatType_32BGRA) ] };
}

@end
