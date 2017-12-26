// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
//
//  CloudFirestoreCodec.m
//  cloud_firestore
//
//  Created by ananfang on 26/12/2017.
//

#import "CloudFirestoreCodec.h"

#pragma mark - CloudFirestoreCodecHelper
@implementation CloudFirestoreCodecHelper
+ (CloudFirestoreField)cloudFirestoreFieldForDataType:(FlutterStandardDataType)type {
    return (CloudFirestoreField)(type + CloudFirestoreFieldUInt8Data);
}

+ (FlutterStandardDataType)flutterStandardDataTypeForField:(CloudFirestoreField)field {
    return (FlutterStandardDataType)(field - CloudFirestoreFieldUInt8Data);
}

+ (UInt8)elementSizeForFlutterStandardDataType:(FlutterStandardDataType)type {
    switch (type) {
        case FlutterStandardDataTypeUInt8:
            return 1;
        case FlutterStandardDataTypeInt32:
            return 4;
        case FlutterStandardDataTypeInt64:
            return 8;
        case FlutterStandardDataTypeFloat64:
            return 8;
    }
}
@end

#pragma mark - 
@implementation FlutterStandardWriter {
    NSMutableData* _data;
}

+ (instancetype)writerWithData:(NSMutableData*)data {
    FlutterStandardWriter* writer = [[FlutterStandardWriter alloc] initWithData:data];
    [writer autorelease];
    return writer;
}

- (instancetype)initWithData:(NSMutableData*)data {
    self = [super init];
    NSAssert(self, @"Super init cannot be nil");
    _data = [data retain];
    return self;
}

- (void)dealloc {
    [_data release];
    [super dealloc];
}

- (void)writeByte:(UInt8)value {
    [_data appendBytes:&value length:1];
}

- (void)writeSize:(UInt32)size {
    if (size < 254) {
        [self writeByte:(UInt8)size];
    } else if (size <= 0xffff) {
        [self writeByte:254];
        UInt16 value = (UInt16)size;
        [_data appendBytes:&value length:2];
    } else {
        [self writeByte:255];
        [_data appendBytes:&size length:4];
    }
}

- (void)writeAlignment:(UInt8)alignment {
    UInt8 mod = _data.length % alignment;
    if (mod) {
        for (int i = 0; i < (alignment - mod); i++) {
            [self writeByte:0];
        }
    }
}

- (void)writeUTF8:(NSString*)value {
    UInt32 length = [value lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    [self writeSize:length];
    [_data appendBytes:value.UTF8String length:length];
}

- (void)writeValue:(id)value {
    if (value == nil || value == [NSNull null]) {
        [self writeByte:FlutterStandardFieldNil];
    } else if ([value isKindOfClass:[NSNumber class]]) {
        NSNumber* number = value;
        const char* type = [number objCType];
        if ([self isBool:number type:type]) {
            BOOL b = number.boolValue;
            [self writeByte:(b ? FlutterStandardFieldTrue : FlutterStandardFieldFalse)];
        } else if (strcmp(type, @encode(signed int)) == 0 || strcmp(type, @encode(signed short)) == 0 ||
                   strcmp(type, @encode(unsigned short)) == 0 ||
                   strcmp(type, @encode(signed char)) == 0 ||
                   strcmp(type, @encode(unsigned char)) == 0) {
            SInt32 n = number.intValue;
            [self writeByte:FlutterStandardFieldInt32];
            [_data appendBytes:(UInt8*)&n length:4];
        } else if (strcmp(type, @encode(signed long)) == 0 ||
                   strcmp(type, @encode(unsigned int)) == 0) {
            SInt64 n = number.longValue;
            [self writeByte:FlutterStandardFieldInt64];
            [_data appendBytes:(UInt8*)&n length:8];
        } else if (strcmp(type, @encode(double)) == 0 || strcmp(type, @encode(float)) == 0) {
            Float64 f = number.doubleValue;
            [self writeByte:FlutterStandardFieldFloat64];
            [self writeAlignment:8];
            [_data appendBytes:(UInt8*)&f length:8];
        } else if (strcmp(type, @encode(unsigned long)) == 0 ||
                   strcmp(type, @encode(signed long long)) == 0 ||
                   strcmp(type, @encode(unsigned long long)) == 0) {
            NSString* hex = [NSString stringWithFormat:@"%llx", number.unsignedLongLongValue];
            [self writeByte:FlutterStandardFieldIntHex];
            [self writeUTF8:hex];
        } else {
            NSLog(@"Unsupported value: %@ of type %s", value, type);
            NSAssert(NO, @"Unsupported value for standard codec");
        }
    } else if ([value isKindOfClass:[NSString class]]) {
        NSString* string = value;
        [self writeByte:FlutterStandardFieldString];
        [self writeUTF8:string];
    } else if ([value isKindOfClass:[FlutterStandardBigInteger class]]) {
        FlutterStandardBigInteger* bigInt = value;
        [self writeByte:FlutterStandardFieldIntHex];
        [self writeUTF8:bigInt.hex];
    } else if ([value isKindOfClass:[FlutterStandardTypedData class]]) {
        FlutterStandardTypedData* typedData = value;
        [self writeByte:FlutterStandardFieldForDataType(typedData.type)];
        [self writeSize:typedData.elementCount];
        [self writeAlignment:typedData.elementSize];
        [_data appendData:typedData.data];
    } else if ([value isKindOfClass:[NSArray class]]) {
        NSArray* array = value;
        [self writeByte:FlutterStandardFieldList];
        [self writeSize:array.count];
        for (id object in array) {
            [self writeValue:object];
        }
    } else if ([value isKindOfClass:[NSDictionary class]]) {
        NSDictionary* dict = value;
        [self writeByte:FlutterStandardFieldMap];
        [self writeSize:dict.count];
        for (id key in dict) {
            [self writeValue:key];
            [self writeValue:[dict objectForKey:key]];
        }
    } else {
        NSLog(@"Unsupported value: %@ of type %@", value, [value class]);
        NSAssert(NO, @"Unsupported value for standard codec");
    }
}

- (BOOL)isBool:(NSNumber*)number type:(const char*)type {
    return strcmp(type, @encode(signed char)) == 0 &&
    [NSStringFromClass([number class]) isEqual:@"__NSCFBoolean"];
}
@end
