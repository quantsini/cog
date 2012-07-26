#import "ToolTipWindow.h"

@implementation ToolTipWindow

- (void)setBackgroundColor:(NSColor *)bgColor
{
	[backgroundColor release];
    backgroundColor = [bgColor retain];
}
- (NSColor *)backgroundColor
{
    return backgroundColor;
}

- (NSSize)suggestedSizeForTooltip:(id)tooltip
{
    NSSize tipSize = NSZeroSize;
	
    if ([tooltip isKindOfClass:[NSAttributedString class]]) {
		tipSize = [tooltip size];
	}
    else if ([tooltip isKindOfClass:[NSString class]]){
		tipSize = [tooltip sizeWithAttributes:textAttributes];
	}
	
	if (!NSEqualSizes(tipSize, NSZeroSize))
		tipSize.width += 4;
	
	return tipSize;
	
}


- (id)init
{
    self = [super initWithContentRect:NSMakeRect(0,0,0,0)
							styleMask:NSBorderlessWindowMask
							  backing:NSBackingStoreBuffered
								defer:NO];
	
	{ // window setup...
        [self setAlphaValue:0.90];
        [self setOpaque:NO];
        [self setHasShadow:YES];
		[self setBackgroundColor:[NSColor colorWithDeviceRed:1.0 green:0.96 blue:0.76 alpha:1.0]];
        [self setLevel:NSStatusWindowLevel];
        [self setHidesOnDeactivate:YES];
        [self setIgnoresMouseEvents:YES];
		[self setReleasedWhenClosed:NO];
	}
	
	{ // textfield setup...
        NSTextField *field = [[NSTextField alloc] initWithFrame:NSMakeRect(0,0,0,0)];
		
		[field setEditable:NO];
		[field setSelectable:NO];
		[field setBezeled:NO];
		[field setBordered:NO];
		[field setDrawsBackground:NO];
		[field setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
		[self setContentView:field];
		[self setFrame:[self frameRectForContentRect:[field frame]] display:NO];
		
		[field setStringValue:@" "]; // Just having at least 1 char to allow the next message...
		textAttributes = [[[field attributedStringValue] attributesAtIndex:0 effectiveRange:nil] retain];
		
		[field release];
	}
	
    return self;
}


- (void)dealloc
{
	if (closeTimer) {
		[closeTimer invalidate];
		[closeTimer release];
	}
    [tooltipObject release];
    [super dealloc];
}

- (id)toolTip { return tooltipObject; }

- (void)setToolTip:(id)tip
{
    id contentView = [self contentView];
    
    [tooltipObject release];
    tooltipObject = [tip retain];
    
    if ([contentView isKindOfClass:[NSTextField class]]) {
        if ([tip isKindOfClass:[NSString class]]) [contentView setStringValue:tip];
        else
			if ([tip isKindOfClass:[NSAttributedString class]]) [contentView setAttributedStringValue:tip];
    }
}

- (void)orderFrontForDuration:(NSTimeInterval)duration
{
	[self orderFront:nil];

    if (closeTimer) { [closeTimer invalidate]; [closeTimer release]; }
	
    closeTimer = [[NSTimer timerWithTimeInterval:duration target:self selector:@selector(close) userInfo:nil repeats:NO] retain];
	[[NSRunLoop currentRunLoop] addTimer:closeTimer forMode:NSRunLoopCommonModes];
}

- (void)orderFront
{
    if (closeTimer) { [closeTimer invalidate]; [closeTimer release]; closeTimer = nil; }
	
    [super orderFront:nil];
}


- (NSString *)description
{
    return [NSString stringWithFormat:@"TooltipWindow:\n%@", [[self contentView] stringValue]];
}


@end