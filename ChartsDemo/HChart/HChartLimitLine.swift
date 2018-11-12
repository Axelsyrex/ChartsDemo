//
//  HChartLimitLine.swift
//  ChartsDemo
//
//  Created by Aleksander Angelov on 11/12/18.
//  Copyright © 2018 Aleksandar Angelov. All rights reserved.
//

import Foundation

class HChartLimitLine: ChartLimitLine {
    
    var isDataGap: Bool
    
    init(isDataGap: Bool) {
        self.isDataGap = isDataGap
        super.init()
    }
    
    convenience init(limit: Double, isDataGap: Bool) {
        self.init(isDataGap: isDataGap)
        self.limit = limit
    }
    
    convenience init(limit: Double, label: String, isDataGap: Bool) {
        self.init(limit: limit, isDataGap: isDataGap)
        self.label = label
    }
    
}
