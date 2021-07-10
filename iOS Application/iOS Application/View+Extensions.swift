//
//  View+Extensions.swift
//  iOS Application
//
//  Created by 저스트비버 on 2021/07/07.
//

import SwiftUI

extension View {
    @ViewBuilder func hidden(_ shouldHide: Bool) -> some View {
        switch shouldHide {
        case true: self.hidden()
        case false: self
        }
    }
}
