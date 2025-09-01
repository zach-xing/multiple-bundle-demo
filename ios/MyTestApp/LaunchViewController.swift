//
//  LaunchViewController.swift
//  MyTestApp
//
//  Created by Zeekg on 2025/8/31.
//

import UIKit

/**
 * 启动画面控制器
 * 显示bundle加载进度和状态
 */
class LaunchViewController: UIViewController {
  
  // MARK: - UI组件
  private let loadingLabel = UILabel()
  private let progressView = UIProgressView()
  private let statusLabel = UILabel()
  private let activityIndicator = UIActivityIndicatorView(style: .large)
  
  // MARK: - 属性
  private var loadingProgress: Float = 0.0
  private var hasStartedLoading = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
    startBundleLoading()
  }
  
  // MARK: - UI设置
  
  private func setupUI() {
    view.backgroundColor = UIColor.systemBackground
    
    // 设置活动指示器
    activityIndicator.translatesAutoresizingMaskIntoConstraints = false
    activityIndicator.startAnimating()
    view.addSubview(activityIndicator)
    
    // 设置加载标签
    loadingLabel.translatesAutoresizingMaskIntoConstraints = false
    loadingLabel.text = "正在加载应用资源..."
    loadingLabel.textAlignment = .center
    loadingLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
    view.addSubview(loadingLabel)
    
    // 设置进度条
    progressView.translatesAutoresizingMaskIntoConstraints = false
    progressView.progressTintColor = UIColor.systemBlue
    progressView.trackTintColor = UIColor.systemGray5
    view.addSubview(progressView)
    
    // 设置状态标签
    statusLabel.translatesAutoresizingMaskIntoConstraints = false
    statusLabel.text = "准备中..."
    statusLabel.textAlignment = .center
    statusLabel.font = UIFont.systemFont(ofSize: 14)
    statusLabel.textColor = UIColor.systemGray
    view.addSubview(statusLabel)
    
    // 设置约束
    NSLayoutConstraint.activate([
      // 活动指示器居中
      activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -60),
      
      // 加载标签
      loadingLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      loadingLabel.topAnchor.constraint(equalTo: activityIndicator.bottomAnchor, constant: 20),
      loadingLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
      loadingLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
      
      // 进度条
      progressView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      progressView.topAnchor.constraint(equalTo: loadingLabel.bottomAnchor, constant: 20),
      progressView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
      progressView.heightAnchor.constraint(equalToConstant: 4),
      
      // 状态标签
      statusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      statusLabel.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 10),
      statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
      statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
    ])
  }
  
  // MARK: - Bundle加载
  
  private func startBundleLoading() {
    // 防止重复调用
    guard !hasStartedLoading else {
      print("Bundle加载已经开始，跳过重复调用")
      return
    }
    
    hasStartedLoading = true
    print("开始启动bundle加载流程...")
    
    // 创建加载进度
    simulateLoadingProgress()
    
    // 开始加载bundle
//    BundleLoader.shared.preloadAllBundles { [weak self] success in
//      DispatchQueue.main.async {
//        self?.handleBundleLoadingComplete(success: success)
//      }
//    }
  }
  
  private func simulateLoadingProgress() {
    // 模拟加载进度更新
    Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] timer in
      guard let self = self else {
        timer.invalidate()
        return
      }
      
      self.loadingProgress += 0.02
      if self.loadingProgress >= 1.0 {
        self.loadingProgress = 1.0
        timer.invalidate()
      }
      
      DispatchQueue.main.async {
        self.progressView.setProgress(self.loadingProgress, animated: true)
        
        // 更新状态文本
        if self.loadingProgress < 0.3 {
          self.statusLabel.text = "正在初始化基础组件..."
        } else if self.loadingProgress < 0.7 {
          self.statusLabel.text = "正在加载业务模块..."
        } else if self.loadingProgress < 1.0 {
          self.statusLabel.text = "正在完成初始化..."
        } else {
          self.statusLabel.text = "加载完成"
        }
      }
    }
  }
  
  private func handleBundleLoadingComplete(success: Bool) {
    if success {
      print("Bundle加载成功，准备启动主应用")
      statusLabel.text = "启动成功！"
      statusLabel.textColor = UIColor.systemGreen
      
      // 延迟一下让用户看到成功状态
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        self.dismiss(animated: true) {
          // 通知AppDelegate启动完成
          NotificationCenter.default.post(name: .bundleLoadingComplete, object: nil)
        }
      }
    } else {
      print("Bundle加载失败")
      statusLabel.text = "加载失败，请重试"
      statusLabel.textColor = UIColor.systemRed
      activityIndicator.stopAnimating()
      
      // 显示重试按钮
      showRetryButton()
    }
  }
  
  private func showRetryButton() {
    let retryButton = UIButton(type: .system)
    retryButton.setTitle("重试", for: .normal)
    retryButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
    retryButton.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
    retryButton.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(retryButton)
    
    NSLayoutConstraint.activate([
      retryButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      retryButton.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 20)
    ])
  }
  
  @objc private func retryButtonTapped() {
    // 重置状态
    hasStartedLoading = false
    loadingProgress = 0.0
    progressView.setProgress(0.0, animated: false)
    statusLabel.text = "准备中..."
    statusLabel.textColor = UIColor.systemGray
    activityIndicator.startAnimating()
    
    // 重新开始加载
    startBundleLoading()
  }
}
