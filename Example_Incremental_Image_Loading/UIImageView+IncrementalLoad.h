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


#import <UIKit/UIKit.h>

#import <Foundation/Foundation.h>

/**
 The category for UIKit class UIImageView adds methods that provides loading remote images asynchronously with URL.
 */

@interface UIImageView (IncrementalLoad)

-(void)loadImageWithURL:(NSURL *)url;

-(void)loadImageWithURL:(NSURL *)url placeholderImage:(UIImage*)placeholderImage;

-(void)loadImageWithURL:(NSURL *)url placeholderImage:(UIImage*)placeholderImage completion:(void(^)(void))completion;

-(void)loadImageWithURL:(NSURL *)url placeholderImage:(UIImage*)placeholderImage incrementally:(BOOL)isInc;

/**
 Creates url connection that asynchronously downloads the image from the URL and set the loaded image to instance of UIImageView when finished. If the image is previously loaded it is taken immediately from cache. If the placeholder image is set it sets immediately for image view and changed after loading is finished. Incremetally flag enables incremental loading of image with received bytes.
 After the loading is completed the competion block fires.
 
 @param url - using for the image url request.
 @param placeholderImage - the placeholder image to set it immediately before starting connection
 @param isInc - flag to load image incrementally
 @param completion - completion block. Fires when loading is completed
 
 */


-(void)loadImageWithURL:(NSURL *)url placeholderImage:(UIImage*)placeholderImage incrementally:(BOOL)isInc completion:(void(^)(void))completion;

@end


typedef void(^successBlock)(UIImage*image);
typedef void(^failureBlock)(NSError *error);
typedef void(^completionBlock)(void);

@interface YKIncrementalImageLoader : NSObject <NSURLConnectionDelegate> {
    NSString *_pathStr;
}

- (void)startLoadingWithURL:(NSURL*)url
              incrementally:(BOOL)isIncremental
                    success:(successBlock)successBlock
                    failure:(failureBlock)failureBlock
                 completion:(void(^)(void))completionBlock;

@property (nonatomic,strong) NSString *pathStr;

@end


@interface YKCache : NSCache

- (UIImage*)imageForKey:(NSString*)keyCache;

@end
