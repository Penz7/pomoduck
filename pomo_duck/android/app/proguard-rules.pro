## Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class com.google.firebase.** { *; }

# Giữ các class cần thiết cho Jackson
-keep class java.beans.** { *; }
-keep class org.w3c.dom.bootstrap.** { *; }
-keep class com.hiennv.flutter_callkit_incoming.** { *; }

# Giữ các class cần thiết cho OkHttp
-keep class org.conscrypt.** { *; }

# Giữ các class của DOM
-keepnames class com.fasterxml.jackson.databind.ext.** { *; }

# Keep Android Window API classes (for BackEvent and related functionality)
-keep class android.window.** { *; }
-keep class androidx.window.** { *; }
-keep class android.view.WindowInsetsAnimationController { *; }
-keep class android.view.WindowInsetsAnimation { *; }
-keep class android.view.WindowInsetsAnimationListener { *; }

# Keep specific BackEvent class that's causing the issue
-keep class android.window.BackEvent { *; }

# Keep the specific method that references BackEvent
-keepclassmembers class io.flutter.view.FlutterView {
    void startBackGesture(android.window.BackEvent);
}

# Keep flutter_inappwebview related classes
-keep class com.pichillilorenzo.flutter_inappwebview.** { *; }
-keep class com.pichillilorenzo.flutter_inappwebview.in_app_browser.** { *; }
-keep class com.pichillilorenzo.flutter_inappwebview.chrome_custom_tabs.** { *; }
-keep class com.pichillilorenzo.flutter_inappwebview.content_blocker.** { *; }
-keep class com.pichillilorenzo.flutter_inappwebview.cookie_manager.** { *; }
-keep class com.pichillilorenzo.flutter_inappwebview.credential_database.** { *; }
-keep class com.pichillilorenzo.flutter_inappwebview.find_interaction.** { *; }
-keep class com.pichillilorenzo.flutter_inappwebview.in_app_webview.** { *; }
-keep class com.pichillilorenzo.flutter_inappwebview.javascript_console_message.** { *; }
-keep class com.pichillilorenzo.flutter_inappwebview.permission.** { *; }
-keep class com.pichillilorenzo.flutter_inappwebview.platform_webview.** { *; }
-keep class com.pichillilorenzo.flutter_inappwebview.pull_to_refresh.** { *; }
-keep class com.pichillilorenzo.flutter_inappwebview.types.** { *; }
-keep class com.pichillilorenzo.flutter_inappwebview.web_storage.** { *; }

# Keep Android WebView related classes
-keep class android.webkit.** { *; }
-keep class android.webkit.WebView { *; }
-keep class android.webkit.WebViewClient { *; }
-keep class android.webkit.WebChromeClient { *; }
-keep class android.webkit.WebSettings { *; }
-keep class android.webkit.WebResourceRequest { *; }
-keep class android.webkit.WebResourceError { *; }
-keep class android.webkit.WebResourceResponse { *; }
-keep class android.webkit.ValueCallback { *; }
-keep class android.webkit.WebViewDatabase { *; }
-keep class android.webkit.CookieManager { *; }
-keep class android.webkit.CookieSyncManager { *; }

# Additional rules for flutter_inappwebview compatibility
-keep class com.pichillilorenzo.flutter_inappwebview.in_app_webview.InAppWebView { *; }
-keep class com.pichillilorenzo.flutter_inappwebview.in_app_webview.InAppWebViewClient { *; }
-keep class com.pichillilorenzo.flutter_inappwebview.in_app_webview.InAppWebChromeClient { *; }

# Keep all methods in FlutterView that might reference BackEvent
-keepclassmembers class io.flutter.view.FlutterView {
    *;
}

# SoLoader rules
-keep class com.facebook.soloader.** { *; }
-dontwarn com.facebook.soloader.**

# CometChat rules
-keep class com.cometchat.** { *; }
-dontwarn com.cometchat.**

# Comprehensive dontwarn rules for all potential missing classes
-dontwarn io.flutter.embedding.**
-dontwarn android.window.**
-dontwarn androidx.window.**
-dontwarn android.view.WindowInsetsAnimation**
-dontwarn com.pichillilorenzo.flutter_inappwebview.**
-dontwarn android.webkit.**

-ignorewarnings
