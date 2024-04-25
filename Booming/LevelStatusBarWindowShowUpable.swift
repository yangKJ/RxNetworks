//
//  LevelStatusBarWindowShowUpable.swift
//  Booming
//
//  Created by Condy on 2024/4/25.
//

import Foundation

public protocol LevelStatusBarWindowShowUpable {
    /// 打开状态
    /// - Parameter superview: 父视图
    func makeOpenedStatusConstraint(superview: ViewType)
    
    /// 根据添加设置内容，刷新界面
    func refreshBeforeShow()
    
    /// 显示
    /// - Parameters:
    ///   - animated: 是否动画效果
    ///   - animation: 动画内容
    ///   - completion: 完成回调
    func show(animated: Bool, animation: (() -> Void)?, completion: ((Bool) -> Void)?)
    
    /// 关闭
    /// - Parameters:
    ///   - animated: 是否动画效果
    ///   - animation: 动画内容
    ///   - completion: 完成回调
    func close(animated: Bool, animation: (() -> Void)?, completion: ((Bool) -> Void)?)
    
    /// 点击外面区域是否可关闭
    var canCloseWhenTapOutSize: Bool { get }
}

extension LevelStatusBarWindowShowUpable {
    
    public func makeOpenedStatusConstraint(superview: ViewType) {
        
    }
    
    public func refreshBeforeShow() {
        
    }
    
    public var canCloseWhenTapOutSize: Bool {
        false
    }
}
