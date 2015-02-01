//
//  CustomVideoCompositor.m
//  video
//
//  Created by Rob Mayoff on 2/1/15.
//  Placed in the public domain by Rob Mayoff.
//

#import "CustomVideoCompositor.h"
@import  UIKit;

@implementation CustomVideoCompositor

- (instancetype)init {
    return self;
}

- (void)startVideoCompositionRequest:(AVAsynchronousVideoCompositionRequest *)request {
    CVPixelBufferRef destination = [request.renderContext newPixelBuffer];
    if (request.sourceTrackIDs.count == 2) {
        CVPixelBufferRef front = [request sourceFrameByTrackID:1];
        CVPixelBufferRef back = [request sourceFrameByTrackID:2];
        CVPixelBufferLockBaseAddress(front, kCVPixelBufferLock_ReadOnly);
        CVPixelBufferLockBaseAddress(back, kCVPixelBufferLock_ReadOnly);
        CVPixelBufferLockBaseAddress(destination, 0);
        [self renderFrontBuffer:front backBuffer:back toBuffer:destination];
        CVPixelBufferUnlockBaseAddress(destination, 0);
        CVPixelBufferUnlockBaseAddress(back, kCVPixelBufferLock_ReadOnly);
        CVPixelBufferUnlockBaseAddress(front, kCVPixelBufferLock_ReadOnly);
    }
    [request finishWithComposedVideoFrame:destination];
    CVBufferRelease(destination);
}

- (void)renderContextChanged:(AVVideoCompositionRenderContext *)newRenderContext {
}

- (NSDictionary *)requiredPixelBufferAttributesForRenderContext {
    return @{ (__bridge NSString *)kCVPixelBufferPixelFormatTypeKey : @[ @(kCVPixelFormatType_32BGRA) ] };
}

- (NSDictionary *)sourcePixelBufferAttributes {
    return @{ (__bridge NSString *)kCVPixelBufferPixelFormatTypeKey : @[ @(kCVPixelFormatType_32BGRA) ] };
}

- (void)renderFrontBuffer:(CVPixelBufferRef)front backBuffer:(CVPixelBufferRef)back toBuffer:(CVPixelBufferRef)destination {
    CGImageRef frontImage = [self createSourceImageFromBuffer:front];
    CGImageRef backImage = [self createSourceImageFromBuffer:back];
    size_t width = CVPixelBufferGetWidth(destination);
    size_t height = CVPixelBufferGetHeight(destination);
    CGRect frame = CGRectMake(0, 0, width, height);
    CGContextRef gc = CGBitmapContextCreate(CVPixelBufferGetBaseAddress(destination), width, height, 8, CVPixelBufferGetBytesPerRow(destination), CGImageGetColorSpace(backImage), CGImageGetBitmapInfo(backImage));
    CGContextDrawImage(gc, frame, backImage);
    CGContextBeginPath(gc);
    CGContextAddEllipseInRect(gc, CGRectInset(frame, frame.size.width / 10, frame.size.height / 10));
    CGContextClip(gc);
    CGContextDrawImage(gc, frame, frontImage);
    CGContextRelease(gc);
}

- (CGImageRef)createSourceImageFromBuffer:(CVPixelBufferRef)buffer {
    size_t width = CVPixelBufferGetWidth(buffer);
    size_t height = CVPixelBufferGetHeight(buffer);
    size_t stride = CVPixelBufferGetBytesPerRow(buffer);
    void *data = CVPixelBufferGetBaseAddress(buffer);
    CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, data, height * stride, NULL);
    CGImageRef image = CGImageCreate(width, height, 8, 32, stride, rgb, kCGBitmapByteOrder32Big | kCGImageAlphaPremultipliedLast, provider, NULL, NO, kCGRenderingIntentDefault);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(rgb);
    return image;
}

@end
