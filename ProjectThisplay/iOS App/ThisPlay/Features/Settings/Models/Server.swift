//
//  Server.swift
//  ThisPlay
//
import SwiftUI
import SwiftData

@Model
class Server {
    var nickname: String
    var ipAddress: String
    var isDefault: Bool
    @Relationship(deleteRule: .cascade, inverse: \CanvasItem.server) var canvasHistoryItems: [CanvasItem]
    @Relationship(deleteRule: .cascade, inverse: \TextItem.server) var textHistoryItems: [TextItem]
    @Relationship(deleteRule: .cascade, inverse: \ImageItem.server) var imageHistoryItems: [ImageItem]

    init(nickname: String = "", ipAddress: String = "", isDefault: Bool = false) {
        self.nickname = nickname
        self.ipAddress = ipAddress
        self.isDefault = isDefault
        self.canvasHistoryItems = []
        self.textHistoryItems = []
        self.imageHistoryItems = []
    }
}
