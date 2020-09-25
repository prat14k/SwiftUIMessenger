//
//  RoundCornerView.swift
//  SwiftUICombineDemo
//
//  Created by Prateek on 25/09/20.
//

import SwiftUI

struct RoundCornerView: Shape {

    let corners: UIRectCorner
    let radius: CGFloat = 24

    private var isTopLeftRound: Bool {
        corners.contains(.topLeft)
    }
    private var isBottomLeftRound: Bool {
        corners.contains(.bottomLeft)
    }
    private var isTopRightRound: Bool {
        corners.contains(.topRight)
    }
    private var isBottomRightRound: Bool {
        corners.contains(.bottomRight)
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()

        let width = rect.size.width
        let height = rect.size.height

        let topRightRadius = isTopRightRound ? radius : 0.0
        let topLeftRadius = isTopLeftRound ? radius : 0.0
        let bottomLeftRadius = isBottomLeftRound ? radius : 0.0
        let bottomRightRadius = isBottomRightRound ? radius : 0.0


        path.move(to: CGPoint(x: width / 2.0, y: 0))
        path.addLine(to: CGPoint(x: width - topRightRadius, y: 0))
        path.addArc(center: CGPoint(x: width - topRightRadius, y: topRightRadius),
                    radius: topRightRadius, startAngle: Angle(degrees: -90),
                    endAngle: Angle(degrees: 0), clockwise: false)

        path.addLine(to: CGPoint(x: width, y: height - bottomRightRadius))
        path.addArc(center: CGPoint(x: width - bottomRightRadius, y: height - bottomRightRadius),
                    radius: bottomRightRadius, startAngle: Angle(degrees: 0),
                    endAngle: Angle(degrees: 90), clockwise: false)

        path.addLine(to: CGPoint(x: bottomLeftRadius, y: height))
        path.addArc(center: CGPoint(x: bottomLeftRadius, y: height - bottomLeftRadius),
                    radius: bottomLeftRadius, startAngle: Angle(degrees: 90),
                    endAngle: Angle(degrees: 180), clockwise: false)

        path.addLine(to: CGPoint(x: 0, y: topLeftRadius))
        path.addArc(center: CGPoint(x: topLeftRadius, y: topLeftRadius),
                    radius: topLeftRadius, startAngle: Angle(degrees: 180),
                    endAngle: Angle(degrees: 270), clockwise: false)

        return path
    }
}
