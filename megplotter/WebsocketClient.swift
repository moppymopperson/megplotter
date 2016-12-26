//
//  WebsocketClient.swift
//  Grapher
//
//  Created by Erik Hornberger on 12/26/16.
//  Copyright © 2016 EExT. All rights reserved.
//

import Foundation
import UIKit
import SocketIO

/** 
 Realizes `SocketClient` for the Web Socket protocol
 */
class WebsocketClient: NSObject, SocketClient {
    
    /// The number of total samples received since transmission began
    private(set) var samplesReceived = 0
    
    /// The time at which data started being received. Used to calculate `averageFrequency`.
    private(set) var startSimulationTime = Date()
    
    /// A background queue that deserialization is performed on
    let processingQueue = DispatchQueue(label: "com.moppy.deserialize")
    
    /// Receives notifications and handles processing data
    var delegate:SocketDelegate?
    
    /// Compute and return the average frequency at which samples have been received so far.
    var averageFrequency: CGFloat {
        let elapsedSeconds = Date().timeIntervalSince(startSimulationTime)
        return CGFloat(samplesReceived) / CGFloat(elapsedSeconds)
    }
    
    /// The underlying web socket
    private let socket = SocketIOClient(socketURL: URL(string: "https://megsimulator.herokuapp.com/")!)
    
    /// Connect the socket to the server
    func connect() {
        
        
        socket.on("connect") { data, ack in
            self.delegate?.connected()
        }
        
        socket.on("disconnect") { data, ack in
            self.delegate?.disconnected()
        }
        
        socket.on("data") { data, ack in
            
            // Deserialize data on a background thread
            self.processingQueue.async {
                let jsonString = data[0] as! String
                let jsonData   = jsonString.data(using: .utf8)!
                self.deserialize(jsonData)
            }
        }
        
        socket.connect()
    }
    
    /// Change binary data into JSON, then get the raw measurements out of it
    private func deserialize(_ jsonData:Data) {
        do {
            
            let json = try JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) as! [String:Any]
            let measurements  = json["data"] as! [CGFloat]
            samplesReceived += 1
            
            // Perform updates on the main queue
            DispatchQueue.main.async {
                self.delegate?.receivedNewData(newMeasurements: measurements)
            }
            
        } catch {
            print(error)
        }
    }
}
