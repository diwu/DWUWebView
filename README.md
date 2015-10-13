#DWUWebView

A **WKWebView** wrapper that serves as a drop-in replacement for the legacy **UIWebView**.


#Why WKWebView?

Facebook migrated from UIWebView to WKWebView and reported [a significant reduction of OOMs][fb_blog] due to the fact that WKWebView now renders web pages in separate processes out of the app.

Besides, WKWebView is [so much faster][performance_blog] than UIWebView that your web development co-workers might burst into tears.

#Installation

Step 1: Drag [DWUWebView.h][h_file] and [DWUWebView.m][m_file] into your project.

Step 2: There's no step 2.

Or, if you are using CocoaPods, add the following requirement into your Podfile:

`pod 'DWUWebView'`

#Accurate Loading Progress

If you are using that popular JavaScript trick to simulate the web page loading progress, DWUWebView will likely break it (see *Known Issues* below). However, thanks to the new APIs brought by WKWebView, you can now have much more accurate loading progress callbacks.

See `DWUWebViewProgressDelegate` in [DWUWebView.h][h_file] for more details. It's a delegation style API and is really easy to use.


#Known Issues

Due to WKWebView's implementation details, you can find a list of unsupported APIs in [DWUWebView.h][h_file].

Besides, due to an architectural change that forces WKWebView to process JavaScript injection on an asynchronous basis. The `stringByEvaluatingJavaScriptFromString:` API will always return a garbage value. So do not use its return value.



[h_file]: ./DWUWebView.h
[m_file]: ./DWUWebView.m
[fb_blog]: https://code.facebook.com/posts/1146930688654547/reducing-fooms-in-the-facebook-ios-app/
[performance_blog]: http://blog.initlabs.com/post/100113463211/wkwebview-vs-uiwebview






