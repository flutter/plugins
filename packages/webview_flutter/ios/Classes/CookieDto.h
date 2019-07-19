NS_ASSUME_NONNULL_BEGIN

@interface CookieDto : NSObject {
  NSHTTPCookie *originalCookie;
  NSString *name;
  NSString *value;
}

+ (instancetype)initWithName:(NSString *)name andValue:(NSString *)value;

+ (instancetype)fromDictionary:(NSDictionary<NSString *, NSString *> *)dict;

+ (instancetype)fromNSHTTPCookie:(NSHTTPCookie *)cookie;

+ (NSArray<CookieDto *> *)manyFromNSHTTPCookies:(NSArray<NSHTTPCookie *> *)cookies;

+ (NSArray<CookieDto *> *)manyFromDictionaries:
    (NSArray<NSDictionary<NSString *, NSString *> *> *)cookies;

+ (NSArray<NSDictionary<NSString *, NSString *> *> *)manyToDictionary:
    (NSArray<CookieDto *> *)cookieDtos;

- (id)init:(NSString *)name value:(NSString *)value;

- (NSDictionary<NSString *, NSString *> *)toDictionary;

- (NSHTTPCookie *)toNSHTTPCookie;

@end

NS_ASSUME_NONNULL_END
