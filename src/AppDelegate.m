#import "AppDelegate.h"

@implementation AppDelegate

-(instancetype)init {
    [super init];

    [NSApp setActivationPolicy:NSApplicationActivationPolicyAccessory];

    NSRect mainFrame = [[NSScreen mainScreen] frame];
    self.window = [[NSWindow alloc] initWithContentRect:mainFrame
                                              styleMask:0
                                                backing:NSBackingStoreBuffered
                                                  defer:NO];

    [self.window setTitle:@"Keyboard Cleaner"];
    [self.window setLevel:kCGMaximumWindowLevel];
    [self.window setCollectionBehavior:(NSWindowCollectionBehaviorStationary |
        NSWindowCollectionBehaviorIgnoresCycle |
        NSWindowCollectionBehaviorFullScreenNone)];
    [self.window setBackgroundColor:[NSColor blackColor]];

    NSRect mainLabelFrame = NSMakeRect(0, mainFrame.size.height / 2, mainFrame.size.width, 0);
    NSText* mainLabel = [[NSText alloc] initWithFrame:mainLabelFrame];
    [mainLabel setAlignment:NSTextAlignmentCenter];
    [mainLabel setFont:[NSFont systemFontOfSize:55.0]];
    [mainLabel setBackgroundColor:[NSColor clearColor]];
    [mainLabel setTextColor:[NSColor whiteColor]];
    [mainLabel setString:@"Keyboard Cleaner Activated!"];
    [mainLabel setSelectable:FALSE];

    NSRect deactivateFrame = NSMakeRect(0, 25, mainFrame.size.width, 0);
    NSText* deactivateLabel = [[NSText alloc] initWithFrame:deactivateFrame];
    [deactivateLabel setAlignment:NSTextAlignmentCenter];
    [deactivateLabel setFont:[NSFont systemFontOfSize:25.0]];
    [deactivateLabel setBackgroundColor:[NSColor clearColor]];
    [deactivateLabel setTextColor:[NSColor whiteColor]];
    [deactivateLabel setString:@"Hold Right Click for 1 Second and Release to Deactivate"];
    [deactivateLabel setSelectable:FALSE];

    NSImage* lockIcon = [NSImage imageWithSystemSymbolName:@"lock.fill"
                                  accessibilityDescription:@"Lock"];
    [lockIcon setSize:NSMakeSize(100, 100)];

    NSImageView* lockIconView = [NSImageView imageViewWithImage:lockIcon];
    [lockIconView setFrameSize:NSMakeSize(100, 100)];
    [lockIconView setSymbolConfiguration:[NSImageSymbolConfiguration configurationWithPointSize:75.0
                                                                                         weight:0.0]];
    [lockIconView setFrame:NSMakeRect(0, 65, mainFrame.size.width, 75)];
    [lockIconView setContentTintColor:[NSColor whiteColor]];

    [[self.window contentView] addSubview:mainLabel];
    [[self.window contentView] addSubview:lockIconView];
    [[self.window contentView] addSubview:deactivateLabel];

    return self;
}

double rightClickDown;

CGEventRef tapCallback(CGEventTapProxy proxy, CGEventType type, CGEventRef event, void* refcon) {
    double now = [[NSDate date] timeIntervalSince1970];
    if (CGEventGetType(event) == kCGEventRightMouseDown) {
        rightClickDown = now;
    } else if (CGEventGetType(event) == kCGEventRightMouseUp) {
        if (now - rightClickDown >= 1) {
            exit(0);
        }
    }
    return nil;
}

-(void)tap {
    CGEventMask mask = kCGEventMaskForAllEvents;
    CFMachPortRef eventTap = CGEventTapCreate(kCGHIDEventTap, kCGHeadInsertEventTap,
        kCGEventTapOptionDefault, mask, tapCallback, NULL);

    if (!eventTap) {
        [NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];
        [self.window setBackgroundColor:[NSColor whiteColor]];
        [self.window setHasShadow:TRUE];
        [self.window setLevel:NSFloatingWindowLevel];
        [self.window setContentSize:NSMakeSize(500, 500)];
        [self.window setStyleMask:NSWindowStyleMaskTitled];
        [self.window setCollectionBehavior:NSWindowCollectionBehaviorDefault];
        [self.window center];
        [NSCursor unhide];

        NSAlert* alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"OK"];
        [alert setMessageText:@"Failed to Create Event Tap"];
        [alert setInformativeText:@"You might have to grant Keyboard Cleaner accessibility access."];
        [alert setAlertStyle:NSAlertStyleCritical];
        [alert beginSheetModalForWindow:self.window completionHandler:^(NSModalResponse returnCode) {
            exit(1);
        }];

        return;
    }

    CFRunLoopSourceRef runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0);
    CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, kCFRunLoopCommonModes);
    CGEventTapEnable(eventTap, true);

    CFRelease(eventTap);
    CFRelease(runLoopSource);
}

-(void)applicationDidFinishLaunching:(NSNotification*)notification {
    [self.window orderFront:nil];
    [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
    [NSCursor hide];
    [self tap];
}
@end
