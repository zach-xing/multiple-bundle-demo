import UIKit
import React
import React_RCTAppDelegate
import ReactAppDependencyProvider

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?

  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
  ) -> Bool {
    
    // 创建窗口
    window = UIWindow(frame: UIScreen.main.bounds)
    
    // 设置首页页面
    let homeViewController = HomeViewController()
    window?.rootViewController = homeViewController
    window?.makeKeyAndVisible()
    
    return true
  }
  
}

//class ReactNativeDelegate: RCTDefaultReactNativeFactoryDelegate {
//  override func sourceURL(for bridge: RCTBridge) -> URL? {
//    self.bundleURL()
//  }
//
//  override func bundleURL() -> URL? {
//#if DEBUG
//    // 开发环境：从Metro服务器加载bundle
//    RCTBundleURLProvider.sharedSettings().jsBundleURL(forBundleRoot: "index")
//#else
//    // 生产环境：从本地bundle文件加载
//    Bundle.main.url(forResource: "main", withExtension: "jsbundle")
//#endif
//  }
//}
