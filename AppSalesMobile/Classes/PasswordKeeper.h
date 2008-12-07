#import <UIKit/UIKit.h>
#import <Security/Security.h>

// This code works on the device but not in the simulator

// Password Keeper securely saves a password dictionary
@interface PasswordKeeper: NSObject
+ (PasswordKeeper *) sharedInstance;
- (void) setObject: (id) anObject forKey: (NSString *) aKey;
- (void) removeObjectForKey: (NSString *) aKey;
- (id) objectForKey: (NSString *) aKey;
- (NSMutableDictionary *) passwordDict;
@end