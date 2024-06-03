//
//  HUDs.swift
//  Booming
//
//  Created by Condy on 2024/5/20.
//

import Foundation

/// 管理所有HUD
public struct HUDs {
    
    private static let HUDsLock = NSLock()
    static var cacheHUDs = [String: LevelStatusBarWindowController]()
    
    public static func readHUD(key: String) -> LevelStatusBarWindowController? {
        self.HUDsLock.lock()
        defer { HUDsLock.unlock() }
        return self.cacheHUDs[key]
    }
    
    public static func saveHUD(key: String, viewController: LevelStatusBarWindowController) {
        self.HUDsLock.lock()
        self.cacheHUDs[key] = viewController
        self.HUDsLock.unlock()
    }
    
    @discardableResult public static func removeHUD(key: String?) -> LevelStatusBarWindowController? {
        guard let key = key else {
            return nil
        }
        self.HUDsLock.lock()
        let hud = self.cacheHUDs[key]
        self.cacheHUDs.removeValue(forKey: key)
        self.HUDsLock.unlock()
        return hud
    }
    
    /// 移除窗口所有HUD
    public static func removeAll() {
        self.HUDsLock.lock()
        self.cacheHUDs.forEach {
            $0.value.close()
        }
        self.cacheHUDs.removeAll()
        self.HUDsLock.unlock()
    }
    
    /// 移除所有加载HUD
    public static func removeLoadingHUDs() {
        self.HUDsLock.lock()
        for (key, hud) in self.cacheHUDs where X.loadingSuffix(key: key) {
            self.cacheHUDs.removeValue(forKey: key)
            hud.close()
        }
        self.HUDsLock.unlock()
    }
    
    static func readHUD(prefix: String) -> [LevelStatusBarWindowController] {
        self.HUDsLock.lock()
        defer { self.HUDsLock.unlock() }
        return self.cacheHUDs.compactMap {
            if let prefix_ = $0.key.components(separatedBy: "_").first, prefix_ == prefix {
                return $0.value
            }
            return nil
        }
    }
    
    static func readHUD(suffix: String) -> [LevelStatusBarWindowController] {
        self.HUDsLock.lock()
        defer { self.HUDsLock.unlock() }
        return self.cacheHUDs.compactMap {
            if let suffix_ = $0.key.components(separatedBy: "_").last, suffix_ == suffix {
                return $0.value
            }
            return nil
        }
    }
    
    static func readTheKeyPrefixAllHUDs(key: String) -> [LevelStatusBarWindowController] {
        self.HUDsLock.lock()
        defer { self.HUDsLock.unlock() }
        let prefix = key.components(separatedBy: "_").first!
        return self.cacheHUDs.compactMap {
            if let prefix_ = $0.key.components(separatedBy: "_").first, prefix_ == prefix {
                return $0.value
            }
            return nil
        }
    }
    
    static func delayRemoveLoadingHUDs(with plugins: APIPlugins?) {
        guard let plugins = plugins else {
            return
        }
        let maxTime = X.maxDelayTime(with: plugins)
        if maxTime > 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + maxTime) {
                HUDs.removeLoadingHUDs()
            }
        } else {
            DispatchQueue.main.async {
                HUDs.removeLoadingHUDs()
            }
        }
    }
}

extension X {
    @available(*, deprecated, message: "Use HUDs.removeAll")
    public static func removeAllAtLevelStatusBarWindow() {
        HUDs.removeAll()
    }
    
    @available(*, deprecated, message: "Use HUDs.removeLoadingHUDs")
    public static func removeLoadingHUDs() {
        HUDs.removeLoadingHUDs()
    }
    
    @available(*, deprecated, message: "Use HUDs.readHUD:")
    public static func readHUD(key: String) -> LevelStatusBarWindowController? {
        HUDs.readHUD(key: key)
    }
    
    @available(*, deprecated, message: "Use HUDs.saveHUD:viewController:")
    public static func saveHUD(key: String, viewController: LevelStatusBarWindowController) {
        HUDs.saveHUD(key: key, viewController: viewController)
    }
    
    @available(*, deprecated, message: "Use HUDs.removeHUD:")
    @discardableResult public static func removeHUD(key: String?) -> LevelStatusBarWindowController? {
        HUDs.removeHUD(key: key)
    }
}
