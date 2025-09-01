//
//  BundleLoader.swift
//  MyTestApp
//
//  Created by Zeekg on 2025/8/31.
//

import Foundation
import React

/**
 * Bundle加载管理器
 * 负责管理多个bundle包的加载和初始化
 */
class BundleLoader: NSObject {
  
  // MARK: - 单例模式
  static let shared = BundleLoader()
  private override init() {
    super.init()
  }
  
  // MARK: - 属性
  private var loadedBundles: [String: Bool] = [:]
  private var bundleLoadCallbacks: [String: [(Bool) -> Void]] = [:]
  private var isLoadingBundles: [String: Bool] = [:] // 防止重复加载
  
  // MARK: - Bundle加载方法
  
  /**
   * 加载基础bundle包
   * @param completion 加载完成回调
   */
  func loadBasicBundle(completion: @escaping (Bool) -> Void) {
    let bundleName = "basic"
    
    // 检查是否已经加载
    if loadedBundles[bundleName] == true {
      print("基础bundle包已经加载，直接返回")
      completion(true)
      return
    }
    
    // 检查是否正在加载中
    if isLoadingBundles[bundleName] == true {
      print("基础bundle包正在加载中，等待完成...")
      // 将回调添加到等待队列
      if bundleLoadCallbacks[bundleName] == nil {
        bundleLoadCallbacks[bundleName] = []
      }
      bundleLoadCallbacks[bundleName]?.append(completion)
      return
    }
    
    print("开始加载基础bundle包...")
    isLoadingBundles[bundleName] = true
    
    // 根据环境加载不同的bundle
    DispatchQueue.global(qos: .userInitiated).async {
      var loadSuccess = false
      
      #if DEBUG
      // 开发环境：basic 包不用单独加载，直接加载业务包就行，会自动也把 basic 包加载的
      loadSuccess = true
      #else
      // 生产环境：从本地bundle文件加载
      print("生产环境：从本地文件加载基础bundle")
      loadSuccess = self.loadBundleFromLocal(bundleName: bundleName, needLoad: true)
      #endif
      
      DispatchQueue.main.async {
        self.loadedBundles[bundleName] = loadSuccess
        self.isLoadingBundles[bundleName] = false
        
        if loadSuccess {
          print("基础bundle包加载完成")
        } else {
          print("基础bundle包加载失败")
        }
        
        // 执行主回调
        completion(loadSuccess)
        
        // 执行等待中的回调
        if let callbacks = self.bundleLoadCallbacks[bundleName] {
          for callback in callbacks {
            callback(loadSuccess)
          }
          self.bundleLoadCallbacks[bundleName] = nil
        }
      }
    }
  }
  
  /**
   * 加载业务bundle包
   * @param completion 加载完成回调
   */
  func loadBusinessBundle(completion: @escaping (Bool) -> Void) {
    let bundleName = "main"
    
    // 检查是否已经加载
    if loadedBundles[bundleName] == true {
      print("业务bundle包已经加载，直接返回")
      completion(true)
      return
    }
    
    // 检查是否正在加载中
    if isLoadingBundles[bundleName] == true {
      print("业务bundle包正在加载中，等待完成...")
      if bundleLoadCallbacks[bundleName] == nil {
        bundleLoadCallbacks[bundleName] = []
      }
      bundleLoadCallbacks[bundleName]?.append(completion)
      return
    }
    
    print("开始加载业务bundle包...")
    isLoadingBundles[bundleName] = true
    
    // 确保基础bundle已加载
    loadBasicBundle { [weak self] success in
      guard let self = self, success else {
        print("基础bundle加载失败，无法加载业务bundle")
        self?.isLoadingBundles[bundleName] = false
        completion(false)
        return
      }
      
      // 根据环境加载业务bundle
      DispatchQueue.global(qos: .userInitiated).async {
        var loadSuccess = false
        
        #if DEBUG
        // 开发环境：从Metro服务器加载bundle
        print("开发环境：从Metro服务器加载业务bundle")
        loadSuccess = self.loadBundleFromMetro(bundleName: bundleName)
        #else
        // 生产环境：从本地bundle文件加载
        print("生产环境：从本地文件加载业务bundle")
        loadSuccess = self.loadBundleFromLocal(bundleName: bundleName)
        #endif
        
        DispatchQueue.main.async {
          self.loadedBundles[bundleName] = loadSuccess
          self.isLoadingBundles[bundleName] = false
          
          if loadSuccess {
            print("业务bundle包加载完成")
          } else {
            print("业务bundle包加载失败")
          }
          
          // 执行主回调
          completion(loadSuccess)
          
          // 执行等待中的回调
          if let callbacks = self.bundleLoadCallbacks[bundleName] {
            for callback in callbacks {
              callback(loadSuccess)
            }
            self.bundleLoadCallbacks[bundleName] = nil
          }
        }
      }
    }
  }
  
  /**
   * 预加载所有bundle包
   * @param completion 所有bundle加载完成回调
   */
  func preloadAllBundles(completion: @escaping (Bool) -> Void) {
    print("开始预加载所有bundle包...")
    
    // 使用串行加载，确保正确的顺序
    loadBasicBundle { [weak self] basicSuccess in
      guard let self = self, basicSuccess else {
        print("基础bundle加载失败")
        completion(false)
        return
      }
      
      // 基础包加载成功后，再加载业务包
      self.loadBusinessBundle { businessSuccess in
        if businessSuccess {
          print("所有bundle包预加载完成")
          completion(true)
        } else {
          print("业务bundle加载失败")
          completion(false)
        }
      }
    }
  }
  
  /**
   * 检查bundle是否已加载
   * @param bundleName bundle名称
   * @return 是否已加载
   */
  func isBundleLoaded(_ bundleName: String) -> Bool {
    return loadedBundles[bundleName] == true
  }
  
