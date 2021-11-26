#import "AppDelegate.h"

@interface AppDelegate ()

@property (strong) IBOutlet NSWindow* window;

@end


@implementation AppDelegate

double rightClickDown;

CGEventRef tapCallback(CGEventTapProxy proxy, CGEventType type, CGEventRef event, void* refcon) {
    double now = [[NSDate date] timeIntervalSince1970] * 1000;
    if (CGEventGetType(event) == kCGEventRightMouseDown) {
        rightClickDown = now;
    } else if (CGEventGetType(event) == kCGEventRightMouseUp) {
        if (now - rightClickDown >= 1000) {
            exit(0);
        }
    }
    return nil;
}
- (void)tap {
    CFRunLoopSourceRef runLoopSource;
    CGEventMask mask = kCGEventMaskForAllEvents;
    CFMachPortRef eventTap = CGEventTapCreate(kCGHIDEventTap, kCGHeadInsertEventTap, kCGEventTapOptionDefault, mask, tapCallback, NULL);
    if (!eventTap) {
        [[self.window contentView] setBackgroundColor:NSColor.whiteColor];
        [[self.window contentView] exitFullScreenModeWithOptions:nil];
        [NSCursor unhide];
        NSAlert* alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"OK"];
        [alert setMessageText:@"Cannot Create Event Tap"];
        [alert setInformativeText:@"You might have to give KeyboardCleaner accessibility access in System Preferences."];
        [alert setAlertStyle:NSAlertStyleCritical];
        [alert beginSheetModalForWindow:self.window completionHandler:^(NSModalResponse returnCode) {
            exit(1);
        }];
        return;
    }
    runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0);
    CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, kCFRunLoopCommonModes);
    CGEventTapEnable(eventTap, true);
    CFRelease(eventTap);
    CFRelease(runLoopSource);
}
- (void)applicationDidFinishLaunching:(NSNotification*)aNotification {
    signal(SIGINT, SIG_IGN);
    [self.window orderFront:nil];
    [self.window setMinSize:self.window.frame.size];
    [self.window setMaxSize:self.window.frame.size];
    [[self.window contentView] setBackgroundColor:NSColor.blackColor];
    [[self.window contentView] enterFullScreenMode:[NSScreen mainScreen] withOptions:nil];
    [NSCursor hide];
    [self tap];
}

@end
