UIImageView-IncrementalLoad
===========================

Load images from web asynchronously and incrementally

using this UIImageView category helps to load asynchronously the web located images.
if you specify the flag 'incrementally' it will show partially loaded image.

To use this category you need to use ARC and load ImageIO.framework agaist the project.

Example of using:

   
    [self.imgViewOne loadImageWithURL:[NSURL URLWithString:@"http://awesomewallpapers.files.wordpress.com/2010/03/summer.png"] placeholderImage:nil incrementally:YES];

    [self.imgViewTwo loadImageWithURL:[NSURL URLWithString:@"http://imgs.mi9.com/uploads/fantasy/4568/free-summer-fantasy-landscape-for-desktop-wallpaper_422_80985.jpg"] ];

    [self.imgViewThree loadImageWithURL:[NSURL URLWithString:@"http://www.listofimages.com/wp-content/uploads/2012/05/spring-landscape-blue-clouds-fields-grass-green-landscape-skies-spring.jpg"] placeholderImage:nil incrementally:YES completion:^{
        NSLog(@"it is loaded!!!");
    }]; 
