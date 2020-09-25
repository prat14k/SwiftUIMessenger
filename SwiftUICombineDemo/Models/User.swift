//
//  User.swift
//  SwiftUICombineDemo
//
//  Created by Prateek on 24/09/20.
//

import UIKit

class User {
    static let current = User()

    let id = UUID()
    var name: String { UIDevice.current.name }

    private init() { }
}
