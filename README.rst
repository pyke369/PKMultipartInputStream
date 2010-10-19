######################
PKMultipartInputStream
######################

This NSInputStream subclass is suitable for building multipart/form-data HTTP requests bodies in MacOSX/iOS applications.

=====
Usage
=====

A very simple example is presented below::

    PKMultipartInputStream *body = [[PKMultipartInputStream alloc] init];
    [body addPartWithName:@"string" string:@"value"];
    [body addPartWithName:@"data" data:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"image" ofType:@"png"]]];
    [body addPartWithName:@"file" path:[[NSBundle mainBundle] pathForResource:@"video" ofType:@"mp4"]];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://site.com/upload.php"]];
    [request setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", [body boundary]] forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%d", [body length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBodyStream:body];
    [request setHTTPMethod:@"POST"];
    [[NSURLConnection alloc] initWithRequest:request delegate:self];

An example iOS application is provided along with the class code, please refer to it.
