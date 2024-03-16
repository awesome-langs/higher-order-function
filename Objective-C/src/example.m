#import <Foundation/Foundation.h>

NSString *p_e_escapeString(NSString *s) {
    NSString *(^p_e_escapeChar)(unichar) = ^NSString *(unichar c) {
        if (c == '\r') return @"\\r";
        if (c == '\n') return @"\\n";
        if (c == '\t') return @"\\t";
        if (c == '\\') return @"\\\\";
        if (c == '\"') return @"\\\"";
        return [NSString stringWithFormat:@"%c", c];
    };
    NSMutableString *result = [NSMutableString string];
    for (NSUInteger i = 0; i < s.length; i++) {
        unichar c = [s characterAtIndex:i];
        [result appendString:p_e_escapeChar(c)];
    }
    return result;
}

typedef NSString *(^FuncType)(id);

FuncType p_e_bool() {
    return Block_copy((^NSString *(NSNumber *b) {
        return b.boolValue ? @"true" : @"false";
    }));
} 

FuncType p_e_int() {
    return Block_copy((^NSString *(NSNumber *i) {
        return i.stringValue;
    }));
}

FuncType p_e_double() {
    return Block_copy((^NSString *(NSNumber *d) {
        return [NSString stringWithFormat:@"%.6f", d.doubleValue];
    }));
}

FuncType p_e_string() {
    return Block_copy((^NSString *(NSString *s) {
        return [NSString stringWithFormat:@"\"%@\"" , p_e_escapeString(s)];
    }));
}

FuncType p_e_list(FuncType f0) {
    return Block_copy((^NSString *(NSArray<id> *lst) {
        NSMutableArray<NSString *> *vs = [NSMutableArray array];
        [lst enumerateObjectsUsingBlock:^(id v, NSUInteger i, BOOL *stop) {
            [vs addObject:f0(v)];
        }];
        return [NSString stringWithFormat:@"[%@]", [vs componentsJoinedByString:@", "]];
    }));
}

FuncType p_e_ulist(FuncType f0) {
    return Block_copy((^NSString *(NSArray<id> *lst) {
        NSMutableArray<NSString *> *vs = [NSMutableArray array];
        [lst enumerateObjectsUsingBlock:^(id v, NSUInteger i, BOOL *stop) {
            [vs addObject:f0(v)];
        }];
        [vs sortUsingSelector:@selector(compare:)];
        return [NSString stringWithFormat:@"[%@]", [vs componentsJoinedByString:@", "]];
    }));
}

FuncType p_e_idict(FuncType f0) {
    NSString *(^f1)(NSNumber *, id) = ^(NSNumber *k, id v) {
        return [NSString stringWithFormat:@"%@=>%@", p_e_int()(k), f0(v)];
    };
    return Block_copy((^NSString *(NSDictionary<NSNumber *, id> *dct) {
        NSMutableArray<NSString *> *vs = [NSMutableArray array];
        [dct enumerateKeysAndObjectsUsingBlock:^(NSNumber *k, id v, BOOL *stop) {
            [vs addObject:f1(k, v)];
        }];
        [vs sortUsingSelector:@selector(compare:)];
        return [NSString stringWithFormat:@"{%@}", [vs componentsJoinedByString:@", "]];
    }));
}

FuncType p_e_sdict(FuncType f0) {
    NSString* (^f1)(NSString *, id) = ^(NSString *k, id v) {
        return [NSString stringWithFormat:@"%@=>%@", p_e_string()(k), f0(v)];
    };
    return Block_copy((^NSString *(NSDictionary<NSString *, id> *dct) {
        NSMutableArray<NSString *> *result = [NSMutableArray array];
        [dct enumerateKeysAndObjectsUsingBlock:^(NSString *k, id v, BOOL *stop) {
            [result addObject:f1(k, v)];
        }];
        [result sortUsingSelector:@selector(compare:)];
        return [NSString stringWithFormat:@"{%@}", [result componentsJoinedByString:@", "]];
    }));
}

FuncType p_e_option(FuncType f0) {
    return Block_copy((^NSString *(id opt) {
        return [opt class] == [NSNull class] ? @"null" : f0(opt);
    }));
}

int main() {
    @autoreleasepool {
        NSString *p_e_out = [@[ p_e_bool()(@YES),
                                p_e_int()(@3),
                                p_e_double()(@3.141592653),
                                p_e_double()(@3.0),
                                p_e_string()(@"Hello, World!"),
                                p_e_string()(@"!@#$%^&*()\\\"\n\t"),
                                p_e_list(p_e_int())(@[@1, @2, @3]),
                                p_e_list(p_e_bool())(@[@YES, @NO, @YES]),
                                p_e_ulist(p_e_int())(@[@3, @2, @1]),
                                p_e_idict(p_e_string())(@{@1: @"one", @2: @"two"}),
                                p_e_sdict(p_e_list(p_e_int()))(@{@"one": @[@1, @2, @3], @"two": @[@4, @5, @6]}),
                                p_e_option(p_e_int())(@42),
                                p_e_option(p_e_int())([NSNull null])
                                ] componentsJoinedByString:@"\n"];
        [p_e_out writeToFile:@"stringify.out" atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }
    return 0;
}