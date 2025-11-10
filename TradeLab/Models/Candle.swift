//
//  Candle.swift
//  TradeLab
//
//  Created by Derrick Mangari on 2025-11-08.
//


// Candles are used for charts

import Foundation

struct Candle {
    let open: Double
    var high: Double
    var low: Double
    var close: Double
    var volume: Int
    let startTime: Date
}





//methods

class CandleAggregator{
    private var currentCandle: Candle?
    private var candles: [Candle] = []
    private let interval: TimeInterval
    
    init(interval: TimeInterval = 60){
        self.interval = interval
    }
    
    func addTrade(_ trade: Trade){
        let tradeTime = Date(timeIntervalSince1970: trade.timestamp / 1000)
        if currentCandle == nil {
            currentCandle = Candle(open: trade.currentPrice, high: trade.currentPrice, low: trade.currentPrice, close: trade.currentPrice, volume: trade.Volume, startTime: tradeTime)
            return
        }
        guard var candle = currentCandle else { return }
        
        //Check if trade is within current candle's interval
        if tradeTime.timeIntervalSince(candle.startTime) < interval {
            candle.high = max(candle.high, trade.currentPrice)
            candle.low = min(candle.low, trade.currentPrice)
            candle.close = trade.currentPrice
            candle.volume += trade.Volume
            currentCandle = candle
        } else {
            //Candle finished, start a new one
            candles.append(candle)
            currentCandle = Candle(open: trade.currentPrice, high: trade.currentPrice, low: trade.currentPrice, close: trade.currentPrice, volume: trade.Volume, startTime: tradeTime)
        }
    }
    
    func getCandles() -> [Candle] {
        return candles
    }
    
    func percentChange(open: Double, current: Double) -> Double {
        return ((current - open) / open) * 100
    }
}
