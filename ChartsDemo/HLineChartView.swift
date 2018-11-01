//
//  HLineChartView.swift
//  ChartsDemo
//
//  Created by Aleksandar Angelov on 10/27/18.
//  Copyright © 2018 Aleksandar Angelov. All rights reserved.
//

import Foundation

class HLineChartView: LineChartView {
    
    public override init(frame: CGRect)
    {
        super.init(frame: frame)
        self.xAxisRenderer = HXAxisRenderer(viewPortHandler: viewPortHandler, xAxis: xAxis, transformer: getTransformer(forAxis: .left))
    }
    
    public required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        self.xAxisRenderer = HXAxisRenderer(viewPortHandler: viewPortHandler, xAxis: xAxis, transformer: getTransformer(forAxis: .left))
    }
   
    
}
