//
//  SpeakerAppDelegate.m
//  Speaker
//
//  Created by Jeena on 24.09.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SpeakerAppDelegate.h"

@interface SpeakerAppDelegate (private)
- (void)initLanugageMenu;
@end

@implementation SpeakerAppDelegate
@synthesize languageMenu;
@synthesize languageMenuPopupButton;
@synthesize speakButton;
@synthesize synth;

@synthesize window, textView;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	synth.delegate = self;
	oldRange = NSMakeRange(-1, -1);
	isNewLocation = YES;
    languages = nil;
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *string = [defaults objectForKey:@"text"];
	if (string) {
		NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:string];
		[[textView textStorage] setAttributedString:attributedString];
		NSRange aRange = NSMakeRange([defaults integerForKey:@"startLocation"], 0);
		[textView setSelectedRange:aRange];
		[textView scrollRangeToVisible:aRange];
	}
    
    float volume = [defaults floatForKey:@"volume"];
    if (volume == 0.0) {
        synth.volume = 1.0;
    } else {
        synth.volume = volume / 100;
    }
    
    [self initLanugageMenu];
}

- (void)applicationWillFinishLaunching:(NSNotification *)aNotification
{
    [[NSAppleEventManager sharedAppleEventManager]
     setEventHandler:self
     andSelector:@selector(handleURLEvent:withReplyEvent:)
     forEventClass:kInternetEventClass
     andEventID:kAEGetURL];
}

- (void)handleURLEvent:(NSAppleEventDescriptor*)event
        withReplyEvent:(NSAppleEventDescriptor*)replyEvent
{
    NSString* text = [[[[event paramDescriptorForKeyword:keyDirectObject]
                     stringValue] substringFromIndex:8] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    if ([synth isSpeaking]) {
        [self speakAction:self];
    }
    [textView setString:text];
    [self speakAction:self];
}

- (void)initLanugageMenu
{
    NSString *startName = [[NSUserDefaults standardUserDefaults] stringForKey:@"languageVoiceName"];
    
    NSLocale *currentLocale = [NSLocale currentLocale];
    NSArray *voices = [NSSpeechSynthesizer availableVoices];
    
    [self.languageMenu removeAllItems];
    
    NSMutableArray *langs = [NSMutableArray arrayWithCapacity:[voices count]];
    NSMutableArray *defaultVoices = [[NSUserDefaults standardUserDefaults] mutableArrayValueForKey:@"defaultVoices"];
    
    for (NSInteger i = 0; i < [voices count]; i++)
    {
        NSDictionary *dict = [NSSpeechSynthesizer attributesForVoice:[voices objectAtIndex:i]];
        NSString *countryString = [currentLocale displayNameForKey:NSLocaleIdentifier value:[dict objectForKey:@"VoiceLocaleIdentifier"]];

        if ([countryString hasPrefix:@"English"] && ![countryString isEqualToString:@"English (United States)"]) {
            continue;
        }
        
        NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:[dict objectForKey:@"VoiceName"] action:@selector(changeLanguage:) keyEquivalent:@""];
        NSMenuItem *country = [self.languageMenu itemWithTitle:countryString];
        if (!country) {
            country = [[NSMenuItem alloc] initWithTitle:countryString action:nil keyEquivalent:@""];
            NSMenu *submenu = [[NSMenu alloc] init];
            [country setSubmenu:submenu];
            [self.languageMenu addItem:country];
            
            [langs addObject:[[[dict objectForKey:@"VoiceLanguage"] componentsSeparatedByString:@"-"] objectAtIndex:0]];
        }
        
        item.tag = i;
        [[country submenu] addItem:item];
        
        if ([defaultVoices indexOfObject:item.title] != NSNotFound) {
            item.state = NSOnState;
        }
        
        if ((![[NSUserDefaults standardUserDefaults] objectForKey:@"languageVoiceIndex"] && [[dict objectForKey:@"VoiceName"] isEqualToString:@"Alex"]) || [item.title isEqualToString:startName])
        {
            //startItem = item;
        }
    }
    
    languages = langs;
}

- (void)changeLanguage:(id)sender
{
    NSMenuItem *item = (NSMenuItem *)sender;
    NSMenuItem *parent = item.parentItem;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *defaultVoices = [defaults mutableArrayValueForKey:@"defaultVoices"];

    for (NSMenuItem *child in parent.submenu.itemArray) {
        if (child.state == NSOnState) {
            for (NSString *voice in defaultVoices) {
                if ([child.title isEqualToString:voice]) {
                    [defaultVoices removeObject:voice];
                }
            }
            child.state = NSOffState;
        }
    }
    
    item.state = NSOnState;
    [defaultVoices addObject:item.title];
    [defaults synchronize];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setInteger:[textView selectedRange].location forKey:@"startLocation"];
	[defaults setObject:[[textView textStorage] string] forKey:@"text"];
	[defaults synchronize];
}

