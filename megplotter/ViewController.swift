//
//  ViewController.swift
//  megplotter
//
//  Created by Erik Hornberger on 12/26/16.
//  Copyright © 2016 EExT. All rights reserved.
//

import UIKit

/**
 The App's GUI
 */
class ViewController: UIViewController, SocketDelegate {
    
    /// A view showing a plot of all the lines
    var graph:Graph?
    
    /// A referenece to all the lines shown in the graph
    var lines = [Line]()
    
    /// A label that displays the average frequency at which samples are received
    let frequencyLabel = UILabel()
    
    /// A label showing how many samples have been received so far
    let sampleLabel = UILabel()
    
    /// A reference to the socket used for communication
    var socket:SocketClient!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the socket. Could be `WebsocketClient` or `TcpSocket`
        socket = WebsocketClient()
        socket.delegate = self
        
        // Frequency label
        frequencyLabel.frame = CGRect(x: 8, y: view.frame.height - 28, width: 200, height: 20)
        frequencyLabel.textColor = .white
        frequencyLabel.text = "frequency: "
        view.addSubview(frequencyLabel)
        
        // Sample label
        sampleLabel.frame = CGRect(x: 8, y: view.frame.height - 48, width: 200, height: 20)
        sampleLabel.textColor = .white
        sampleLabel.text = "samples: 0"
        view.addSubview(sampleLabel)
    }
    
    /// Connect the socket and beginning receiving data just after the view shows
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        socket.connect()
    }
    
    
    /// This is called everytime the socket received new data
    func receivedNewData(newMeasurements: [CGFloat]) {
        
        // Route new data
        if self.graph == nil {
            self.setupGraph(with: newMeasurements)
        } else {
            self.handleNewData(measurements: newMeasurements)
        }
        
        // Update labels
        frequencyLabel.text = String(format: "frequency: %.5f", socket.averageFrequency)
        sampleLabel.text    = "samples: \(socket.samplesReceived)"
        self.graph?.setNeedsDisplay()
    }
    
    /// Called the very first time data is received to initialize the `Graph`.
    private func setupGraph(with measurements:[CGFloat]) {
        
        // create lines, each with it's own random color
        for k in 0..<measurements.count {
            let line = Line(values: Array.init(repeating: 0, count: Line.maxLength))
            line.add(newPoint: measurements[k])
            line.color = self.randomColor()
            self.lines.append(line)
        }
        
        // create graph
        self.graph = SpreadGraph(frame: self.view.frame, lines: self.lines)
        self.view.insertSubview(self.graph!, at: 0)
    }
    
    /// Called every time (except the very first time) that data is received to update the graph
    private func handleNewData(measurements:[CGFloat]) {
        for (index, value) in measurements.enumerated() {
            self.lines[index].add(newPoint: value)
        }
    }
    
    /// Called when the socket connects to the server
    func connected() {
        print("Connected!")
    }
    
    /// Called when the socket disconnects to the server
    func disconnected() {
        print("Disconnected")
    }
    
    
    // MARK: Helper functions
    
    /// Produce a random color (fully opaque)
    private func randomColor() -> UIColor {
        return UIColor(colorLiteralRed: rand01(), green: rand01(), blue: rand01(), alpha: 1)
    }
    
    /// Produce a random number between 0 and 1
    private func rand01() -> Float {
        return Float(arc4random_uniform(255))/255
    }
}


