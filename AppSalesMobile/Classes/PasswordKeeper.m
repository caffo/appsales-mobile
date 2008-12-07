#import "PasswordKeeper.h"

#define	ACCOUNT	@"omz:software AppSales Mobile Account"
#define	SERVICE	@"omz:software AppSales Mobile Service"
#define PWKEY	@"omz:software AppSales Mobile Password Data"
#define DEBUG	NO

@implementation PasswordKeeper

static PasswordKeeper *sharedInstance = nil;

+ (PasswordKeeper *)sharedInstance 
{
	if(!sharedInstance) {
		sharedInstance = [[self alloc] init];
    }
    return sharedInstance;
}

// Translate status messages into return strings
- (NSString *) fetchStatus : (OSStatus) status
{
	if		(status == 0) return(@"Success!");
	else if (status == errSecNotAvailable) return(@"No trust results are available.");
	else if (status == errSecItemNotFound) return(@"The item cannot be found.");
	else if (status == errSecParam) return(@"Parameter error.");
	else if (status == errSecAllocate) return(@"Memory allocation error. Failed to allocate memory.");
	else if (status == errSecInteractionNotAllowed) return(@"User interaction is not allowed.");
	else if (status == errSecUnimplemented ) return(@"Function is not implemented");
	else if (status == errSecDuplicateItem) return(@"The item already exists.");
	else if (status == errSecDecode) return(@"Unable to decode the provided data.");
	else return([NSString stringWithFormat:@"Function returned: %d", status]);
}

// Return a base dictionary
- (NSMutableDictionary *) baseDictionary
{
	NSMutableDictionary *md = [[NSMutableDictionary alloc] init];
	
	// Password identification keys
	NSData *identifier = [PWKEY dataUsingEncoding:NSUTF8StringEncoding];
	[md setObject:identifier forKey:(id)kSecAttrGeneric];
	[md setObject:ACCOUNT forKey:(id)kSecAttrAccount];
    [md setObject:SERVICE forKey:(id)kSecAttrService];
	
	// Mandatory Key
	[md setObject:(id)kSecClassGenericPassword forKey:(id)kSecClass];
	
	return [md autorelease];
}

// Build a search query based
- (NSMutableDictionary *) buildSearchQuery
{
	NSMutableDictionary *genericPasswordQuery = [self baseDictionary];
	
	// Add the search constraints
	[genericPasswordQuery setObject:(id)kSecMatchLimitOne forKey:(id)kSecMatchLimit];
	[genericPasswordQuery setObject:(id)kCFBooleanTrue
							 forKey:(id)kSecReturnAttributes];
	[genericPasswordQuery setObject:(id)kCFBooleanTrue
							 forKey:(id)kSecReturnData];
	
	return genericPasswordQuery;
}

// retrieve data dictionary from the keychain
- (NSMutableDictionary *) fetchDictionary
{
	NSMutableDictionary *genericPasswordQuery = [self buildSearchQuery];
	
	NSMutableDictionary *outDictionary = nil;
	OSStatus status = SecItemCopyMatching((CFDictionaryRef)genericPasswordQuery, (CFTypeRef *)&outDictionary);
	if (DEBUG) printf("FETCH: %s\n", [[self fetchStatus:status] UTF8String]);
	
	if (status == errSecItemNotFound) return NULL;
	return outDictionary;
}

// Deserialize from data
- (NSMutableDictionary *) dictionaryFromData: (NSData *) data
{
	NSString *errorString;
	NSMutableDictionary *outDict = [NSPropertyListSerialization propertyListFromData:data mutabilityOption:kCFPropertyListMutableContainersAndLeaves format:NULL errorDescription:&errorString];
	return outDict;
}

// Serialize to data
- (NSData *) dataFromDictionary: (NSMutableDictionary *) dict
{
	
	NSString *errorString;
	NSData *outData = [NSPropertyListSerialization dataFromPropertyList:dict format:NSPropertyListBinaryFormat_v1_0 errorDescription:&errorString];
	return outData;
}

// fetch the keychain value
- (NSMutableDictionary *) fetchKeychainValue
{
	NSMutableDictionary *outDictionary = [self fetchDictionary];
	
	if (outDictionary)
	{
		NSMutableDictionary *dict = [self dictionaryFromData:[outDictionary objectForKey:(id)kSecValueData]];
		[outDictionary release];
		return dict;
	} else return NULL;
}

// remove a keychain entry
- (void) clearKeychain
{
	NSMutableDictionary *genericPasswordQuery = [self baseDictionary];
	
	OSStatus status = SecItemDelete((CFDictionaryRef) genericPasswordQuery);
	if (DEBUG) printf("DELETE: %s\n", [[self fetchStatus:status] UTF8String]);
}

// Return a keychain-style dictionary populated with the password dictionary
- (NSMutableDictionary *) buildDictForPasswordDict:(NSMutableDictionary *) dict
{
	NSData *passwordData = [self dataFromDictionary:dict];
	NSMutableDictionary *passwordDict = [self baseDictionary];
    [passwordDict setObject:passwordData forKey:(id)kSecValueData]; // password 
	
	return passwordDict;
}

// create a new keychain entry
- (BOOL) createKeychainValue:(NSMutableDictionary *) passwordDict
{
	NSMutableDictionary *md = [self buildDictForPasswordDict:passwordDict];
	OSStatus status = SecItemAdd((CFDictionaryRef)md, NULL);
	if (DEBUG) printf("CREATE: %s\n", [[self fetchStatus:status] UTF8String]);
	
	if (status == noErr) return YES; else return NO;
}

// update a keychaing entry
- (BOOL) updateKeychainValue:(NSMutableDictionary *)passwordDict
{
	NSMutableDictionary *genericPasswordQuery = [self baseDictionary];
	NSMutableDictionary *attributesToUpdate = [[NSMutableDictionary alloc] init];
	NSData *passwordData = [self dataFromDictionary:passwordDict];
	[attributesToUpdate setObject:passwordData forKey:(id)kSecValueData];
	
	OSStatus status = SecItemUpdate((CFDictionaryRef)genericPasswordQuery, (CFDictionaryRef)attributesToUpdate);
	if (DEBUG) printf("UPDATE: %s\n", [[self fetchStatus:status] UTF8String]);
	
	if (status == 0) return YES; else return NO;
}

/*
 *  Simple Keychain Access Protocol Methods
 */

- (void) setObject: (id) anObject forKey: (NSString *) aKey
{
	NSMutableDictionary *dict = [self fetchKeychainValue];
	if (dict)
	{
		// Keychain already has object
		[dict setObject:anObject forKey:aKey];
		[self updateKeychainValue:dict];
		return;
	}
	
	// Dictionary not found so create it
	dict = [[NSMutableDictionary alloc] init];
	[dict setObject:anObject forKey:aKey];
	if (![self createKeychainValue:dict]) [self updateKeychainValue:dict];
}

- (void) removeObjectForKey: (NSString *) aKey
{
	NSMutableDictionary *dict = [self fetchKeychainValue];
	if (dict) 
	{
		// Keychain has object
		[dict removeObjectForKey:aKey];
		[self updateKeychainValue:dict];
		return;
	}
}

- (id) objectForKey: (NSString *) aKey
{
	NSMutableDictionary *dict = [self fetchKeychainValue];
	return [dict objectForKey:aKey];
}

- (NSMutableDictionary *) passwordDict
{
	return [self fetchKeychainValue];
}

@end