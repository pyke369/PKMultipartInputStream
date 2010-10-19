// PKMultipartInputStream.h
// py.kerembellec@gmail.com

#import <UIKit/UIKit.h>
#import <MobileCoreServices/UTType.h>
#import "PKMultipartInputStream.h"

#ifndef min
#define min(a,b) ((a) < (b) ? (a) : (b))
#endif

@interface PKMultipartElement : NSObject
{
    @private
    NSData        *headers;
    NSInputStream *body;
    NSUInteger    headersLength, bodyLength, length, delivered;
}
@end


@implementation PKMultipartElement
- (NSString *)mimeTypeForExtension:(NSString *)extension
{
    CFStringRef uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (CFStringRef)extension, NULL);
    if (uti != NULL)
    {
        CFStringRef mime = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType);
        CFRelease(uti);
        if (mime != NULL)
        {
            NSString *type = [NSString stringWithString:(NSString *)mime];
            CFRelease(mime);
            return type;
        }
    }
    return @"application/octet-stream";
}
- (void)updateLength
{
    length = headersLength + bodyLength + 2;
    [body open];
} 
- (id)initWithName:(NSString *)name boundary:(NSString *)boundary string:(NSString *)string
{
    [self init];
    headers       = [[[NSString stringWithFormat:@"--%@\r\nContent-Disposition: form-data; name=\"%@\"\r\n\r\n", boundary, name] dataUsingEncoding:NSUTF8StringEncoding] retain];
    headersLength = [headers length];
    body          = [[NSInputStream inputStreamWithData:[string dataUsingEncoding:NSUTF8StringEncoding]] retain];
    bodyLength    = [[string dataUsingEncoding:NSUTF8StringEncoding] length];
    [self updateLength];
    return self;
}
- (id)initWithName:(NSString *)name boundary:(NSString *)boundary data:(NSData *)data
{
    [self init];
    headers       = [[[NSString stringWithFormat:@"--%@\r\nContent-Disposition: form-data; name=\"%@\"\r\nContent-Type: application/octet-stream\r\n\r\n", boundary, name] dataUsingEncoding:NSUTF8StringEncoding] retain];
    headersLength = [headers length];
    body          = [[NSInputStream inputStreamWithData:data] retain];
    bodyLength    = [data length];
    [self updateLength];
    return self;
}
- (id)initWithName:(NSString *)name boundary:(NSString *)boundary path:(NSString *)path
{
    headers       = [[[NSString stringWithFormat:@"--%@\r\nContent-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\nContent-Type: %@\r\n\r\n", boundary, name, [path lastPathComponent], [self mimeTypeForExtension:[path pathExtension]]] dataUsingEncoding:NSUTF8StringEncoding] retain];
    headersLength = [headers length];
    body          = [[NSInputStream inputStreamWithFileAtPath:path] retain];
    bodyLength    = [[[[NSFileManager defaultManager] attributesOfItemAtPath:path error:NULL] objectForKey:NSFileSize] unsignedIntegerValue];
    [self updateLength];
    return self;
}
- (NSUInteger)length
{
    return length;
}
- (NSUInteger)read:(uint8_t *)buffer maxLength:(NSUInteger)len
{
    NSUInteger sent = 0, read;

    if (delivered >= length)
    {
        return 0;
    }
    if (delivered < headersLength && sent < len)
    {
        read       = min(headersLength - delivered, len - sent);
        [headers getBytes:buffer + sent range:NSMakeRange(delivered, read)];
        sent      += read;
        delivered += sent;
    }
    while (delivered >= headersLength && delivered < (length - 2) && sent < len)
    {
        if ((read = [body read:buffer + sent maxLength:len - sent]) == 0)
        {
            break;
        }
        sent      += read;
        delivered += read;
    }
    if (delivered >= (length - 2) && sent < len)
    {
        if (delivered == (length - 2))
        {
            *(buffer + sent) = '\r';
            sent ++; delivered ++;
        }
        *(buffer + sent) = '\n';
        sent ++; delivered ++;
    }
    return sent;
}
- (void)dealloc
{
    [headers release], headers = nil;
    [body close], [body release], body = nil;
    [super dealloc];
}
@end

@implementation PKMultipartInputStream
- (void)updateLength
{
    NSEnumerator       *enumerator;
    PKMultipartElement *part;

    length     = footerLength;
    enumerator = [parts objectEnumerator];
    while (part = [enumerator nextObject])
    {
        length += [part length];
    }
}
- (id)init
{
    if ((self = [super init]) == nil)
    {
        return nil;
    }
    parts        = [[NSMutableArray arrayWithCapacity:1] retain];
    boundary     = [[[NSProcessInfo processInfo] globallyUniqueString] retain];
    footer       = [[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding] retain];
    footerLength = [footer length];
    [self updateLength];
    return self;
}
- (void)dealloc
{
    [parts release], parts = nil;
    [boundary release], boundary = nil;
    [footer release], footer = nil;
    [super dealloc];
}
- (void)addPartWithName:(NSString *)name string:(NSString *)string
{
    [parts addObject:[[PKMultipartElement alloc] initWithName:name boundary:boundary string:string]];
    [self updateLength];
}
- (void)addPartWithName:(NSString *)name data:(NSData *)data
{
    [parts addObject:[[PKMultipartElement alloc] initWithName:name boundary:boundary data:data]];
    [self updateLength];
}
- (void)addPartWithName:(NSString *)name path:(NSString *)path
{
    [parts addObject:[[PKMultipartElement alloc] initWithName:name boundary:boundary path:path]];
    [self updateLength];
}
- (NSString *)boundary
{
    return boundary;
}
- (NSUInteger)length
{
    return length;
}
- (NSInteger)read:(uint8_t *)buffer maxLength:(NSUInteger)len
{
    NSUInteger sent = 0, read;

    status = NSStreamStatusReading;
    while (delivered < length && sent < len && currentPart < [parts count])
    {
        if ((read = [[parts objectAtIndex:currentPart] read:buffer + sent maxLength:len - sent]) == 0)
        {
            currentPart ++;
            continue;
        }
        sent      += read;
        delivered += read;
    }
    if (delivered >= (length - footerLength) && sent < len)
    {
        read       = min(footerLength - (delivered - (length - footerLength)), len - sent);
        [footer getBytes:buffer + sent range:NSMakeRange(delivered - (length - footerLength), read)];
        sent      += read;
        delivered += read;
    }
    return sent;
}
- (BOOL)hasBytesAvailable
{
    return delivered < length;
}
- (void)open
{
    status = NSStreamStatusOpen;
}
- (void)close
{
    status = NSStreamStatusClosed;
}
- (NSStreamStatus)streamStatus
{
    if (status != NSStreamStatusClosed && delivered >= length)
    {
        status = NSStreamStatusAtEnd;
    }
    return status;
}
- (void)_scheduleInCFRunLoop:(NSRunLoop *)runLoop forMode:(id)mode {}
- (void)_setCFClientFlags:(CFOptionFlags)flags callback:(CFReadStreamClientCallBack)callback context:(CFStreamClientContext)context {}
@end
