//
//  LoadingHud.swift
//  RxNetworks
//
//  Created by Condy on 2023/4/12.
//

import Foundation
import Lottie

final class LoadingHud: UIView {
    
    lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
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
        view.layer.rasterizationScale = UIScreen.main.scale
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var textLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "loading.."
        label.numberOfLines = 0
        label.layer.rasterizationScale = UIScreen.main.scale
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
    
    func makeOpenedStatusConstraint(superview: UIView) {
        let size = CGSize(width: 100, height: 100)
        let origin = CGPoint(x: superview.center.x - 50, y: superview.center.y - 50)
        self.frame = CGRect(origin: origin, size: size)
    }
    
    func refreshBeforeShow() {
        
    }
    
    func show(animated: Bool, animation: (() -> Void)?, completion: ((Bool) -> Void)?) {
        self.animatedView.play(fromProgress: 0, toProgress: 1, loopMode: LottieLoopMode.loop)
        DispatchQueue.main.async {
            if animated {
                UIView.animate(withDuration: 0.2, animations: {
                    animation?()
                }, completion: completion)
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
                UIView.animate(withDuration: 0.2, animations: {
                    animation?()
                }, completion: completion)
            } else {
                animation?()
                completion?(true)
            }
        }
    }
}
