//
//  JsonParser.swift
//  TradeLab
//
//  Created by Derrick Mangari on 2025-11-19.
//

import Foundation

class JsonParser{
    
    var onTradesParsed: (([Trade]) -> Void)?
    
    func parseTradeData(_ jsonString: String){
        
        //Check if string is empty
        guard !jsonString.isEmpty else {
            print("Empty JSON string")
            return
        }
        //Check if the format is in UTF8
        guard let data = jsonString.data(using: .utf8) else {
            print("Failed to convert string to data")
            return
        }
        
        do{
            let response = try JSONDecoder().decode(TradeResponse.self, from: data)
            switch response.type{
            case "trade":
                if let newTrades = response.data, !newTrades.isEmpty{
                    onTradesParsed?(newTrades)
                }else{
                    print("Trade message with no data")
                }
            case "ping":
                print("Ping")
            default:
                print("Unknown message type")
            }
        }catch let DecodingError.keyNotFound(key, context){
            print("Key '\(key)' not found:", context)
            
        }catch let DecodingError.typeMismatch(type, context){
            print("Type '\(type)' mismatch:", context)
            
        }catch let DecodingError.valueNotFound(value, context){
            print("Value '\(value)' not found:", context)
            
        }catch{
            print("Parse error:", error.localizedDescription)
        }
    }
}
