// PKMultipartInputStream.h
// py.kerembellec@gmail.com

@interface PKMultipartInputStream : NSInputStream
- (void)addPartWithName:(NSString *)name string:(NSString *)string;
- (void)addPartWithName:(NSString *)name data:(NSData *)data; //the same as bellow with content type application/octet-stream
- (void)addPartWithName:(NSString *)name data:(NSData *)data contentType:(NSString *)type;
- (void)addPartWithName:(NSString *)name path:(NSString *)path;
- (void)addPartWithName:(NSString *)name filename:(NSString *)filename path:(NSString *)path;

@property (nonatomic, readonly) NSString *boundary;
@property (nonatomic, readonly) NSUInteger length;
@end
