#import "OutputsArrayController.h"

@implementation OutputsArrayController

- (void)awakeFromNib
{
	[self removeObjects:[self arrangedObjects]];
	
	[self setSelectsInsertedObjects:NO];
			
	UInt32 propsize;
	verify_noerr(AudioHardwareGetPropertyInfo(kAudioHardwarePropertyDevices, &propsize, NULL));
	int nDevices = propsize / sizeof(AudioDeviceID);	
	AudioDeviceID *devids = malloc(propsize);
	verify_noerr(AudioHardwareGetProperty(kAudioHardwarePropertyDevices, &propsize, devids));
	int i;
	
	NSDictionary *defaultDevice = [[[NSUserDefaultsController sharedUserDefaultsController] defaults] objectForKey:@"outputDevice"];
	
	for (i = 0; i < nDevices; ++i) {
		char name[256];
		UInt32 maxlen = 256;
		verify_noerr(AudioDeviceGetProperty(devids[i], 0, false, kAudioDevicePropertyDeviceName, &maxlen, name));
		
		// Ignore devices that have no output channels:
		// This tells us the size of the buffer required to hold the information about the channels
		UInt32 propSize;
		verify_noerr(AudioDeviceGetPropertyInfo(devids[i], 0, false, kAudioDevicePropertyStreamConfiguration, &propSize, NULL));
		// Knowing the size of the required buffer, we can determine how many channels there are
		// without actually allocating a buffer and requesting the information.
		// (we don't care about the exact number of channels, only if there are more than zero or not)
		if (propSize <= sizeof(UInt32)) continue;

		NSDictionary *deviceInfo = [NSDictionary dictionaryWithObjectsAndKeys:
			[NSString stringWithUTF8String:name], @"name",
			[NSNumber numberWithLong:devids[i]], @"deviceID",
			nil];
		[self addObject:deviceInfo];
		
		if (defaultDevice) {
			if ([[defaultDevice objectForKey:@"deviceID"] isEqualToNumber:[deviceInfo objectForKey:@"deviceID"]]) {
				[self setSelectedObjects:[NSArray arrayWithObject:deviceInfo]];
			}
		}

		[deviceInfo release];
	}
	free(devids);
	
		
	if (!defaultDevice)
		[self setSelectionIndex:0];
}

@end
