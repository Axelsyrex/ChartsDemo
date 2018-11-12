//
//  HXAxisRenderer.swift
//  ChartsDemo
//
//  Created by Aleksandar Angelov on 10/27/18.
//  Copyright © 2018 Aleksandar Angelov. All rights reserved.
//

import Foundation
import CoreGraphics
import UIKit

class HXAxisRenderer: XAxisRenderer {
    
    
    override func drawLabels(context: CGContext, pos: CGFloat, anchor: CGPoint) {
        guard
            let xAxis = self.axis as? XAxis,
            let transformer = self.transformer
            else { return }
        
        #if os(OSX)
        let paraStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        #else
        let paraStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        #endif
        paraStyle.alignment = .center
        
        let labelAttrs: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font: xAxis.labelFont,
                                                          NSAttributedString.Key.foregroundColor: xAxis.labelTextColor,
                                                          NSAttributedString.Key.paragraphStyle: paraStyle]
        let labelRotationAngleRadians = xAxis.labelRotationAngle.DEG2RAD
        
        let centeringEnabled = xAxis.isCenterAxisLabelsEnabled
        
        let valueToPixelMatrix = transformer.valueToPixelMatrix
        
        var position = CGPoint(x: 0.0, y: 0.0)
        
        var labelMaxSize = CGSize()
        
        if xAxis.isWordWrapEnabled
        {
            labelMaxSize.width = xAxis.wordWrapWidthPercent * valueToPixelMatrix.a
        }
        
        let entries = xAxis.entries
        
