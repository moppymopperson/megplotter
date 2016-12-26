//
//  WebsocketClient.swift
//  Grapher
//
//  Created by Erik Hornberger on 12/23/16.
//  Copyright © 2016 EExT. All rights reserved.
//

import Foundation
import UIKit

/** 
 Notifications sent by a `SocketClient`
 */
protocol SocketDelegate {
    func disconnected()
    func connected()
    func receivedNewData(newMeasurements:[CGFloat])
}

/** 
 There may be several kinds of clients (Websocket, TCP, UDP, etc.)
 Implementing a new client requires having these functions and members.
 */
protocol SocketClient {
    var delegate:SocketDelegate? { get set }
    var samplesReceived:Int { get }
    var averageFrequency:CGFloat { get }
    func connect()
}

