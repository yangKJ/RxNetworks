//
//  LoadingHud.swift
//  RxNetworks
//
//  Created by Condy on 2023/4/12.
//

import Foundation
import Lottie

final class LoadingHud: ViewType {
    
    lazy var containerView: ViewType = {
        let view = ViewType()
        view.backgroundColor = .black.withAlphaComponent(0.7)
        #if os(macOS)
        view.wantsLayer = true
        view.layer?.cornerRadius = 15
        view.layer?.masksToBounds = true
        view.layer?.shouldRasterize = true
        view.layer?.rasterizationScale = X.mainScale()
        #else
        view.layer.cornerRadius = 15
        view.layer.masksToBounds = true
        view.layer.shouldRasterize = true
        view.layer.rasterizationScale = X.mainScale()
        #endif
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var animatedView: LottieAnimationView = {
        let view = LottieAnimationView()
        view.contentMode = .scaleAspectFit
        #if os(macOS)
        view.layer?.rasterizationScale = X.mainScale()
        #else
        view.layer.rasterizationScale = X.mainScale()
        #endif
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
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
        return label
    }()
    
    init(frame: CGRect, animatedNamed: String?, bundle: Bundle, subdirectory: String?) {
        super.init(frame: frame)
        self.setup()
        self.setup(animatedNamed: animatedNamed, bundle: bundle, subdirectory: subdirectory)
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
            containerView.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0),
            containerView.widthAnchor.constraint(equalToConstant: 100),
            containerView.heightAnchor.constraint(equalToConstant: 100),
            animatedView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            animatedView.leftAnchor.constraint(equalTo: containerView.leftAnchor),
            animatedView.rightAnchor.constraint(equalTo: containerView.rightAnchor),
            textLabel.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 10),
            textLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -10),
            textLabel.heightAnchor.constraint(equalToConstant: 15),
            textLabel.topAnchor.constraint(equalTo: animatedView.bottomAnchor, constant: 5),
            textLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -15),
        ])
    }
    
    private func setup(animatedNamed: String?, bundle: Bundle, subdirectory: String?) {
        if let animatedNamed = animatedNamed {
            animatedView.animation = LottieAnimation.named(animatedNamed, bundle: bundle, subdirectory: subdirectory)
        } else {
            NSLayoutConstraint.activate([
                textLabel.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 10),
                textLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -10),
                textLabel.heightAnchor.constraint(equalToConstant: 15),
                textLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            ])
        }
    }
    
    func setupLoadingText(_ text: String?) {
        textLabel.text = text
        if let text = text, !text.isEmpty { } else {
            NSLayoutConstraint.activate([
                animatedView.leftAnchor.constraint(equalTo: containerView.leftAnchor),
                animatedView.rightAnchor.constraint(equalTo: containerView.rightAnchor),
                animatedView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            ])
        }
    }
}

extension LoadingHud: LevelStatusBarWindowShowUpable {
    
    func makeOpenedStatusConstraint(superview: ViewType) {
        let origin = CGPoint(x: superview.center.x - 50, y: superview.center.y - 50)
        self.frame = CGRect(origin: origin, size: .init(width: 100, height: 100))
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
