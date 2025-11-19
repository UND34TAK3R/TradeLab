//
//  WebSocketsManager.swift
//  TradeLab
//
//  Created by Derrick Mangari on 2025-11-18.
//

import Foundation
import Combine

class WebSocketsManager: NSObject, URLSessionWebSocketDelegate, ObservableObject{
    
    @Published var trades: [Trade] = []
    
    //singleton pattern
    static let shared = WebSocketsManager()
    
    private let jsonParser = JsonParser()
    
    private var webSocketTask: URLSessionWebSocketTask?
    
    var onMessage: ((String?, Data?) -> Void)?
    
    override init(){
        super.init()
        
        //Setup Parser callback(connects the JsonParser and WebSocketsManager)
        jsonParser.onTradesParsed = { [weak self] trades in
            DispatchQueue.main.async {
                self?.trades.append(contentsOf: trades)
            }
        }
    }
    
    //Connection with url String
    func connect(urlString: String){
        guard let url = URL(string: urlString) else{return}
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue.main)
        webSocketTask = session.webSocketTask(with: url)
        webSocketTask?.resume()//Start connection process
    }
    
    //Disconnect from websocket
    func disconnect(){
        webSocketTask?.cancel(with: .goingAway, reason: nil)
    }
    
    //Recieve Message (FETCH DATA)
    func receiveMessage() {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .failure(let error):
                print("Error receiving message: \(error)")
            case .success(let message):
                switch message {
                case .string(let text):
                    self?.onMessage?(text, nil)
                case .data(let data):
                    self?.onMessage?(nil, data)
                @unknown default:
                    break
                }
            }
            //Call receive again to listen for the next message
            self?.receiveMessage()
        }
    }
    
    func send(text: String) {
        webSocketTask?.send(.string(text)) { error in
            if let error = error {
                print("Send error:", error)
            }
        }
    }
    
    // FUNCTIONS FOR URLSessionWebSocketDelegate METHODS
    
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print("WebSocket connected.")
        // Start recieveing messages immediately after connection is established
        receiveMessage()
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print("WebSocket connection closed. Code: \(closeCode)")
    }
    
    //FUNCTIONS TO RETRIEVE/DECODE DATA
    
    func startCollectingTrades(){
        self.onMessage = {[weak self] text, _ in
            guard let text = text else { return }
            
            //Finnhub JSON data
            print("Finnhub data:", text)
            
            //Parse data with Json Parser
            self?.jsonParser.parseTradeData(text)
        }
        let apiKey = Secrets.FHAPIKey
        self.connect(urlString: "wss://ws.finnhub.io?token=\(apiKey)")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            for symbol in StockSymbols.Top50{
                let subscribeMessage = "{\"type\":\"subscribe\",\"symbol\":\"\(symbol)\"}"
                self.send(text: subscribeMessage)
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
            self.send(text: "Hello!")
        }
    }
    
    //Test if recieve works
    func startFinnhubTest() {
        self.onMessage = { text, _ in
            print("Finnhub data:", text ?? "")
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
