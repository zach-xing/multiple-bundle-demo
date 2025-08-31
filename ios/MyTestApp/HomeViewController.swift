//
//  HomeViewController.swift
//  MyTestApp
//
//  Created by Zeekg on 2025/8/31.
//

import UIKit

/**
 * 自定义原生页面控制器
 * 包含一个按钮，点击后加载React Native页面
 */
class HomeViewController: UIViewController {
  
  // MARK: - UI组件
  private lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.text = "欢迎使用多Bundle应用"
    label.font = UIFont.systemFont(ofSize: 28, weight: .bold)
    label.textAlignment = .center
    label.textColor = .label
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  
  private lazy var subtitleLabel: UILabel = {
    let label = UILabel()
    label.text = "这是一个完全用原生代码编写的启动页面"
    label.font = UIFont.systemFont(ofSize: 18)
    label.textAlignment = .center
    label.textColor = .secondaryLabel
    label.numberOfLines = 0
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  
  private lazy var descriptionLabel: UILabel = {
    let label = UILabel()
    label.text = "点击下方按钮可以加载React Native页面\n体验多Bundle架构的魅力"
    label.font = UIFont.systemFont(ofSize: 16)
    label.textAlignment = .center
    label.textColor = .tertiaryLabel
    label.numberOfLines = 0
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  
  private lazy var loadRNButton: UIButton = {
    let button = UIButton(type: .system)
    button.setTitle("加载React Native页面", for: .normal)
    button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
    button.backgroundColor = .systemBlue
    button.setTitleColor(.white, for: .normal)
    button.layer.cornerRadius = 16
    button.translatesAutoresizingMaskIntoConstraints = false
    button.addTarget(self, action: #selector(loadRNButtonTapped), for: .touchUpInside)
    
    // 添加阴影效果
    button.layer.shadowColor = UIColor.black.cgColor
    button.layer.shadowOffset = CGSize(width: 0, height: 4)
    button.layer.shadowRadius = 8
    button.layer.shadowOpacity = 0.3
    
    return button
  }()
  
  private lazy var infoButton: UIButton = {
    let button = UIButton(type: .system)
    button.setTitle("ℹ️ 应用信息", for: .normal)
    button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
    button.setTitleColor(.systemBlue, for: .normal)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.addTarget(self, action: #selector(infoButtonTapped), for: .touchUpInside)
    return button
  }()
  
  // MARK: - 生命周期
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
    setupConstraints()
    setupAnimations()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    animateElementsIn()
  }
  
  // MARK: - UI设置
  
  private func setupUI() {
    view.backgroundColor = .systemBackground
    
    // 添加渐变背景
    let gradientLayer = CAGradientLayer()
    gradientLayer.frame = view.bounds
    gradientLayer.colors = [
      UIColor.systemBackground.cgColor,
      UIColor.systemGray6.cgColor,
      UIColor.systemBackground.cgColor
    ]
    gradientLayer.locations = [0.0, 0.5, 1.0]
    view.layer.insertSublayer(gradientLayer, at: 0)
    
    // 添加子视图
    view.addSubview(titleLabel)
    view.addSubview(subtitleLabel)
    view.addSubview(descriptionLabel)
    view.addSubview(loadRNButton)
    view.addSubview(infoButton)
  }
  
  private func setupConstraints() {
    NSLayoutConstraint.activate([
      // 标题标签约束
      titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80),
      titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
      titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
      
      // 副标题标签约束
      subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
      subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
      subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
      
      // 描述标签约束
      descriptionLabel.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 40),
      descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
      descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
      
      // 加载RN按钮约束
      loadRNButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      loadRNButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 40),
      loadRNButton.heightAnchor.constraint(equalToConstant: 60),
      loadRNButton.widthAnchor.constraint(equalToConstant: 300),
      
      // 信息按钮约束
      infoButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
      infoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      infoButton.heightAnchor.constraint(equalToConstant: 44),
      infoButton.widthAnchor.constraint(equalToConstant: 120)
    ])
  }
  
