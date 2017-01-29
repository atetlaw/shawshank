# Shawshank
"I guess it comes down to a simple choice, really. Get busy testing or get busy crying."

## API Examples
### Swift
```swift
Shawshank.take { (components: URLComponents) in
    return components.host == "www.example.com" && components.port == 82
}.fixture(JSONDataFixture(["test":"json"]))
```
```swift
Shawshank.take(matching: .scheme("http") && .host("www.example.com")).httpStatus(.httpStatus(101))
```

### Objective-C
```objc
SHKResponse *testResponse = [SHKResponse new];
testResponse.httpResponse = [[NSHTTPURLResponse alloc] initWithURL:self.testRequest.URL statusCode:101 HTTPVersion:nil headerFields:nil];

[[SHKShawshank takeWithRequestPredicate:^BOOL(NSURLRequest *_Nonnull request ) {
    NSURLComponents *components = [NSURLComponents componentsWithURL:request.URL resolvingAgainstBaseURL:YES];
    return [components.host isEqualToString:@"www.example.com"] && [components.path isEqualToString:@"/path/to"];
}] withResponse:testResponse];
```
