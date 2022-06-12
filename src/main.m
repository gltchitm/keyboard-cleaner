#import <Cocoa/Cocoa.h>
#import "AppDelegate.m"

int main(void) {
    NSApplication* application = [NSApplication sharedApplication];

    AppDelegate* applicationDelegate = [[AppDelegate alloc] init];
    [application setDelegate:applicationDelegate];

    [application run];
}
