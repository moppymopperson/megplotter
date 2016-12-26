//
//  TcpsocketClient.swift
//  Grapher
//
//  Created by Erik Hornberger on 12/26/16.
//  Copyright © 2016 EExT. All rights reserved.
//

import UIKit
import CocoaAsyncSocket

/** 
 Realizes `SocketClient` for the TCP Socket protocol
 */
class TcpClient: NSObject, SocketClient, GCDAsyncSocketDelegate {
    
    /// The underlying socket
    private var socket = GCDAsyncSocket()
    private(set) var hostIPAddress = "10.0.0.13"
    private(set) var port          = 8080
    
    /// Receives notifications and handles processing data
    var delegate:SocketDelegate?
    
    /// The total number of samples received so far
    private(set) var samplesReceived: Int = 0
    
    /// The time at which data started being received. Used to calculate `averageFrequency`.
    private(set) var startSimulationTime:Date?
    
    /// A background queue that deserialization is performed on
    private let backgroundQueue = DispatchQueue(label: "bgQueue")
    
    /// The average frequency that samples have been received at so far
    var averageFrequency: CGFloat {
        if startSimulationTime == nil {
            return -1
        }
        let elapsedSeconds = Date().timeIntervalSince(startSimulationTime!)
        return CGFloat(samplesReceived) / CGFloat(elapsedSeconds)
    }
    
    /// Connect the socket to the heroku web server
    func connect() {
        socket = GCDAsyncSocket(delegate: self, delegateQueue: backgroundQueue)
        try! socket.connect(toHost: hostIPAddress, onPort: UInt16(port), withTimeout: 2.0)
    }
    
    /// Called when the socket connnects to the TCP server
    /// Data is read until the \0 character following the JSON transmission
    func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        delegate?.connected()
        
        startSimulationTime = Date()
        sock.readData(to: GCDAsyncSocket.zeroData(), withTimeout: -1, tag: 0)
    }
    
    /// Called when the socket disconnects from the TCP server
    func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
        delegate?.disconnected()
    }
    
    
    /// Called when new data has been read in
    /// Further data is read until the \0 character following the JSON transmission
    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        sock.readData(to: GCDAsyncSocket.zeroData(), withTimeout: -1, tag: 0)
        
        // Remove the trailing stop byte from the data
        let jsonData   = data.subdata(in: 0..<data.count - 1)
        
        // Deserialize into JSON and extract the raw data
        do {
            let json = try JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) as! [String:Any]
            let raw  = json["data"] as! [CGFloat]
            
            samplesReceived += 1
            
            // GUI updates have to be performed on the main thread
            DispatchQueue.main.async {
                self.delegate?.receivedNewData(newMeasurements: raw)
            }
        } catch {
            print(error)
        }
    }
}
