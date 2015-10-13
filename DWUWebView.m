/*
 Copyright (c) 2015 Di Wu diwup@foxmail.com
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

#import "DWUWebView.h"
#import <WebKit/WebKit.h>

static void * DWUWebViewKVOContext = &DWUWebViewKVOContext;

@interface DWUWebView () <WKNavigationDelegate>

@property (nonnull, nonatomic, strong) WKWebView *wkWebView;

- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;

@end

@implementation DWUWebView

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    self.wkWebView.frame = self.bounds;
}

+ (UIWebViewNavigationType)_enumHelperForNavigationType:(WKNavigationType)wkNavigationType {
    switch (wkNavigationType) {
        case WKNavigationTypeLinkActivated:
            return UIWebViewNavigationTypeLinkClicked;
            break;
        case WKNavigationTypeFormSubmitted:
            return UIWebViewNavigationTypeFormSubmitted;
            break;
        case WKNavigationTypeBackForward:
            return UIWebViewNavigationTypeBackForward;
            break;
        case WKNavigationTypeReload:
            return UIWebViewNavigationTypeReload;
            break;
        case WKNavigationTypeFormResubmitted:
            return UIWebViewNavigationTypeFormResubmitted;
            break;
        case WKNavigationTypeOther:
        default:
            return UIWebViewNavigationTypeOther;
            break;
    }
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    if ([self.delegate respondsToSelector:@selector(webView:shouldStartLoadWithRequest:navigationType:)]) {
        BOOL result = [self.delegate webView:(id)self shouldStartLoadWithRequest:[NSURLRequest requestWithURL:webView.URL] navigationType:[DWUWebView _enumHelperForNavigationType:navigationAction.navigationType]];
        if (result) {
            decisionHandler(WKNavigationActionPolicyAllow);
        } else {
            decisionHandler(WKNavigationActionPolicyCancel);
        }
    } else {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    if ([self.delegate respondsToSelector:@selector(webViewDidStartLoad:)]) {
        [self.delegate webViewDidStartLoad:(id)self];
    }
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    if ([self.delegate respondsToSelector:@selector(webViewDidFinishLoad:)]) {
        [self.delegate webViewDidFinishLoad:(id)self];
    }
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(webView:didFailLoadWithError:)]) {
        [self.delegate webView:(id)self didFailLoadWithError:error];
    }
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    return [super initWithCoder:aDecoder];
}

- (nonnull instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        _wkWebView = [[WKWebView alloc] initWithFrame:self.bounds];
        _wkWebView.navigationDelegate = self;
        [self addSubview:_wkWebView];
        [_wkWebView addObserver:self forKeyPath:@"estimatedProgress" options:0 context:DWUWebViewKVOContext];
    }
    return self;
}

- (void)dealloc {
    [self.wkWebView removeObserver:self forKeyPath:@"estimatedProgress" context:DWUWebViewKVOContext];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if (context == DWUWebViewKVOContext) {
        if ([self.progressDelegate respondsToSelector:@selector(webViewUpdateProgress:)]) {
            [self.progressDelegate webViewUpdateProgress:self.wkWebView.estimatedProgress];
        }
    }
}

- (UIScrollView *)scrollView {
    return self.wkWebView.scrollView;
}

- (void)loadRequest:(nonnull NSURLRequest *)request {
    //Ignore the returned WKNavigation object
    [self.wkWebView loadRequest:request];
}

- (void)loadHTMLString:(nonnull NSString *)string baseURL:(nullable NSURL *)baseURL {
    //Ignore the returned WKNavigation object
    [self.wkWebView loadHTMLString:string baseURL:baseURL];
}

- (void)loadData:(nonnull NSData *)data MIMEType:(nonnull NSString *)MIMEType textEncodingName:(nonnull NSString *)textEncodingName baseURL:(nonnull NSURL *)baseURL {
    //Ignore the returned WKNavigation object
    [self.wkWebView loadData:data MIMEType:MIMEType characterEncodingName:textEncodingName baseURL:baseURL];
}

- (NSURLRequest *)request {
    return [NSURLRequest requestWithURL:self.wkWebView.URL];
}

- (void)reload {
    //Ignore the returned WKNavigation object
    [self.wkWebView reload];
}

- (void)stopLoading {
    [self.wkWebView stopLoading];
}

- (void)goBack {
    //Ignore the returned WKNavigation object
    [self.wkWebView goBack];
}

- (void)goForward {
    //Ignore the returned WKNavigation object
    [self.wkWebView goForward];
}

- (BOOL)canGoBack {
    return self.wkWebView.canGoBack;
}

- (BOOL)canGoForward {
    return self.wkWebView.canGoForward;
}

- (BOOL)isLoading {
    return self.wkWebView.isLoading;
}

- (nullable NSString *)stringByEvaluatingJavaScriptFromString:(nonnull NSString *)script {
    __block NSString *resultString = @"Garbage Value.";
    [self.wkWebView evaluateJavaScript:script completionHandler:^(id _Nullable result, NSError * _Nullable error) {
            if (error == nil) {
                if (result != nil) {
                    resultString = [NSString stringWithFormat:@"%@", result];
                }
            }
    }];
    return resultString;
}

- (BOOL)allowsLinkPreview {
    return self.wkWebView.allowsLinkPreview;
}

- (void)setAllowsLinkPreview:(BOOL)allowsLinkPreview {
    self.wkWebView.allowsLinkPreview = allowsLinkPreview;
}

- (BOOL)scalesPageToFit {
    //This API is not found in WKWebView
    return NO;
}

- (void)setScalesPageToFit:(BOOL)scalesPageToFit {
    //This API is not found in WKWebView
}

- (UIDataDetectorTypes)dataDetectorTypes {
    //This API is not found in WKWebView
    return UIDataDetectorTypeNone;
}

- (void)setDataDetectorTypes:(UIDataDetectorTypes)dataDetectorTypes {
    //This API is not found in WKWebView
}

- (BOOL)allowsInlineMediaPlayback {
    return self.wkWebView.configuration.allowsInlineMediaPlayback;
}

- (void)setAllowsInlineMediaPlayback:(BOOL)allowsInlineMediaPlayback {
    //This property is not settable after web view initialization
}

- (BOOL)mediaPlaybackRequiresUserAction {
    return self.wkWebView.configuration.mediaPlaybackRequiresUserAction;
}

- (void)setMediaPlaybackRequiresUserAction:(BOOL)mediaPlaybackRequiresUserAction {
    //This property is not settable after web view initialization
}

- (BOOL)mediaPlaybackAllowsAirPlay {
    return self.wkWebView.configuration.mediaPlaybackAllowsAirPlay;
}

- (void)setMediaPlaybackAllowsAirPlay:(BOOL)mediaPlaybackAllowsAirPlay {
    //This property is not settable after web view initialization
}

- (BOOL)suppressesIncrementalRendering {
    return self.wkWebView.configuration.suppressesIncrementalRendering;
}

- (void)setSuppressesIncrementalRendering:(BOOL)suppressesIncrementalRendering {
    //This property is not settable after web view initialization
}

- (BOOL)keyboardDisplayRequiresUserAction {
    //This API is not found in WKWebView
    return NO;
}

- (void)setKeyboardDisplayRequiresUserAction:(BOOL)keyboardDisplayRequiresUserAction {
    //This API is not found in WKWebView
}

- (UIWebPaginationMode)paginationMode {
    //This API is not found in WKWebView
    return UIWebPaginationModeUnpaginated;
}

- (void)setPaginationMode:(UIWebPaginationMode)paginationMode {
    //This API is not found in WKWebView
}

- (UIWebPaginationBreakingMode)paginationBreakingMode {
    //This API is not found in WKWebView
    return UIWebPaginationBreakingModePage;
}

- (CGFloat)pageLength {
    //This API is not found in WKWebView
    return 0;
}

- (void)setPageLength:(CGFloat)pageLength {
    //This API is not found in WKWebView
}

- (CGFloat)gapBetweenPages {
    //This API is not found in WKWebView
    return 0;
}

- (void)setGapBetweenPages:(CGFloat)gapBetweenPages {
    //This API is not found in WKWebView
}

- (NSUInteger)pageCount {
    //This API is not found in WKWebView
    return 0;
}

- (BOOL)allowsPictureInPictureMediaPlayback {
    return self.wkWebView.configuration.allowsPictureInPictureMediaPlayback;
}

- (void)setAllowsPictureInPictureMediaPlayback:(BOOL)allowsPictureInPictureMediaPlayback {
    //This property is not settable after web view initialization
}

@end