  private func setupAnimations() {
    // 初始状态：所有元素都是透明的
    titleLabel.alpha = 0
    subtitleLabel.alpha = 0
    descriptionLabel.alpha = 0
    loadRNButton.alpha = 0
    infoButton.alpha = 0
    
    // 初始位置：稍微偏移
    titleLabel.transform = CGAffineTransform(translationX: 0, y: 30)
    subtitleLabel.transform = CGAffineTransform(translationX: 0, y: 30)
    descriptionLabel.transform = CGAffineTransform(translationX: 0, y: 30)
    loadRNButton.transform = CGAffineTransform(translationX: 0, y: 30)
    infoButton.transform = CGAffineTransform(translationX: 0, y: 30)
  }
  
  private func animateElementsIn() {
    // 标题动画
    UIView.animate(withDuration: 0.8, delay: 0.1, options: .curveEaseOut) {
      self.titleLabel.alpha = 1
      self.titleLabel.transform = .identity
    }
    
    // 副标题动画
    UIView.animate(withDuration: 0.8, delay: 0.2, options: .curveEaseOut) {
      self.subtitleLabel.alpha = 1
      self.subtitleLabel.transform = .identity
    }
    
    // 描述动画
    UIView.animate(withDuration: 0.8, delay: 0.3, options: .curveEaseOut) {
      self.descriptionLabel.alpha = 1
      self.descriptionLabel.transform = .identity
    }
    
    // 按钮动画
    UIView.animate(withDuration: 0.8, delay: 0.4, options: .curveEaseOut) {
      self.loadRNButton.alpha = 1
      self.loadRNButton.transform = .identity
    }
    
    // 信息按钮动画
    UIView.animate(withDuration: 0.8, delay: 0.5, options: .curveEaseOut) {
      self.infoButton.alpha = 1
      self.infoButton.transform = .identity
    }
  }
  
  // MARK: - 按钮事件
  
  @objc private func loadRNButtonTapped() {
    print("🚀 用户点击了加载RN页面按钮")
    
    // 按钮点击动画
    UIView.animate(withDuration: 0.1, animations: {
      self.loadRNButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
    }) { _ in
      UIView.animate(withDuration: 0.1) {
        self.loadRNButton.transform = .identity
      }
    }
    
    // 显示加载指示器
    showLoadingIndicator()
    
    // 延迟一下，模拟加载过程
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
      self.hideLoadingIndicator()
      self.navigateToRNPage()
    }
  }
  
  @objc private func infoButtonTapped() {
    print("ℹ️ 用户点击了信息按钮")
    
    let alert = UIAlertController(
      title: "应用信息",
      message: "这是一个支持多Bundle架构的React Native应用\n\n• 基础包：包含共享工具函数\n• 业务包：包含主要业务逻辑\n• 原生页面：完全用Swift编写",
      preferredStyle: .alert
    )
    
    alert.addAction(UIAlertAction(title: "了解", style: .default))
    present(alert, animated: true)
  }
  
  // MARK: - 导航到RN页面
  
  private func navigateToRNPage() {
    print("🎯 开始导航到React Native页面")
    
    // 创建RN页面控制器
    let rnViewController = RNViewController()
    
    // 使用模态展示
    rnViewController.modalPresentationStyle = .fullScreen
    rnViewController.modalTransitionStyle = .crossDissolve
    
    present(rnViewController, animated: true) {
      print("✅ React Native页面展示完成")
    }
  }
  
  // MARK: - 加载指示器
  
  private func showLoadingIndicator() {
    loadRNButton.setTitle("⏳ 正在加载...", for: .normal)
    loadRNButton.isEnabled = false
    loadRNButton.backgroundColor = .systemGray
  }
  
  private func hideLoadingIndicator() {
    loadRNButton.setTitle("加载React Native页面", for: .normal)
    loadRNButton.isEnabled = true
    loadRNButton.backgroundColor = .systemBlue
    
    // 停止旋转动画
    loadRNButton.layer.removeAnimation(forKey: "rotationAnimation")
  }
}
