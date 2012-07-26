//
//  PreferencePane.m
//  Preferences
//
//  Created by Vincent Spader on 9/4/06.
//  Copyright 2006 Vincent Spader. All rights reserved.
//

#import "GeneralPreferencePane.h"


@implementation GeneralPreferencePane

+ (GeneralPreferencePane *)preferencePaneWithView:(NSView *)v title:(NSString *)t iconNamed:(NSString *)n
{
	GeneralPreferencePane *pane = [[[GeneralPreferencePane alloc] init] autorelease];
	if (pane)
	{
		[pane setView:v];
		[pane setTitle:t];

		NSImage *i = [[NSImage alloc] initWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForImageResource:n]];
		[pane setIcon:i];
		[i release];
	}
	
	return pane;
}

- (NSView *)view
{
	return view;
}

- (NSString *)title
{
	return title;
}

- (NSImage *)icon
{
	return icon;
}

- (void)setView:(NSView *)v
{
	[v retain];
	[view release];
	view = v;
}

- (void)setTitle:(NSString *)t
{
	[t retain];
	[title release];
	title = t;
}

- (void)setIcon:(NSImage *)i
{
	[i retain];
	[icon release];
    icon = i;
}

@end
