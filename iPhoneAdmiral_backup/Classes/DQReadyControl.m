//
//  DQReadyControl.m
//  BattleInterface
//
//  Created by Piotr Sarnowski on 7/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DQReadyControl.h"

//create ctfont from uifont
CTFontRef CTFontCreateFromUIFont(UIFont *font);

@implementation DQReadyControl

@synthesize _Text;
@synthesize _TextColor;
@synthesize _TextColorHighlited;
@synthesize _TextSize;
@synthesize _TextIndent;
@synthesize _TextCentered;

@synthesize _ActionTarget;

- (id) initWithCoder:(NSCoder *) acoder
{
    self = [super initWithCoder:acoder];
    
    if (self)
    {
        //set values to default
        [self setUserInteractionEnabled: NO];
        
        _TextSize = 20.0;
        _TextIndent = 0;
        _TextCentered = NO;
        _TextColor = [[UIColor blackColor] retain];
        _TextColorHighlited = [[UIColor whiteColor] retain];
    }
    
    return self;
}

- (void) addVisualAid
{
    [self setBackgroundColor:[UIColor whiteColor]];
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self recreateTextHighlit:YES];
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self recreateTextHighlit:NO];
    
	UITouch *touch = [touches anyObject];
    
	if ([touch tapCount] >= 1) [_ActionTarget performSelector: _Selector 
                                                   withObject: self];
}

- (void) setActionTarget:(id) targ
                selector:(SEL) sel
{
    _ActionTarget = targ;
    _Selector = sel;
    
    [self setUserInteractionEnabled:YES];
}

- (void) setActionSelector:(SEL) sel
{
    _Selector = sel;
    
    [self setUserInteractionEnabled:YES];
}

- (void) set_Text:(NSString *) text
{
    _Text = text;

    [self recreateTextHighlit:NO];
}

- (void) recreateTextHighlit:(BOOL) highlited
{
    if (_TextLayer == nil)
    {
        //load text layer
        _TextLayer = [[CATextLayer alloc] init];
        
        //text crispiness
        _TextLayer.contentsScale = [[UIScreen mainScreen] scale];
        
        //add as sublayer
        [[self layer] addSublayer:_TextLayer];
    }

    UIFont * invisible_newline_font = [UIFont systemFontOfSize:10.0];
    UIFont * invisible_spaces_font = [UIFont systemFontOfSize:_TextSize];
    UIFont * normal_font = [UIFont fontWithName:@"Don Quixote" 
                                           size:_TextSize];
        
    //hihglite or not
    UIColor * main_text_color = _TextColor;
    if (highlited) main_text_color = _TextColorHighlited;
    
    NSMutableAttributedString * new_string = [self mutableAttributedStringWithString: @"\n"
                                                                                font: invisible_newline_font
                                                                               color: [UIColor clearColor]
                                                                           alignment: kCTNaturalTextAlignment];
    
    
    if (_TextCentered)
    {        
        [new_string appendAttributedString: [self mutableAttributedStringWithString: _Text
                                                                               font: normal_font
                                                                              color: main_text_color
                                                                          alignment: kCTRightTextAlignment]];
        
        [_TextLayer setAlignmentMode:kCAAlignmentCenter];
    }
    else
    {
        //as crude as this gets...
        NSString * twenty_spaces_string = @"                    ";
        NSString * indentation_string = [twenty_spaces_string substringToIndex: _TextIndent];

        [new_string appendAttributedString: [self mutableAttributedStringWithString: indentation_string
                                                                               font: invisible_spaces_font
                                                                              color: [UIColor clearColor]
                                                                          alignment: kCTNaturalTextAlignment]];
        
        
        [new_string appendAttributedString: [self mutableAttributedStringWithString: _Text
                                                                               font: normal_font
                                                                              color: main_text_color
                                                                          alignment: kCTNaturalTextAlignment]];
    }
    
    //arrange string
    _TextLayer.frame = [self getFrameRectForFontSize:_TextSize];
    
    //set new string
    _TextLayer.string = new_string;
}

/* function that calculates textlayers frame */
- (CGRect) getFrameRectForFontSize:(CGFloat) fs
{
    CGFloat frame_height = 8.0 + fs * 1.6;
    //calculate y_origin so that the text gets aligned at the center of the containing label
    CGFloat y_origin = self.frame.size.height / 2 - frame_height / 2;
    
    return CGRectMake(0.0, y_origin, self.frame.size.width, frame_height);
}

/* wrapper for creating attributed string from simple ui classes */
- (NSMutableAttributedString *) mutableAttributedStringWithString:(NSString *)string 
                                                             font:(UIFont *)font 
                                                            color:(UIColor *)color 
                                                        alignment:(CTTextAlignment)alignment

{
    CFMutableAttributedStringRef attrString = CFAttributedStringCreateMutable(kCFAllocatorDefault, 0);
    
    if (string != nil)
        CFAttributedStringReplaceString (attrString, CFRangeMake(0, 0), (CFStringRef)string);
    
    CFAttributedStringSetAttribute(attrString, CFRangeMake(0, CFAttributedStringGetLength(attrString)), kCTForegroundColorAttributeName, color.CGColor);
    CTFontRef theFont = CTFontCreateFromUIFont(font);
    CFAttributedStringSetAttribute(attrString, CFRangeMake(0, CFAttributedStringGetLength(attrString)), kCTFontAttributeName, theFont);
    CFRelease(theFont);
    
    CTParagraphStyleSetting settings[] = {kCTParagraphStyleSpecifierAlignment, sizeof(alignment), &alignment};
    CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(settings, sizeof(settings) / sizeof(settings[0]));
    CFAttributedStringSetAttribute(attrString, CFRangeMake(0, CFAttributedStringGetLength(attrString)), kCTParagraphStyleAttributeName, paragraphStyle);    
    CFRelease(paragraphStyle);
    
    NSMutableAttributedString *ret = (NSMutableAttributedString *)attrString;
    
    return ret;
}

- (void) dealloc
{
    [_TextLayer release];
    
    [_Text release];
    [_TextColor release];
    [_TextColorHighlited release];
    
    [super dealloc];
}

@end

CTFontRef CTFontCreateFromUIFont(UIFont *font)
{
    CTFontRef ctFont = CTFontCreateWithName((CFStringRef)font.fontName, 
                                            font.pointSize, 
                                            NULL);
    return ctFont;
}
