//
//  BIAlertView.m
//  BattleInterface
//
//  Created by Piotr Sarnowski on 5/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BIAlertView.h"
#import <QuartzCore/QuartzCore.h>

@implementation BIAlertView


- (id) initWithAlertType:(UIAlertType) type
                 message:(NSString *) msg
                delegate:(id) del
             cancelDelay:(NSTimeInterval) interval
{
    /*
                    GENERAL SETUP
     */
    
    _BGImage = [UIImage imageNamed:@"NotificationBG.png"];
    
    //who's your daddy?
    self = [super init];
    
    //set delegate
    [self setDelegate:del];

    [self setTag: type];
    
    //if interval is greater than 0, set auto cancel after this time - else, it will await the users decision indefinately
    if (interval > 0.0) [self performSelector:@selector(dismissAfterDelay) 
                                   withObject:nil 
                                   afterDelay:interval];

    /*
                    GRAPHIC SETUP
     */
    UILabel * NotifLabel;
    
    //create label
    if (type == AlertTypeRealismOn)
    {
        //need larger text here
        CGRect label_frame = CGRectMake(30.0, 0.0, 210.0, 170.0);
        NotifLabel = [[UILabel alloc] initWithFrame:label_frame];
        
        //set text properties
        [NotifLabel setFont: [UIFont fontWithName:@"Cochin-BoldItalic" size:18] ];
        [NotifLabel setNumberOfLines: 5];
    }
    else
    {
        CGRect label_frame = CGRectMake(40.0, 20.0, 190.0, 130.0);
        NotifLabel = [[UILabel alloc] initWithFrame:label_frame];
    
        //set text properties
        [NotifLabel setFont: [UIFont fontWithName:@"Cochin-BoldItalic" size:18] ];
        [NotifLabel setNumberOfLines: 3];
	}

    [NotifLabel setLineBreakMode: UILineBreakModeTailTruncation];
    [NotifLabel setTextAlignment: UITextAlignmentCenter];
    [NotifLabel setBackgroundColor:[UIColor clearColor]];
    
	//set message text
	[NotifLabel setText: msg];
	
	//add it to our bg
	[self addSubview: NotifLabel];	
    [NotifLabel release];
    
    /*
                    TYPE SPECIFIC BEHAVIOUR SETUP
     */
    
    switch (type)
    {
        //behavior - click anywhere to dismiss the view - create a giant see through button,
        //that encompasses the view
        case AlertTypeShootingFail:
        case AlertTypeTurnBegins:
        case AlertTypeRealismOn:
        {
            //OK
            UIButton * okbutton = [UIButton buttonWithType:UIButtonTypeCustom];
            [okbutton setFrame: CGRectMake(0.0, 0.0, _BGImage.size.width, _BGImage.size.height) ];
            
            [okbutton setTag: OKTAG];
            [self addSubview:okbutton];
            
            [okbutton setEnabled:YES];
            [okbutton setUserInteractionEnabled:YES];
            [okbutton addTarget:self
                          action:@selector(handleButton:) 
                forControlEvents:UIControlEventTouchUpInside];
        }
            break;
        
        //behavior - present the user with two buttons
        case AlertTypeShallowWater:
        {
            [self setUserInteractionEnabled:YES];
            
            //AYE
            UIImage * ayeimage = [UIImage imageNamed:@"Aye.png"];
            UIButton * ayebutton = [UIButton buttonWithType:UIButtonTypeCustom];
            [ayebutton setFrame: CGRectMake(60.0, 120.0, ayeimage.size.width, ayeimage.size.height) ];
            [ayebutton setBackgroundImage:ayeimage forState:UIControlStateNormal & UIControlStateSelected];
            
            [ayebutton setTag: AYETAG];
            [self addSubview:ayebutton];
            
            [ayebutton setEnabled:YES];
            [ayebutton setUserInteractionEnabled:YES];
            [ayebutton addTarget:self
                          action:@selector(handleButton:) 
                forControlEvents:UIControlEventTouchUpInside];

            //NAY
            UIImage * nayimage = [UIImage imageNamed:@"Nay.png"];
            UIButton * naybutton = [UIButton buttonWithType:UIButtonTypeCustom];
            [naybutton setFrame: CGRectMake(140.0, 120.0, nayimage.size.width, nayimage.size.height) ];
            [naybutton setBackgroundImage:nayimage forState:UIControlStateNormal & UIControlStateSelected];
            
            [naybutton setTag: NAYTAG];
            [self addSubview:naybutton];
            
            [naybutton setEnabled:YES];
            [naybutton setUserInteractionEnabled:YES];
            [naybutton addTarget:self
                          action:@selector(handleButton:) 
                forControlEvents:UIControlEventTouchUpInside];
            
        }
            break;
    }
    
    return self;
}

- (void) setNeedsDisplay
{
    [super setNeedsDisplay];
    
    //set to desired size
    CGSize imageSize = _BGImage.size;
    self.bounds = CGRectMake(0, 0, imageSize.width, imageSize.height);
}

- (void) show {
    // call the super show method to initiate the animation
    [super show];
        
    //find the default background subview
    for (UIView * subv in [self subviews])
    {
        if ( [subv tag] == 0 && [subv class] == [UIImageView class] )
        {
            //replace its image with our own
            [(UIImageView *)subv setImage:_BGImage];
        }
    }

    //resize
    CGSize imageSize = _BGImage.size;
    self.bounds = CGRectMake(0, 0, imageSize.width, imageSize.height);
}

- (void) handleButton:(id) sender
{
    UIButton * button = (UIButton *) sender;
    
    [self dismissWithClickedButtonIndex: [button tag] animated:YES]; 
}
 
- (void)dismissAfterDelay
{
    [self dismissWithClickedButtonIndex:OKTAG animated:YES]; 
}

@end
