//
//  WebSocketsManager.swift
//  TradeLab
//
//  Created by Derrick Mangari on 2025-11-18.
//

import Foundation
import Combine

class WebSocketsManager: NSObject, URLSessionWebSocketDelegate, ObservableObject {
    
    @Published var trades: [Trade] = []
    @Published var stockPrices: [String: StockPrice] = [:]
    
    static let shared = WebSocketsManager()
    
    private let jsonParser = JsonParser()
    private var webSocketTask: URLSessionWebSocketTask?
    private var session: URLSession?  // Keep session as property
    
    var onMessage: ((String?, Data?) -> Void)?
    
    override init() {
        super.init()
        
        // Setup URLSession once
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 30
        session = URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue.main)
        
        // Setup Parser callback
        jsonParser.onTradesParsed = { [weak self] trades in
            DispatchQueue.main.async {
                self?.trades.append(contentsOf: trades)
                for trade in trades {
                    if let exist = self?.stockPrices[trade.symbol] {
                        self?.stockPrices[trade.symbol] = StockPrice(
                            symbol: trade.symbol,
                            currentPrice: trade.currentPrice,
                            previousPrice: exist.currentPrice,
                            timestamp: Date()
                        )
                    } else {
                        self?.stockPrices[trade.symbol] = StockPrice(
                            symbol: trade.symbol,
                            currentPrice: trade.currentPrice,
                            previousPrice: nil,
                            timestamp: Date()
                        )
                    }
                }
            }
        }
    }
    
    func connect(urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        // Cancel existing connection if any
        disconnect()
        
        // Use the existing session
        webSocketTask = session?.webSocketTask(with: url)
        webSocketTask?.resume()
    }
    
    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
    }
    
    func receiveMessage() {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .failure(let error):
                print("Error receiving message: \(error)")
                // Don't call receiveMessage again on error
            case .success(let message):
                switch message {
                case .string(let text):
                    self?.onMessage?(text, nil)
                case .data(let data):
                    self?.onMessage?(nil, data)
                @unknown default:
                    break
                }
                // Only continue listening if successful
                self?.receiveMessage()
            }
        }
    }
    
    func send(text: String) {
        webSocketTask?.send(.string(text)) { error in
            if let error = error {
                print("Send error:", error)
            }
        }
    }
    
    // MARK: - URLSessionWebSocketDelegate
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print("WebSocket connected.")
        // Add a small delay to ensure connection is fully established
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.receiveMessage()
        }
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print("WebSocket connection closed. Code: \(closeCode)")
        if let reason = reason, let reasonString = String(data: reason, encoding: .utf8) {
            print("Reason: \(reasonString)")
        }
    }
    
    // MARK: - Data Collection
    
    func startCollectingTrades() {
        self.onMessage = { [weak self] text, _ in
            guard let text = text else { return }
            self?.jsonParser.parseTradeData(text)
        }
        
        let apiKey = Secrets.FHAPIKey
        self.connect(urlString: "wss://ws.finnhub.io?token=\(apiKey)")
        
        // Increased delay to ensure connection is established
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            for symbol in StockSymbols.Top50 {
                let subscribeMessage = "{\"type\":\"subscribe\",\"symbol\":\"\(symbol)\"}"
                self?.send(text: subscribeMessage)
            }
        }
    }
    
    //TEST FUNCTIONS
    
    //Test WebSocket works (send)
    func startTestConnection() {
        self.onMessage = { text, _ in
            print("Received:", text ?? "")
        }

        self.connect(urlString: "wss://echo.websocket.org")

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.send(text: "Hello!/Users/undertaker/Desktop/IOS_APPLICATIONS_1/TradeLab/TradeLab.xcodeproj")
        }
    }
    
    //Test if recieve works
    func startFinnhubTest() {
        self.onMessage = { text, _ in
            print("Finnhub data recieved")
        }
        
        // Take key from Secrets
        let apiKey = Secrets.FHAPIKey
        
        self.connect(urlString: "wss://ws.finnhub.io?token=\(apiKey)")
        
        // Subscribe to symbol
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            // Subscribe to any Trade
            let subscribeMessage = "{\"type\":\"subscribe\",\"symbol\":\"AAPL\"}"
            self.send(text: subscribeMessage)
            print("Subscribed to AAPL")
        }
    }
}



//To view the trades :
// webSocketManager.trades
//This will list every trades available(50 of them)
