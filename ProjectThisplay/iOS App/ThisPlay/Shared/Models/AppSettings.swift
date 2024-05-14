//
//  AppSettings.swift
//  ThisPlay
//
import Foundation
import SwiftData
import SwiftUI

@Model
class AppSettings {
    var lastTabIndex: Int
    var customAppIcon: String?
    @Relationship(deleteRule: .nullify) var currentServer: Server?
    @Relationship(deleteRule: .nullify) var defaultServer: Server?

    init(lastTabIndex: Int = 0, customAppIcon: String? = nil, mostRecentServer: Server? = nil, defaultServer: Server? = nil) {
        self.lastTabIndex = lastTabIndex
        self.customAppIcon = customAppIcon
        self.currentServer = mostRecentServer
        self.defaultServer = defaultServer
    }
}
