//
//  RNViewController.swift
//  MyTestApp
//
//  Created by Zeekg on 2025/8/31.
//
import UIKit
import React

/**
 * React Native页面控制器
 * 负责加载和显示React Native内容
 */
class RNViewController: UIViewController {
  
  // MARK: - 属性
  private var reactNativeView: RCTRootView?
  private var bridge: RCTBridge?
  
  // MARK: - 生命周期
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
    setupReactNative()
  }
  
  // MARK: - UI设置
  
  private func setupUI() {
    view.backgroundColor = .systemBackground
    
    // 添加关闭按钮
    let closeButton = UIButton(type: .system)
    closeButton.setTitle("❌ 关闭", for: .normal)
    closeButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
    closeButton.setTitleColor(.systemRed, for: .normal)
    closeButton.translatesAutoresizingMaskIntoConstraints = false
    closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
    
    view.addSubview(closeButton)
    
    // 设置关闭按钮约束
    NSLayoutConstraint.activate([
      closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
      closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
      closeButton.heightAnchor.constraint(equalToConstant: 44),
      closeButton.widthAnchor.constraint(equalToConstant: 80)
    ])
  }
  
  // MARK: - React Native设置
  
  private func setupReactNative() {
    print("🔧 开始设置React Native...")
    
    // 获取bundle URL
    let bundleURL = getBundleURL()
    
    // 创建RCTRootView
    let rnView = RCTRootView(
      bundleURL: bundleURL,
      moduleName: "MyTestApp",
      initialProperties: nil,
      launchOptions: nil
    )
    
    reactNativeView = rnView
    view.addSubview(rnView)
    
    // 设置React Native视图约束
    rnView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      rnView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60),
      rnView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      rnView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      rnView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])
    
    print("✅ React Native视图创建成功")
  }
  
  // MARK: - 获取Bundle URL
  
  private func getBundleURL() -> URL {
    #if DEBUG
      // 开发环境：从Metro服务器加载bundle
      let url = RCTBundleURLProvider.sharedSettings().jsBundleURL(forBundleRoot: "index")
      print(" Debug模式，使用Metro服务器URL: \(url?.absoluteString ?? "nil")")
      return url ?? Bundle.main.url(forResource: "main", withExtension: "jsbundle")!
    #else
      // 生产环境：从本地bundle文件加载
      let url = Bundle.main.url(forResource: "main", withExtension: "jsbundle")
      print("🔧 Release模式，使用本地bundle: \(url?.absoluteString ?? "nil")")
      return url!
    #endif
  }
  
  // MARK: - 按钮事件
  
  @objc private func closeButtonTapped() {
    print("❌ 用户点击了关闭按钮")
    
    // 清理React Native资源
    cleanupReactNative()
    
    dismiss(animated: true) {
      print("✅ React Native页面已关闭")
    }
  }
  
  // MARK: - 资源清理
  
  private func cleanupReactNative() {
    print(" 开始清理React Native资源...")
    
    // 停止bridge
    bridge?.invalidate()
    bridge = nil
    
    // 移除React Native视图
    reactNativeView?.removeFromSuperview()
    reactNativeView = nil
    
    print("✅ React Native资源清理完成")
  }
  
  // MARK: - 内存管理
  
  deinit {
    print(" RNViewController 被释放")
    cleanupReactNative()
  }
}