  /**
   * 获取bundle加载状态
   * @return 所有bundle的加载状态
   */
  func getBundleLoadStatus() -> [String: Bool] {
    return loadedBundles
  }
  
  /**
   * 获取bundle加载进度
   * @return 加载进度信息
   */
  func getBundleLoadProgress() -> [String: Any] {
    var progress: [String: Any] = [:]
    
    for (bundleName, isLoaded) in loadedBundles {
      progress[bundleName] = [
        "loaded": isLoaded,
        "loading": isLoadingBundles[bundleName] ?? false
      ]
    }
    
    return progress
  }
  
  /**
   * 重置加载状态（用于测试）
   */
  func resetLoadStatus() {
    loadedBundles.removeAll()
    isLoadingBundles.removeAll()
    bundleLoadCallbacks.removeAll()
    print("Bundle加载状态已重置")
  }
  
  // MARK: - 公共bundle管理
  
  /**
   * 预加载公共bundle包
   * 在应用启动时调用，确保公共资源可用
   * @param completion 加载完成回调
   */
  func preloadCommonBundle(completion: @escaping (Bool) -> Void) {
    let bundleName = "common"
    
    // 检查是否已经加载
    if loadedBundles[bundleName] == true {
      print("公共bundle包已经加载，直接返回")
      completion(true)
      return
    }
    
    // 检查是否正在加载中
    if isLoadingBundles[bundleName] == true {
      print("公共bundle包正在加载中，等待完成...")
      if bundleLoadCallbacks[bundleName] == nil {
        bundleLoadCallbacks[bundleName] = []
      }
      bundleLoadCallbacks[bundleName]?.append(completion)
      return
    }
    
    print("开始预加载公共bundle包...")
    isLoadingBundles[bundleName] = true
    
    // 根据环境加载公共bundle
    DispatchQueue.global(qos: .userInitiated).async {
      var loadSuccess = false
      
      #if DEBUG
      // 开发环境：从Metro服务器加载
      print("开发环境：从Metro服务器加载公共bundle")
      loadSuccess = self.loadBundleFromMetro(bundleName: bundleName)
      #else
      // 生产环境：从本地文件加载
      print("生产环境：从本地文件加载公共bundle")
      loadSuccess = self.loadBundleFromLocal(bundleName: bundleName)
      #endif
      
      DispatchQueue.main.async {
        self.loadedBundles[bundleName] = loadSuccess
        self.isLoadingBundles[bundleName] = false
        
        if loadSuccess {
          print("公共bundle包预加载完成")
        } else {
          print("公共bundle包预加载失败")
        }
        
        // 执行主回调
        completion(loadSuccess)
        
        // 执行等待中的回调
        if let callbacks = self.bundleLoadCallbacks[bundleName] {
          for callback in callbacks {
            callback(loadSuccess)
          }
          self.bundleLoadCallbacks[bundleName] = nil
        }
      }
    }
  }
  
  // MARK: - 私有加载方法
  
  /**
   * 从Metro服务器加载bundle（开发环境）
   * @param bundleName bundle名称
   * @return 是否加载成功
   */
  private func loadBundleFromMetro(bundleName: String) -> Bool {
    // 这里实现从Metro服务器加载bundle的逻辑
    // 可以使用RCTBundleURLProvider来获取bundle URL
    
    // 模拟网络加载延迟
    Thread.sleep(forTimeInterval: 0.5)
    
    // 检查Metro服务器是否可用
    let metroURL = "http://localhost:8081"
    // 这里可以添加实际的网络检查逻辑
    
    print("从Metro服务器加载 \(bundleName) bundle")
    return true // 开发环境假设总是成功
  }
  
  /**
   * 从本地文件加载bundle（生产环境）
   * @param bundleName bundle名称
   * @return 是否加载成功
   */
  private func loadBundleFromLocal(bundleName: String, needLoad: Bool = false) -> Bool {
    // 从本地bundle文件加载
    let bundleFileName = "\(bundleName).jsbundle"
    
    // 检查本地bundle文件是否存在
    if let bundlePath = Bundle.main.path(forResource: bundleName, ofType: "jsbundle") {
      print("找到本地bundle文件：\(bundlePath)")
      
      // 这里可以添加实际的本地文件读取和验证逻辑
      // 例如检查文件完整性、版本号等
      if needLoad {
        // let bundleURL = URL(fileURLWithPath: bundlePath)
        // let bridge = RCTBridge(delegate: nil, launchOptions: nil)
        
        // // 预加载bundle
        // bridge?.loadAndExecuteSplitBundleURL(bundleURL, onError: { error in
        //   print("加载本地bundle失败：\(error)")
        // }, onComplete: {
        //   print("本地bundle加载完成：\(bundleName)")
        // })
      }
      
      return true
    } else {
      print("未找到本地bundle文件：\(bundleFileName)")
      return false
    }
  }
  
  /**
   * 创建加载状态视图
   */
  private func createLoadingView() -> UIView {
    let loadingView = UIView()
    loadingView.backgroundColor = UIColor.white
    
    let activityIndicator = UIActivityIndicatorView(style: .large)
    activityIndicator.color = UIColor.systemBlue
    activityIndicator.startAnimating()
    
    let label = UILabel()
    label.text = "加载中..."
    label.textAlignment = .center
    label.textColor = UIColor.systemGray
    
    loadingView.addSubview(activityIndicator)
    loadingView.addSubview(label)
    
    // 设置约束（这里简化处理）
    activityIndicator.center = CGPoint(x: loadingView.bounds.midX, y: loadingView.bounds.midY - 20)
    label.center = CGPoint(x: loadingView.bounds.midX, y: loadingView.bounds.midY + 20)
    
    return loadingView
  }
}
