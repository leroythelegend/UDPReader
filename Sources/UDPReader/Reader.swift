//
//  File.swift
//  
//
//  Created by Leigh McLean on 6/12/21.
//

import Foundation

///
/// Reader Protocol so that you can use different types of readers.
///
/// I'm hoping to use the protocol to create a TestUDPReader that reads
/// from a file rather than a network and pass my TestUDPReader to my
/// application instead of the real UDPReader.
///

protocol Reader {
    func read(amount : Int) -> (Data?)
}

