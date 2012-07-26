//
//  WavPackFile.h
//  Cog
//
//  Created by Vincent Spader on 6/6/05.
//  Copyright 2005 Vincent Spader All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Plugin.h"

#import "WavPack/wputils.h"

@interface WavPackDecoder : NSObject <CogDecoder>
{
	WavpackContext *wpc;
	WavpackStreamReader reader;
	
	id<CogSource> source;
	
	int bitsPerSample;
	int channels;
	int bitrate;
	float frequency;
	long totalFrames;
}

- (void)setSource:(id<CogSource>)s;
- (id<CogSource>)source;

@end
