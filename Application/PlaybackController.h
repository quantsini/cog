/* PlaybackController */

#import <Cocoa/Cocoa.h>

#import "CogAudio/AudioPlayer.h"
#import "TrackingSlider.h"
#import "AudioScrobbler.h"

#define DEFAULT_VOLUME_DOWN 5
#define DEFAULT_VOLUME_UP DEFAULT_VOLUME_DOWN

extern NSString *CogPlaybackDidBeginNotficiation;
extern NSString *CogPlaybackDidPauseNotficiation;
extern NSString *CogPlaybackDidResumeNotficiation;
extern NSString *CogPlaybackDidStopNotficiation;


@class PlaylistController;
@class PlaylistView;

@interface PlaybackController : NSObject
{
    IBOutlet PlaylistController *playlistController;
	IBOutlet PlaylistView *playlistView;
	
	IBOutlet NSSlider *volumeSlider;
	
	IBOutlet NSArrayController *outputDevices;
	
	NSTimer *positionTimer;
		
	AudioPlayer *audioPlayer;
	
	int playbackStatus;
	double position;
	BOOL seekable;
	BOOL fading;
 }

@property int playbackStatus;

- (IBAction)changeVolume:(id)sender;
- (IBAction)volumeDown:(id)sender;
- (IBAction)volumeUp:(id)sender;

- (IBAction)playPauseResume:(id)sender;
- (IBAction)pauseResume:(id)sender;
- (IBAction)skipToNextAlbum:(id)sender;
- (IBAction)skipToPreviousAlbum:(id)sender;

- (IBAction)play:(id)sender;
- (IBAction)pause:(id)sender;
- (IBAction)resume:(id)sender;
- (IBAction)stop:(id)sender;

- (IBAction)next:(id)sender;
- (IBAction)prev:(id)sender;
- (IBAction)seek:(id)sender;
- (IBAction)eventSeekForward:(id)sender;
- (void)seekForward:(double)sender;
- (IBAction)eventSeekBackward:(id)sender;
- (void)seekBackward:(double)amount;
- (IBAction)fade:(id)sender;

- (void)initDefaults;
- (void)audioFadeDown:(NSTimer *)audioTimer;
- (void)audioFadeUp:(NSTimer *)audioTimer;

- (void)playEntryAtIndex:(int)i;
- (void)playEntry:(PlaylistEntry *)pe;

// Playlist notifications
- (void)playlistDidChange:(PlaylistController *)p;

// For bindings

- (void)setPosition:(double)p;
- (double)position;

- (void)setSeekable:(BOOL)s;
- (BOOL)seekable;

@end
