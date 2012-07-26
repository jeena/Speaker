//
//  SpeakerAppDelegate.h
//  Speaker
//
//  Created by Jeena on 24.09.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SpeakerAppDelegate : NSObject <NSApplicationDelegate, NSSpeechSynthesizerDelegate> {
    NSWindow *__weak window;
	NSTextView *textView;
    NSMenu *__weak languageMenu;
    NSPopUpButton *__weak languageMenuPopupButton;
	NSSpeechSynthesizer *synth;
	NSRange oldRange;
	BOOL isNewLocation;
}

@property (weak) IBOutlet NSWindow *window;
@property (strong, nonatomic) IBOutlet NSTextView *textView;
@property (weak) IBOutlet NSMenu *languageMenu;
@property (weak) IBOutlet NSPopUpButton *languageMenuPopupButton;

-(IBAction)speakAction:(id)sender;
-(IBAction)seekForward:(id)sender;
-(IBAction)seekBack:(id)sender;

-(void)stopSpeaking;
-(void)startSpeaking;

- (void)changeLanguage:(id)sender;
- (void)changeVoiceGender:(id)sender;

@end
