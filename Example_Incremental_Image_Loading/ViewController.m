//
//  ViewController.m
//  Example_Incremental_Image_Loading
//
//  Created by Youri Kobets on 16.02.13.
//  Copyright (c) 2013 Youri Kobets. All rights reserved.
//

#import "ViewController.h"

#import "UIImageView+IncrementalLoad.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.imgViewOne loadImageWithURL:[NSURL URLWithString:@"http://awesomewallpapers.files.wordpress.com/2010/03/summer.png"] placeholderImage:nil incrementally:YES];

    [self.imgViewTwo loadImageWithURL:[NSURL URLWithString:@"http://imgs.mi9.com/uploads/fantasy/4568/free-summer-fantasy-landscape-for-desktop-wallpaper_422_80985.jpg"] ];

    [self.imgViewThree loadImageWithURL:[NSURL URLWithString:@"http://www.listofimages.com/wp-content/uploads/2012/05/spring-landscape-blue-clouds-fields-grass-green-landscape-skies-spring.jpg"] placeholderImage:nil incrementally:YES completion:^{
        NSLog(@"it is loaded!!!");
    }]; 

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}



@end