        for i in stride(from: 0, to: entries.count, by: 1)
        {
            if centeringEnabled
            {
                position.x = CGFloat(xAxis.centeredEntries[i])
            }
            else
            {
                position.x = CGFloat(entries[i])
            }
            
            position.y = 0.0
            position = position.applying(valueToPixelMatrix)
            
            if viewPortHandler.isInBoundsX(position.x)
            {
                let label = xAxis.valueFormatter?.stringForValue(xAxis.entries[i], axis: xAxis) ?? ""
                
                let labelns = label as NSString
                
                if xAxis.isAvoidFirstLastClippingEnabled
                {
                    // avoid clipping of the last
                    if i == xAxis.entryCount - 1 && xAxis.entryCount > 1
                    {
                        let width = labelns.boundingRect(with: labelMaxSize, options: .usesLineFragmentOrigin, attributes: labelAttrs, context: nil).size.width
                        
                        if width > viewPortHandler.offsetRight * 2.0
                            && position.x + width > viewPortHandler.chartWidth
                        {
                            position.x -= width / 2.0
                        }
                    }
                    else if i == 0
                    { // avoid clipping of the first
                        let width = labelns.boundingRect(with: labelMaxSize, options: .usesLineFragmentOrigin, attributes: labelAttrs, context: nil).size.width
                        position.x += width / 2.0
                    }
                }
                
                drawLabel(context: context,
                          formattedLabel: label,
                          x: position.x,
                          y: pos,
                          attributes: labelAttrs,
                          constrainedToSize: labelMaxSize,
                          anchor: anchor,
                          angleRadians: labelRotationAngleRadians)
            }
        }
    }
    
    override func renderAxisLabels(context: CGContext) {
        guard let xAxis = self.axis as? XAxis else { return }
        
        if !xAxis.isEnabled || !xAxis.isDrawLabelsEnabled
        {
            return
        }
        
        let yOffset = xAxis.yOffset
        
        if xAxis.labelPosition == .top
        {
            drawLabels(context: context, pos: viewPortHandler.contentTop - yOffset, anchor: CGPoint(x: 0.5, y: 1.0))
        }
        else if xAxis.labelPosition == .topInside
        {
            drawLabels(context: context, pos: viewPortHandler.contentTop + yOffset + xAxis.labelRotatedHeight, anchor: CGPoint(x: 0.5, y: 1.0))
        }
        else if xAxis.labelPosition == .bottom
        {
            drawLabels(context: context, pos: viewPortHandler.contentBottom + yOffset, anchor: CGPoint(x: 0.5, y: 0.0))
        }
        else if xAxis.labelPosition == .bottomInside
        {
            drawLabels(context: context, pos: viewPortHandler.contentBottom - yOffset - xAxis.labelRotatedHeight, anchor: CGPoint(x: 0.5, y: 0.0))
        }
        else
        { // BOTH SIDED
            drawLabels(context: context, pos: viewPortHandler.contentTop - yOffset, anchor: CGPoint(x: 0.5, y: 1.0))
            drawLabels(context: context, pos: viewPortHandler.contentBottom + yOffset, anchor: CGPoint(x: 0.5, y: 0.0))
        }
    }
    
    override func renderLimitLines(context: CGContext) {
        guard
            let xAxis = self.axis as? XAxis,
            let transformer = self.transformer
            else { return }
        
        var limitLines = xAxis.limitLines
        
        if limitLines.count == 0
        {
            return
        }
        
        let trans = transformer.valueToPixelMatrix
        
        var position = CGPoint(x: 0.0, y: 0.0)
        
        for i in 0 ..< limitLines.count
        {
            if limitLines[i] is HChartLimitLine == false {
                continue
            }
            let l = limitLines[i] as! HChartLimitLine
            
            if !l.isEnabled
            {
                continue
            }
            
            context.saveGState()
            defer { context.restoreGState() }
            
            var clippingRect = viewPortHandler.contentRect
            clippingRect.origin.x -= l.lineWidth / 2.0
            clippingRect.size.width += l.lineWidth
            context.clip(to: clippingRect)
            
            position.x = CGFloat(l.limit)
            position.y = 0.0
            position = position.applying(trans)
            let maxPosition = CGPoint(x: CGFloat(l.limit+Double(ChartConstants.dayDuration)), y: 0).applying(trans)
            renderLimitLineLine(context: context, limitLine: l, position: position)
            switch l.type {
            case .gap:
                break
            case .gradient:
                renderLimitLineGradient(context: context, limitLine: l, position: position)
                renderLimitLineLabel(context: context, limitLine: l, position: position, yOffset: 2.0 + l.yOffset, maxPosition: maxPosition)
            }
        }
    }
    
    func renderLimitLineLabel(context: CGContext, limitLine: ChartLimitLine, position: CGPoint, yOffset: CGFloat, maxPosition: CGPoint) {
        // if drawing the limit-value label is enabled
        let label = limitLine.label
        guard limitLine.drawLabelEnabled && label.count > 0 else {
            return
        }
        
        let labelLineHeight = limitLine.valueFont.lineHeight
        let labelWidth = label.size(withAttributes: [NSAttributedString.Key.font: limitLine.valueFont]).width
        
        let availableSpace = ((maxPosition.x-labelWidth) - position.x) - 20
        if (availableSpace < labelWidth){
            //TODO smaller?
        }
        let centerViewPosition = viewPortHandler.offsetLeft + 0.5*viewPortHandler.chartWidth - 0.5*labelWidth//constant value
        let xOffset: CGFloat = limitLine.lineWidth + limitLine.xOffset
        var centerRelativeToAvailableSpace = (centerViewPosition - (position.x + 10)) / availableSpace //translate and normalize
        //move point to edge if outside
        if(centerRelativeToAvailableSpace < 0){
            centerRelativeToAvailableSpace = 0
        }
        if (centerRelativeToAvailableSpace > 1 ){
            centerRelativeToAvailableSpace = 1
        }
        //use 1/6 to speed up/down
        centerRelativeToAvailableSpace *= 10.0
        if (centerRelativeToAvailableSpace < 1){
            centerRelativeToAvailableSpace = CGFloat(QuadraticEaseIn(Float(centerRelativeToAvailableSpace)))
        }
        if (centerRelativeToAvailableSpace > 9){
            centerRelativeToAvailableSpace = CGFloat(QuadraticEaseOut(Float((centerRelativeToAvailableSpace-9.0))))+9.0
        }
        centerRelativeToAvailableSpace /= 10.0
        var adjustedPosition = position
        adjustedPosition.x = adjustedPosition.x - xOffset + centerRelativeToAvailableSpace * availableSpace + 5
        
        if limitLine.labelPosition == .rightTop
        {
            ChartUtils.drawText(context: context,
                                text: label,
                                point: CGPoint(
                                    x: adjustedPosition.x + xOffset,
                                    y: viewPortHandler.contentTop + yOffset),
                                align: .left,
                                attributes: [NSAttributedString.Key.font: limitLine.valueFont, NSAttributedString.Key.foregroundColor: limitLine.valueTextColor])
        }
        else if limitLine.labelPosition == .rightBottom
        {
            ChartUtils.drawText(context: context,
                                text: label,
                                point: CGPoint(
                                    x: adjustedPosition.x + xOffset,
                                    y: viewPortHandler.contentBottom - labelLineHeight - yOffset),
                                align: .left,
                                attributes: [NSAttributedString.Key.font: limitLine.valueFont, NSAttributedString.Key.foregroundColor: limitLine.valueTextColor])
        }
        else if limitLine.labelPosition == .leftTop
        {
            ChartUtils.drawText(context: context,
                                text: label,
                                point: CGPoint(
                                    x: adjustedPosition.x - xOffset,
                                    y: viewPortHandler.contentTop + yOffset),
                                align: .right,
                                attributes: [NSAttributedString.Key.font: limitLine.valueFont, NSAttributedString.Key.foregroundColor: limitLine.valueTextColor])
        }
        else
        {
            ChartUtils.drawText(context: context,
                                text: label,
                                point: CGPoint(
                                    x: adjustedPosition.x - xOffset,
                                    y: viewPortHandler.contentBottom - labelLineHeight - yOffset),
                                align: .right,
                                attributes: [NSAttributedString.Key.font: limitLine.valueFont, NSAttributedString.Key.foregroundColor: limitLine.valueTextColor])
        }
    }
    
    func renderLimitLineGradient(context: CGContext, limitLine: ChartLimitLine, position: CGPoint)
    {
        
        let locations: [CGFloat] = [ 0.0, 1.0 ]
        let colors = [limitLine.lineColor.withAlphaComponent(0.5).cgColor,
                      limitLine.lineColor.withAlphaComponent(0.01).cgColor]
        
        let colorspace = CGColorSpaceCreateDeviceRGB()
        
        let gradient = CGGradient(colorsSpace: colorspace,
                                  colors: colors as CFArray, locations: locations)
        var startPoint = CGPoint()
        var endPoint =  CGPoint()
        
        startPoint.x = position.x
        startPoint.y = viewPortHandler.contentTop
        endPoint.x = position.x+viewPortHandler.contentWidth/2.0;
        endPoint.y = viewPortHandler.contentTop
        context.saveGState()
        context.addRect(CGRect(x: position.x, y: viewPortHandler.contentTop, width: viewPortHandler.contentWidth/2.0, height: viewPortHandler.contentHeight))
        context.clip()
        context.drawLinearGradient(gradient!, start: startPoint, end: endPoint,options: [])
        context.restoreGState()
    }
    
    fileprivate func  QuadraticEaseIn(_ p:Float)->Float
    {
        return p * p;
    }
    
    fileprivate func QuadraticEaseOut(_ p:Float)->Float
    {
        return -(p * (p - 2));
    }
    
}
