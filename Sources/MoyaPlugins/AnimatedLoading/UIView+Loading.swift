//
//  UIView+Loading.swift
//  RxNetworks
//
//  Created by Condy on 2023/4/12.
//

import Foundation
import ObjectiveC
import Lottie

extension UIView {
    private struct AnimatedLoadingExtensionKey {
        static var loadingHud: Void?
        static var backViewTag: Void?
    }
    
    var animatedLoadingHud: LoadingHud? {
        set {
            objc_setAssociatedObject(self, &AnimatedLoadingExtensionKey.loadingHud, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(self, &AnimatedLoadingExtensionKey.loadingHud) as? LoadingHud
        }
    }
    
    var hudBackView: UIView? {
        set {
            objc_setAssociatedObject(self, &AnimatedLoadingExtensionKey.backViewTag, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(self, &AnimatedLoadingExtensionKey.backViewTag) as? UIView
        }
    }
    
    func showLoadingHUD(_ animatedNamed: String?) {
        if self.animatedLoadingHud != nil {
            return
        }
        self.hideHUD()
        self.animatedLoadingHud = LoadingHud(frame: .zero, animatedNamed: animatedNamed)
        self.animatedLoadingHud?.show(in: self)
    }
    
    func hideHUD() {
        self.animatedLoadingHud?.hide()
        self.animatedLoadingHud = nil
    }
    
    func showHudBackView() {
        if self.hudBackView != nil {
            return
        }
        self.hideBackView()
        let backView = UIView.init(frame: self.bounds)
        backView.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        self.addSubview(backView)
        self.hudBackView = backView
    }
    
    func hideBackView() {
        self.hudBackView?.removeFromSuperview()
        self.hudBackView = nil
    }
}

// MARK: - LoadingHud view

final class LoadingHud: UIView {
    
    lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        view.layer.cornerRadius = 15
        view.layer.masksToBounds = true
        view.layer.shouldRasterize = true
        view.layer.rasterizationScale = UIScreen.main.scale
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var animatedView: LottieAnimationView = {
        let view = LottieAnimationView()
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var textLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.black.withAlphaComponent(0.65)
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "loading.."
        label.numberOfLines = 0
        return label
    }()
    
    init(frame: CGRect, animatedNamed: String?) {
        super.init(frame: frame)
        self.setup()
        self.setup(animatedNamed: animatedNamed)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        self.addSubview(containerView)
        containerView.addSubview(animatedView)
        containerView.addSubview(textLabel)
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            containerView.widthAnchor.constraint(equalToConstant: 100),
            containerView.heightAnchor.constraint(equalToConstant: 100),
            animatedView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            animatedView.leftAnchor.constraint(equalTo: containerView.leftAnchor),
            animatedView.rightAnchor.constraint(equalTo: containerView.rightAnchor),
            textLabel.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 10),
            textLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -10),
            textLabel.heightAnchor.constraint(equalToConstant: 15),
            textLabel.topAnchor.constraint(equalTo: animatedView.bottomAnchor, constant: 5),
            textLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10),
        ])
    }
    
    private func setup(animatedNamed: String?) {
        if let animatedNamed = animatedNamed {
            animatedView.animation = LottieAnimation.named(animatedNamed)
        } else {
            NSLayoutConstraint.activate([
                textLabel.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 10),
                textLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -10),
                textLabel.heightAnchor.constraint(equalToConstant: 15),
                textLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            ])
        }
    }
    
    func show(in view: UIView) {
        view.addSubview(self)
        view.bringSubviewToFront(self)
        animatedView.play(fromProgress: 0, toProgress: 1, loopMode: LottieLoopMode.loop)
    }
    
    func hide() {
        animatedView.stop()
        removeFromSuperview()
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if superview != nil {
            let size = CGSize(width: 100, height: 100)
            let origin = CGPoint(x: superview!.center.x - 50, y: superview!.center.y - 50)
            self.frame = CGRect(origin: origin, size: size)
        }
    }
}
