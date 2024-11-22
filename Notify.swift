//
//  Notify.swift
//  Booming
//
//  Created by Condy on 2024/5/20.
//

import Foundation

public struct Notify {
    
    public struct LevelStatusBarWindow {
        /// If you need to restore a temporarily hidden level status window, please use this notification to hide.
        static let restoreDisplay = Notification.Name("Level.status.bar.window.restore.display")
        /// If you need to temporarily hide the level status display window, please use this notification to hide.
        static let temporarilyHide = Notification.Name("Level.status.bar.window.dismiss.temporarily")
    }
}
