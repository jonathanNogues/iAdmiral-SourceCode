//
//  DQReadyControl.h
//  BattleInterface
//
//  Created by Piotr Sarnowski on 7/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreText/CoreText.h>

@interface DQReadyControl : UIView 
{
    CATextLayer * _TextLayer;
    
    NSString *  _Text;
    UIColor *   _TextColor;
    UIColor *   _TextColorHighlited;
    CGFloat     _TextSize;    
    int         _TextIndent;
    BOOL        _TextCentered;
    
    id          _ActionTarget;
    SEL         _Selector;
    
}

@property (nonatomic, retain) NSString *    _Text;
@property (nonatomic, retain) UIColor *     _TextColor;
@property (nonatomic, retain) UIColor *     _TextColorHighlited;
@property (nonatomic, assign) CGFloat       _TextSize;
@property (nonatomic, assign) int           _TextIndent;
@property (nonatomic, assign) BOOL          _TextCentered;
@property (nonatomic, assign) IBOutlet id   _ActionTarget;


/* configures action to be triggered after clicking the control 
   before this is called, the control will not respond to taps */
- (void) setActionTarget:(id) targ
                selector:(SEL)  sel;

- (void) setActionSelector:(SEL) sel;

/* adds white background for easier positioning during design */
- (void) addVisualAid;

/* Utilities */
- (void) recreateTextHighlit:(BOOL) highlited;

- (CGRect) getFrameRectForFontSize:(CGFloat) fs;

- (NSMutableAttributedString *) mutableAttributedStringWithString:(NSString *)string 
                                                             font:(UIFont *)font 
                                                            color:(UIColor *)color 
                                                        alignment:(CTTextAlignment)alignment;

@end
