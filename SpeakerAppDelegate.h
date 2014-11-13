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
    NSArray *languages;
}

@property (weak) IBOutlet NSWindow *window;
@property (strong, nonatomic) IBOutlet NSTextView *textView;
@property (weak) IBOutlet NSMenu *languageMenu;
@property (weak) IBOutlet NSPopUpButton *languageMenuPopupButton;
@property (weak) IBOutlet NSToolbarItem *speakButton;

-(IBAction)speakAction:(id)sender;
-(IBAction)seekForward:(id)sender;
-(IBAction)seekBack:(id)sender;

-(void)stopSpeaking;
-(void)startSpeaking;

- (void)changeLanguage:(id)sender;
- (void)changeVoiceGender:(id)sender;

- (NSString *)findLanguageFromString:(NSString *)text;
- (void)setVoiceForLanguage:(NSString *)language;

@end
