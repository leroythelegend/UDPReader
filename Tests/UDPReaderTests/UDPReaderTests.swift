import XCTest
import Network
@testable import UDPReader

func UDPClient(send string: String) {
    let connection = NWConnection(host: "127.0.0.1", port: 3443, using: .udp)

    connection.stateUpdateHandler = { (newState) in
        switch (newState) {
        case .ready:
            connection.send(content: string.data(using: String.Encoding.utf8), completion: .contentProcessed({error in
                if let error = error {
                    print("error while sending hello: \(error)")
                    return
                }
                
                print("may have sent hello")
                
                connection.cancel()
            }))
        case .setup: break
        case .cancelled: break
        case .preparing: break
        default: break
        }
    }

    connection.start(queue: .init(label: "client"))
}

final class UDPReaderTests: XCTestCase {
    func testExample() throws {
        let result = "Hello"
        
        // Start client and send result
        UDPClient(send: result)
        
        // Listen
        let reader = try! UDPReader(listen: "3443")
        
        // Check the result from the client is the same
        if let data = reader.read(amount: 6) {
            XCTAssertEqual(String(decoding: data, as: UTF8.self), result)
        }
        else {
            XCTAssert(false)
        }
    }
}