-(IBAction)speakAction:(id)sender {
	if ([synth isSpeaking]) {
		[self stopSpeaking];
        speakButton.image = [NSImage imageNamed:@"play.png"];
	} else {
		[self startSpeaking];
        speakButton.image = [NSImage imageNamed:@"pause.png"];
	}
}

-(void)stopSpeaking {
	[synth pauseSpeakingAtBoundary:NSSpeechWordBoundary];
	[textView setEditable:YES];
}

-(void)startSpeaking {
    
    [synth stopSpeaking];
	
	[textView setEditable:NO];
	
	NSRange range = [textView selectedRange];
	
	if (range.location == [[[textView textStorage] string] length]) {
		range.location = 0;
		[textView setSelectedRange:NSMakeRange(0,0)];
		[textView scrollRangeToVisible:NSMakeRange(0,0)];
	}
	
	NSString *wholeText = [[textView textStorage] string];
	NSString *text = nil;
	
	if (range.length > 0) { // selection
		text = [wholeText substringWithRange:range];
	} else { // only pointer
		text = [wholeText substringWithRange:NSMakeRange(range.location, [wholeText length] - range.location)];
	}
    
    [self setVoiceForLanguage:[self findLanguageFromString:text]];
    [synth startSpeakingString:text];
	oldRange = range;
	
}

-(IBAction)seekForward:(id)sender {
	// not working yet
	
	[self stopSpeaking];
	
	NSRange selected = [textView selectedRange];
	NSString *wholeText = [[textView textStorage] string];
	NSRange position = [wholeText rangeOfString:@". " options:NSLiteralSearch range:NSMakeRange(selected.location + 1, [wholeText length] - selected.location - 1)];
	[textView setSelectedRange:NSMakeRange(position.location + 2, 0)];

	[self startSpeaking];
}

-(IBAction)seekBack:(id)sender {

}

- (void)speechSynthesizer:(NSSpeechSynthesizer *)sender willSpeakWord:(NSRange)wordToSpeak ofString:(NSString *)text {
	NSRange range = NSMakeRange(oldRange.location + wordToSpeak.location, wordToSpeak.length);
	[textView scrollRangeToVisible:range];
	[textView setSelectedRange:NSMakeRange(range.location, 0)];
	[textView showFindIndicatorForRange:range];
	[textView display];
}

- (void)changeVoiceGender:(id)sender
{
    
}

- (void)speechSynthesizer:(NSSpeechSynthesizer *)sender didFinishSpeaking:(BOOL)success {
    [textView setEditable:YES];
}

- (NSString *)findLanguageFromString:(NSString *)text
{
    NSArray *tagschemes = [NSArray arrayWithObjects:NSLinguisticTagSchemeLanguage, nil];
    NSLinguisticTagger *tagger = [[NSLinguisticTagger alloc] initWithTagSchemes:tagschemes options:0];
    [tagger setString:[[[text componentsSeparatedByCharactersInSet:[[NSCharacterSet letterCharacterSet] invertedSet]] componentsJoinedByString:@" "] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
    NSString *language = [tagger tagAtIndex:0 scheme:NSLinguisticTagSchemeLanguage tokenRange:NULL sentenceRange:NULL];
    
    return language;
}

- (void)setVoiceForLanguage:(NSString *)language
{
    NSMenuItem *item;
    NSMenuItem *languageItem;
    for (NSInteger i = 0; i < [languages count]; i++)
    {
        if ([[languages objectAtIndex:i] isEqualToString:language]) {
            languageItem = [[self.languageMenu itemArray] objectAtIndex:i];
            for (item in [languageItem.submenu itemArray]) {
                if (item.state == NSOnState) {
                    break;
                }
            }
            if (!item) {
                item = [[languageItem.submenu itemArray] objectAtIndex:0];
            }
        }
    }
    
    if (languageItem && item) {
        NSString *voice = [[NSSpeechSynthesizer attributesForVoice:[[NSSpeechSynthesizer availableVoices] objectAtIndex:item.tag]] objectForKey:@"VoiceIdentifier"];
        [synth setVoice:voice];
        [self.languageMenuPopupButton selectItem:languageItem];
    }    
}


@end
