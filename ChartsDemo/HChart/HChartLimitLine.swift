//
//  HChartLimitLine.swift
//  ChartsDemo
//
//  Created by Aleksander Angelov on 11/12/18.
//  Copyright © 2018 Aleksandar Angelov. All rights reserved.
//

import Foundation

class HChartLimitLine: ChartLimitLine {
    
    let type: LimitType
    
    init(type: LimitType) {
        self.type = type
        super.init()
        switch type {
        case .gap(let limit):
            self.limit = limit
        case .gradient(let limit, let label):
            self.limit = limit
            self.label = label
        }
    }
    
    enum LimitType {
        case gap(limit: Double)
        case gradient(limit: Double, label: String)
    }
    
}
