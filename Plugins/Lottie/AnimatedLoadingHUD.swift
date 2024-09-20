//
//  AnimatedLoadingHUD.swift
//  RxNetworks
//
//  Created by Condy on 2023/4/12.
//

import Foundation
import Lottie
import Booming

final class AnimatedLoadingHUD: ViewType {
    
    lazy var containerView: ViewType = {
        let view = ViewType()
        #if os(macOS)
        view.wantsLayer = true
        view.layer?.cornerRadius = cornerRadius
        view.layer?.masksToBounds = true
        view.layer?.shouldRasterize = true
        view.layer?.rasterizationScale = X.mainScale()
        #else
        view.layer.cornerRadius = cornerRadius
        view.layer.masksToBounds = true
        view.layer.shouldRasterize = true
        view.layer.rasterizationScale = X.mainScale()
        #endif
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var animatedView: LottieAnimationView = {
        let animationView = LottieAnimationView()
        animationView.contentMode = .scaleAspectFit
        // Fixed the animation stops when it is covered.
        animationView.backgroundBehavior = .pauseAndRestore
        #if os(macOS)
        animationView.layer?.rasterizationScale = X.mainScale()
        #else
        animationView.layer.rasterizationScale = X.mainScale()
        #endif
        animationView.translatesAutoresizingMaskIntoConstraints = false
        if let animatedNamed = animatedNamed {
            animationView.animation = LottieAnimation.named(animatedNamed, bundle: bundle, subdirectory: subdirectory)
        }
        animationView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        animationView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return animationView
    }()
    
    lazy var textLabel: LabelType = {
        let label = LabelType()
        label.textColor = .white
        label.font = .systemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "loading.."
        #if os(macOS)
        label.layer?.rasterizationScale = X.mainScale()
        label.maximumNumberOfLines = 0
        #else
        label.textAlignment = .center
        label.numberOfLines = 0
        label.layer.rasterizationScale = X.mainScale()
        #endif
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        label.setContentHuggingPriority(.required, for: .horizontal)
        return label
    }()
    
    private let animatedNamed: String?
    private let bundle: Bundle
    private let subdirectory: String?
    
    init(animatedNamed: String?, bundle: Bundle, subdirectory: String?) {
        self.animatedNamed = animatedNamed
        self.bundle = bundle
        self.subdirectory = subdirectory
        super.init(frame: .zero)
        self.setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var containerSize: CGSize = .init(width: 100, height: 100)
    
    var cornerRadius: CGFloat = 15.0 {
        didSet {
            #if os(macOS)
            containerView.layer?.cornerRadius = cornerRadius
            #else
            containerView.layer.cornerRadius = cornerRadius
            #endif
        }
    }
    
    private func setup() {
        self.addSubview(containerView)
        if let animatedNamed = animatedNamed {
            containerView.addSubview(animatedView)
            NSLayoutConstraint.activate([
                containerView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
                containerView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
                containerView.widthAnchor.constraint(equalToConstant: containerSize.width),
                containerView.heightAnchor.constraint(equalToConstant: containerSize.height),
                animatedView.leftAnchor.constraint(equalTo: containerView.leftAnchor),
                animatedView.rightAnchor.constraint(equalTo: containerView.rightAnchor),
                animatedView.topAnchor.constraint(equalTo: containerView.topAnchor),
                animatedView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            ])
        } else {
            containerView.addSubview(textLabel)
            NSLayoutConstraint.activate([
                containerView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
                containerView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
                containerView.widthAnchor.constraint(equalToConstant: containerSize.width),
                containerView.heightAnchor.constraint(equalToConstant: containerSize.height),
                textLabel.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 8),
                textLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -8),
                textLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            ])
        }
    }
    
    func setupLoadingText(_ text: String?) {
        textLabel.text = text
        if let text = text, !text.isEmpty {
            if textLabel.superview == nil {
                containerView.addSubview(textLabel)
            }
            if animatedView.isHidden {
                NSLayoutConstraint.activate([
                    textLabel.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 8),
                    textLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -8),
                    textLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
                ])
            } else {
                NSLayoutConstraint.deactivate([
                    animatedView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
                ])
                NSLayoutConstraint.activate([
                    animatedView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -30),
                    textLabel.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 8),
                    textLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -8),
                    textLabel.topAnchor.constraint(equalTo: animatedView.bottomAnchor, constant: 5),
                ])
            }
        } else {
            NSLayoutConstraint.activate([
                animatedView.leftAnchor.constraint(equalTo: containerView.leftAnchor),
                animatedView.rightAnchor.constraint(equalTo: containerView.rightAnchor),
                animatedView.topAnchor.constraint(equalTo: containerView.topAnchor),
                animatedView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            ])
        }
    }
}

extension AnimatedLoadingHUD: LevelStatusBarWindowShowUpable {
    
    func makeOpenedStatusConstraint(superview: ViewType) {
        let origin = CGPoint(x: superview.center.x - containerSize.width/2, y: superview.center.y - containerSize.height/2)
        self.frame = CGRect(origin: origin, size: containerSize)
    }
    
    func show(animated: Bool, animation: (() -> Void)?, completion: ((Bool) -> Void)?) {
        self.animatedView.play(fromProgress: 0, toProgress: 1, loopMode: LottieLoopMode.loop)
        DispatchQueue.main.async {
            if animated {
                #if os(macOS)
                NSAnimationContext.runAnimationGroup({ context in
                    context.duration = 0.2
                    animation?()
                }, completionHandler: {
                    completion?(true)
                })
                #else
                UIView.animate(withDuration: 0.2, animations: {
                    animation?()
                }, completion: completion)
                #endif
            } else {
                animation?()
                completion?(true)
            }
        }
    }
    
    func close(animated: Bool, animation: (() -> Void)?, completion: ((Bool) -> Void)?) {
        self.animatedView.stop()
        DispatchQueue.main.async {
            if animated {
                #if os(macOS)
                NSAnimationContext.runAnimationGroup({ context in
                    context.duration = 0.2
                    animation?()
                }, completionHandler: {
                    completion?(true)
                })
                #else
                UIView.animate(withDuration: 0.2, animations: {
                    animation?()
                }, completion: completion)
                #endif
            } else {
                animation?()
                completion?(true)
            }
        }
    }
}
