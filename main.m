// PKMultipartInputStream
// py.kerembellec@gmail.com

#import <UIKit/UIKit.h>
#import "PKMultipartInputStream.h"

@interface PKMISController : UIViewController
{
    UIButton       *action;
    UIProgressView *progress;
    UITextView     *message;
}
@end

@implementation PKMISController
- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    if (totalBytesExpectedToWrite > 0)
    {
        progress.progress = (double)totalBytesWritten / (double)totalBytesExpectedToWrite;
        if (totalBytesExpectedToWrite <= totalBytesWritten)
        {
            message.text = @"Data post complete";
        }
        else
        {
            message.text = [NSString stringWithFormat:@"%.2fMB / %.2fMB (%.1f%%)", (double)totalBytesWritten / (1024 * 1024), (double)totalBytesExpectedToWrite / (1024 * 1024), ((double)totalBytesWritten * 100) / (double)totalBytesExpectedToWrite];
        }
    }
}
- (void)upload:(id)sender
{
    PKMultipartInputStream *body = [[PKMultipartInputStream alloc] init];
    [body addPartWithName:@"string1" string:@"string1 value"];
    [body addPartWithName:@"data1" data:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Icon" ofType:@"png"]]];
    [body addPartWithName:@"file1" path:[[NSBundle mainBundle] pathForResource:@"file1" ofType:@"flv"]];
    [body addPartWithName:@"string2" string:@"string2 value"];
    [body addPartWithName:@"data2" data:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"]]];
    [body addPartWithName:@"file2" path:[[NSBundle mainBundle] pathForResource:@"file2" ofType:@"jpg"]];
    [body addPartWithName:@"string3" string:@"string3 value"];
    [body addPartWithName:@"data3" data:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] executablePath]]];
    [body addPartWithName:@"file3" path:[[NSBundle mainBundle] pathForResource:@"file3" ofType:@"mp3"]];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://asite.com/upload.php"]];
    [request setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", [body boundary]] forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[body length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBodyStream:body];
    [request setHTTPMethod:@"POST"];
    [[NSURLConnection alloc] initWithRequest:request delegate:self];
    action.enabled = NO;
    message.text   = @"Starting data post";
}
- (void)loadView
{
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];

    action = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    action.frame = CGRectMake(60, 150, 200, 36);
    [action setTitle:@"Start data post" forState:UIControlStateNormal];
    [action setTitle:@"Posting data..." forState:UIControlStateDisabled];
    [action setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    [action addTarget:self action:@selector(upload:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:action];

    progress = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    progress.frame = CGRectMake(30, 250, 260, 36);
    [self.view addSubview:progress];

    message = [[UITextView alloc] initWithFrame:CGRectMake(30, 260, 260, 24)];
    message.backgroundColor = [UIColor blackColor];
    message.textColor = [UIColor whiteColor];
    message.textAlignment = UITextAlignmentCenter;
    [self.view addSubview:message];
}
@end

@interface PKMISDelegate : NSObject <UIApplicationDelegate>
{
    UIWindow        *window;
    PKMISController *main;
}
@end

@implementation PKMISDelegate
- (void)applicationDidFinishLaunching:(UIApplication *)application
{
    window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    main   = [PKMISController alloc];
    [window addSubview:main.view];
    [window makeKeyAndVisible];
}
@end

int main(int argc, char **argv)
{
    @autoreleasepool
    {
        int retVal = UIApplicationMain(argc, argv, nil, NSStringFromClass([PKMISDelegate class]));
        return retVal;
    }
}
