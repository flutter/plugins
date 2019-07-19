//
//  CookieDto.m
//  webview_flutter
//
//  Created by Jeroen Meijer on 07/07/2019.
//

#import "CookieDto.h"

@implementation CookieDto

+ (instancetype)initWithName:(NSString *)name andValue:(NSString *)value {
  return [[CookieDto alloc] init:name value:value];
}

+ (instancetype)fromDictionary:(NSDictionary<NSString *, NSString *> *)dict {
  return [CookieDto initWithName:[dict valueForKey:@"name"] andValue:[dict valueForKey:@"value"]];
}

+ (instancetype)fromNSHTTPCookie:(NSHTTPCookie *)cookie {
  return [CookieDto initWithName:[cookie name] andValue:[cookie value]];
}

+ (NSArray<CookieDto *> *)manyFromNSHTTPCookies:(NSArray<NSHTTPCookie *> *)cookies {
  NSMutableArray<CookieDto *> *accumulator = [NSMutableArray array];
  for (NSHTTPCookie *cookie in cookies) {
    [accumulator addObject:[CookieDto fromNSHTTPCookie:cookie]];
  }

  return [NSArray arrayWithArray:accumulator];
}

+ (NSArray<CookieDto *> *)manyFromDictionaries:
    (NSArray<NSDictionary<NSString *, NSString *> *> *)cookieDictionaries {
  NSMutableArray<CookieDto *> *accumulator = [NSMutableArray array];
  for (NSDictionary<NSString *, NSString *> *cookieDictionary in cookieDictionaries) {
    [accumulator addObject:[CookieDto fromDictionary:cookieDictionary]];
  }

  return [NSArray arrayWithArray:accumulator];
}

+ (NSArray<NSDictionary<NSString *, NSString *> *> *)manyToDictionary:
    (NSArray<CookieDto *> *)cookieDtos {
  NSMutableArray<NSDictionary<NSString *, NSString *> *> *accumulator = [NSMutableArray array];
  for (CookieDto *cookieDto in cookieDtos) {
    [accumulator addObject:[cookieDto toDictionary]];
  }

  return [NSArray arrayWithArray:accumulator];
}

- (id)init:(NSString *)name value:(NSString *)value {
  self = [self init];
  if (self) {
    self->name = name;
    self->value = value;
  }
  return self;
}

- (NSDictionary<NSString *, NSString *> *)toDictionary {
  return @{
    @"name" : name,
    @"value" : value,
  };
};

- (NSHTTPCookie *)toNSHTTPCookie {
  return [NSHTTPCookie cookieWithProperties:@{NSHTTPCookieName : name, NSHTTPCookieValue : value}];
}

@end
