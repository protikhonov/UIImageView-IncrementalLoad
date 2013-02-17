//
// UIImageView+IncrementalLoad.h
//
// Copyright (c) 2013 Youri Kobets.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


#import "UIImageView+IncrementalLoad.h"

#import <ImageIO/ImageIO.h>


@implementation UIImageView (IncrementalLoad)

-(void)loadImageWithURL:(NSURL *)url
{
    [self loadImageWithURL:url placeholderImage:nil incrementally:NO completion:nil];
}

-(void)loadImageWithURL:(NSURL *)url placeholderImage:(UIImage*)placeholderImage
{
    [self loadImageWithURL:url placeholderImage:placeholderImage incrementally:NO completion:nil];
}

-(void)loadImageWithURL:(NSURL *)url placeholderImage:(UIImage*)placeholderImage completion:(void(^)(void))completion
{
    [self loadImageWithURL:url placeholderImage:placeholderImage incrementally:NO completion:completion];
}

-(void)loadImageWithURL:(NSURL *)url placeholderImage:(UIImage*)placeholderImage incrementally:(BOOL)isInc
{
    
    [self loadImageWithURL:url placeholderImage:placeholderImage incrementally:isInc completion:nil];
}

-(void)loadImageWithURL:(NSURL *)url placeholderImage:(UIImage*)placeholderImage incrementally:(BOOL)isInc completion:(void(^)(void))completion
{
    [self setImage:placeholderImage];
    
    YKIncrementalImageLoader *incrementalLoader = [YKIncrementalImageLoader new];
    [incrementalLoader startLoadingWithURL:url incrementally:isInc success:^(UIImage *image) {
        self.image = nil;
        [self setImage:image];
    } failure:^(NSError *error) {
        NSLog(@"error loading image %@", [error localizedDescription]);
    } completion:completion];
}

@end



@interface YKCache () 

@end

@implementation YKCache

static YKCache *_sharedCacheManager = nil;

+ (YKCache*) sharedCache {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedCacheManager = [YKCache new];
    });
    
    return _sharedCacheManager;
}

- (id) init {
    self = [super init];
    if (self) {
        
    }
    
    return self;
}

- (UIImage*)imageForKey:(NSString*)keyCache {
    UIImage *image = [self objectForKey:keyCache];
    
    return image;
}


@end




@interface YKIncrementalImageLoader ()
{
    NSURLConnection *activeConnection;
    NSMutableData *receivedData;
    successBlock success;
    failureBlock failure;
    completionBlock completion;
    
    BOOL _isIncremental;
    CGImageSourceRef _imageSource;
    
}
@end


@implementation YKIncrementalImageLoader

- (void)startLoadingWithURL:(NSURL*)url
              incrementally:(BOOL)isIncremental
                    success:(successBlock)successBlock
                    failure:(failureBlock)failureBlock
                 completion:(void(^)(void))completionBlock
{
    YKCache *cache = [YKCache sharedCache];
    UIImage *cachedImage = [cache imageForKey:url.absoluteString];
    if (cachedImage) {
        success(cachedImage);
        if (completion) {
            completion();
        }
        return;
    }
    
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];
    [theRequest setTimeoutInterval:60.];
    
    activeConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    
    if (activeConnection) {
        receivedData = [NSMutableData data];
    } else {
        NSLog(@"NSURLConnection instantiate failed");
    }
    
    success = successBlock;
    failure = failureBlock;
    completion = completionBlock;
    _isIncremental = isIncremental;
    
    [activeConnection start];
    
}

#pragma mark - NSURLConnection Delegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [receivedData appendData:data];
    
    if (_isIncremental) {
        if (_imageSource == NULL) {
            _imageSource = CGImageSourceCreateIncremental(NULL);
        }
        CGImageSourceUpdateData(_imageSource, (__bridge CFDataRef)receivedData, NO);
        
        CGImageRef imageRef = CGImageSourceCreateImageAtIndex(_imageSource, 0, NULL);
        if (imageRef)
        {
            UIImage *anImage = [UIImage imageWithCGImage:imageRef];
            success(anImage);
        }
        CGImageRelease(imageRef);
        
    }
}


#pragma mark -

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
    receivedData = nil;
    
    failure(error);
    
    NSLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    UIImage *receivedImage = [UIImage imageWithData:receivedData];
    
    if (receivedImage) {
        success(receivedImage);
    } else {
        failure(nil);
    }
    
    if (_imageSource) {
        CFRelease(_imageSource);
    }
    
    if (completion) {
        completion();
    }
    
    NSString *absPath = connection.originalRequest.URL.absoluteString;
    if (receivedImage) {
        YKCache *cache = [YKCache sharedCache];
        [cache setObject:receivedImage forKey:absPath];
    }
    
    activeConnection = nil;
    receivedData = nil;
}

#pragma mark -

@end
