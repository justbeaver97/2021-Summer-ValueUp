//
//  Initialized Settings -> flase
//
//  SessionSettings.swift
//  iOS Application
//
//  Created by 저스트비버 on 2021/07/07.
//

import SwiftUI

class SessionSettings: ObservableObject {
    @Published var isPeopleOcclusionEnabled: Bool = false
    @Published var isObjectOcclusionEnabled: Bool = false
    @Published var isLidarDebugEnabled: Bool = false
    @Published var isMultiuserEnabled: Bool = false
}
