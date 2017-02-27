#import "notify.h"

NSString *getBundleIdentifier(NSString *appName){
        NSString *findString = [NSString stringWithFormat:@"get id of application \"%@\"", appName];
        NSAppleScript *findScript = [[NSAppleScript alloc] initWithSource:findString];
        NSAppleEventDescriptor *resultDescriptor = [findScript executeAndReturnError:nil];
        return [resultDescriptor stringValue];
}

BOOL setApplication(NSString *newbundleIdentifier) {
        if(LSCopyApplicationURLsForBundleIdentifier((CFStringRef)newbundleIdentifier, NULL) != NULL) {
                fakeBundleIdentifier = newbundleIdentifier;
                return YES;
        }
        return NO;
}

void scheduleNotification(NSString *title, NSString *message, NSString *sound, double deliveryDate) {
        @autoreleasepool {
                if (!installNSBundleHook()) {
                        return;
                }
                // NSDate *scheduleTime = [NSDate dateWithTimeIntervalSince1970:deliveryDate];
                NSDate *scheduleTime = [NSDate dateWithTimeIntervalSinceNow:deliveryDate];
                NSUserNotificationCenter *nc = [NSUserNotificationCenter defaultUserNotificationCenter];
                NotificationCenterDelegate *ncDelegate = [[NotificationCenterDelegate alloc] init];
                ncDelegate.keepRunning = YES;
                nc.delegate = ncDelegate;

                NSUserNotification *note = [[NSUserNotification alloc] init];
                note.title = title;
                note.informativeText = message;
                note.deliveryDate = scheduleTime;
                if (![sound isEqualToString:@"_mute"]) {
                        note.soundName = sound;
                }

                [nc scheduleNotification:note];
        }
}

void sendNotification(NSString *title, NSString *message, NSString *sound) {
        @autoreleasepool {
                if (!installNSBundleHook()) {
                        return;
                }

                NSUserNotificationCenter *nc = [NSUserNotificationCenter defaultUserNotificationCenter];
                NotificationCenterDelegate *ncDelegate = [[NotificationCenterDelegate alloc]init];
                ncDelegate.keepRunning = YES;
                nc.delegate = ncDelegate;

                NSUserNotification *note = [[NSUserNotification alloc] init];
                note.title = title;
                note.informativeText = message;
                if (![sound isEqualToString:@"_mute"]) {
                        note.soundName = sound;
                }
                [nc deliverNotification:note];

                while (ncDelegate.keepRunning) {
                        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
                }
        }
}
