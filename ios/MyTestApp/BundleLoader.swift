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
  private var bundleLoadCallbacks: [String: [() -> Void]] = [:]
  
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
    
    print("开始加载基础bundle包...")
    
    // 模拟bundle加载过程
    DispatchQueue.global(qos: .userInitiated).async {
      // 这里可以添加实际的bundle加载逻辑
      // 例如从网络下载、本地文件读取等
      
      DispatchQueue.main.async {
        self.loadedBundles[bundleName] = true
        print("基础bundle包加载完成")
        completion(true)
      }
    }
  }
  
  /**
   * 加载业务bundle包
   * @param completion 加载完成回调
   */
  func loadBusinessBundle(completion: @escaping (Bool) -> Void) {
    let bundleName = "business"
    
    // 检查是否已经加载
    if loadedBundles[bundleName] == true {
      print("业务bundle包已经加载，直接返回")
      completion(true)
      return
    }
    
    print("开始加载业务bundle包...")
    
    // 确保基础bundle已加载
    loadBasicBundle { [weak self] success in
      guard let self = self, success else {
        print("基础bundle加载失败，无法加载业务bundle")
        completion(false)
        return
      }
      
      // 模拟业务bundle加载过程
      DispatchQueue.global(qos: .userInitiated).async {
        // 这里可以添加实际的bundle加载逻辑
        
        DispatchQueue.main.async {
          self.loadedBundles[bundleName] = true
          print("业务bundle包加载完成")
          completion(true)
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
   * 重置加载状态（用于测试）
   */
  func resetLoadStatus() {
    loadedBundles.removeAll()
    print("Bundle加载状态已重置")
  }
}
