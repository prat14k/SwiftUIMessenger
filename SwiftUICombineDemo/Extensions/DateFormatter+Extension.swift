//
//  DateFormatter+Extension.swift
//  SwiftUICombineDemo
//
//  Created by Prateek on 24/09/20.
//

import Foundation

extension DateFormatter {
    static let formatter = DateFormatter(dateStyle: .short, timeStyle: .short)

    convenience init(dateStyle: DateFormatter.Style, timeStyle: DateFormatter.Style) {
        self.init()
        self.dateStyle = dateStyle
        self.timeStyle = timeStyle
    }
}
