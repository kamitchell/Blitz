#import "BlitzPDFView.h"

@implementation BlitzPDFView
@synthesize secondsElapsed;

//  Following function stolen from http://cocoa.karelia.com/Foundation_Categories/NSColor__Instantiat.m
static NSColor* colorFromHexRGB( NSString *inColorString ) {
	NSColor *result = nil;
	unsigned int colorCode = 0;
	unsigned char redByte, greenByte, blueByte;
	
	if (nil != inColorString) {
		NSScanner *scanner = [NSScanner scannerWithString:inColorString];
		(void) [scanner scanHexInt:&colorCode];	// ignore error
	}
	redByte		= (unsigned char) (colorCode >> 16);
	greenByte	= (unsigned char) (colorCode >> 8);
	blueByte	= (unsigned char) (colorCode);	// masks off high bits
	result = [NSColor
              colorWithCalibratedRed: (float)redByte	/ 0xff
              green: (float)greenByte/ 0xff
              blue:	(float)blueByte	/ 0xff
              alpha: 1.0];
	return result;
}

#define threeOclock		0.0f
#define twelveOclock	90.0f
#define nineOclock		180.0f
#define sixOclock		270.0f

- (void)drawPagePost:(PDFPage*)page {
#if 0
        [[NSColor grayColor] set];
        NSFrameRect([self bounds]);
#endif
    
    const CGFloat kSize = 80.0f;
    const CGFloat kOuterRingWidth = 8.0f;
    const CGFloat kPadding = 20.0f;
    
    NSColor *outerSlideElapsedWedgeColor = colorFromHexRGB(@"2c8fff");
    
    NSRect bounds = NSMakeRect([self bounds].size.width - kPadding - kSize, kPadding, kSize, kSize);
    NSPoint center = NSMakePoint(NSMidX(bounds), NSMidY(bounds));
    
    {
        NSBezierPath *outerSlideRingBackground = [NSBezierPath bezierPathWithOvalInRect:bounds];
        
        NSShadow *shadow = [[[NSShadow alloc] init] autorelease];
        [shadow setShadowBlurRadius:6.0];
        [shadow setShadowColor:[[NSColor blackColor] colorWithAlphaComponent:0.50]];
        [shadow setShadowOffset:NSMakeSize(2.0, -2.0)];
        [shadow set];
        
        [colorFromHexRGB(@"32303d") set];
        [outerSlideRingBackground fill];
        
        [[[[NSShadow alloc] init] autorelease] set];
    }
    
    CGFloat degreesElapsed;
    {
        NSBezierPath *outerSlideElapsedWedge = [NSBezierPath bezierPath];
        [outerSlideElapsedWedge moveToPoint:center];
        
        float slideSeconds = fmod(self.secondsElapsed, 15.0f);
        degreesElapsed = (slideSeconds * 360.0f) / 14.0f;
        if (300 == self.secondsElapsed) degreesElapsed = 360.0f;
        
        [outerSlideElapsedWedge appendBezierPathWithArcWithCenter:center
                                          radius:bounds.size.width / 2.0f
                                      startAngle:twelveOclock-degreesElapsed
                                        endAngle:twelveOclock];
        [outerSlideElapsedWedge lineToPoint:center];
        [outerSlideElapsedWedge closePath];
        
        [outerSlideElapsedWedgeColor set];
        [outerSlideElapsedWedge fill];
    }
    
    NSRect innerCircleBounds = NSInsetRect(bounds, kOuterRingWidth, kOuterRingWidth);
    {
        NSBezierPath *innerTalkCircleBackground = [NSBezierPath bezierPathWithOvalInRect:innerCircleBounds];
        
        [[NSColor blackColor] set];
        [innerTalkCircleBackground fill];
    }
    
    {
        NSBezierPath *innerTalkElapsedWedge = [NSBezierPath bezierPath];
        [innerTalkElapsedWedge moveToPoint:center];
        
        CGFloat degreesElapsed = ((CGFloat)self.secondsElapsed * 360.0f) / 300.0f;
        [innerTalkElapsedWedge appendBezierPathWithArcWithCenter:center
                                                           radius:innerCircleBounds.size.width / 2.0f
                                                       startAngle:twelveOclock-degreesElapsed
                                                         endAngle:twelveOclock];
        [innerTalkElapsedWedge lineToPoint:center];
        [innerTalkElapsedWedge closePath];
        
        [colorFromHexRGB(@"0046a8") set];
        [innerTalkElapsedWedge fill];
    }
    
    {
        const CGFloat dotSize = 10.0f;
        NSRect dotBounds = NSMakeRect(-dotSize/2, (kSize/2)-dotSize+1, dotSize, dotSize);
        NSRect glowBounds = NSInsetRect(dotBounds, -5.0f, -5.0f);
        
        NSBezierPath *outerSlideElapsedDotGlow = [NSBezierPath bezierPathWithOvalInRect:glowBounds];
        NSBezierPath *outerSlideElapsedDot = [NSBezierPath bezierPathWithOvalInRect:dotBounds];
        
        NSGradient *glowGradient = [[[NSGradient alloc] initWithColorsAndLocations:
                                     [outerSlideElapsedWedgeColor colorWithAlphaComponent:0.99f], 0.00,
                                     [outerSlideElapsedWedgeColor colorWithAlphaComponent:0.02f], 0.80,
                                     [outerSlideElapsedWedgeColor colorWithAlphaComponent:0.01f], 1.00,
                                     nil] autorelease];
        NSGradient *dotGradient = [[[NSGradient alloc] initWithStartingColor:colorFromHexRGB(@"ffffff")
                                                                 endingColor:outerSlideElapsedWedgeColor] autorelease];
        
        [[NSGraphicsContext currentContext] saveGraphicsState]; {
            NSAffineTransform *transform = [NSAffineTransform transform];
            
            // translate and rotate graphics state (order is important, translate first before rotating)
            [transform translateXBy:center.x yBy:center.y];
            [transform rotateByDegrees:-degreesElapsed];
            [transform concat];
            
            [glowGradient drawInBezierPath:outerSlideElapsedDotGlow relativeCenterPosition:NSZeroPoint];
            [dotGradient drawInBezierPath:outerSlideElapsedDot relativeCenterPosition:NSZeroPoint];
        } [[NSGraphicsContext currentContext] restoreGraphicsState];
    }
}

- (IBAction)updateSecondsElapsed:(id)sender {
    self.secondsElapsed = [sender intValue];
    [self setNeedsDisplay:YES];
}

@end
