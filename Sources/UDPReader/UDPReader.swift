
import Foundation

public class UDPReader {
    
    enum UDPReaderError: Error {
        case getAddrInfo(error: Int32)
        case bind(error: Int32)
        case socket(error: Int32)
        case unknown
    }
    
    ///
    /// UDPReader Init: Starts listening on port
    ///
    /// - parameters:
    ///   - port: The port number to listen to e.g. 5606 for pcars udp
    /// - throws: An error of type `UDPReaderError`
    ///
    
    init(listen port: String) throws {
        self.connectionHandle = INVALID_HANDLE
        
        var hints = createAddrInfoStruct()
        let info = try createListOfServerInfo(port: port, server: &hints)
        defer {
            freeaddrinfo(info)
        }
        try bindToServerInfo(server: info)
    }
    
    ///
    /// ReaderUDP deinit: close connection
    ///
    
    deinit {
        close(self.connectionHandle)
    }
    
    ///
    /// UDPReader read: Reads data from UDP
    ///
    /// - parameters:
    ///   - amount: amount of bytes to be read
    /// - returns:
    ///   - Data: read
    ///
    
    func read(amount : Int) -> (Data?) {
        let buffer : UnsafeMutableRawPointer = UnsafeMutableRawPointer.allocate(byteCount: amount, alignment: 1)
        defer {
            buffer.deallocate()
        }

        // now grab the packet
        let amountRead = recvfrom(self.connectionHandle, buffer,
                                  amount, 0,
                                  nil,
                                  nil)
        
        guard amountRead >= 0 else {
            return nil
        }
        
        return Data(bytesNoCopy: buffer, count: amountRead, deallocator: .none)
    }
    
    typealias ServerInfo = UnsafeMutablePointer<addrinfo>
    
    private var connectionHandle: Int32
    private let INVALID_HANDLE: Int32 = -1
    
    private func createAddrInfoStruct() -> addrinfo {
        return addrinfo(
            ai_flags: AI_PASSIVE,
            ai_family: AF_UNSPEC,
            ai_socktype: SOCK_DGRAM,
            ai_protocol: 0,
            ai_addrlen: 0,
            ai_canonname: nil,
            ai_addr: nil,
            ai_next: nil)
    }
    
    private func createListOfServerInfo(port: String, server hints: inout addrinfo) throws -> ServerInfo? {
        var serverInfo: ServerInfo? = nil
        
        let result = getaddrinfo(
                    nil,
                    port,
                    &hints,
                    &serverInfo)
        guard result == 0 else {
            throw UDPReaderError.getAddrInfo(error: result)
        }
        
        return serverInfo
    }
    
    private func bindToServerInfo(server info: ServerInfo?) throws {

        var result = info
        var functionNameThatReturnedError = ""
        var errorCode: Int32 = 0
        var status = INVALID_HANDLE
        
        // loop through servinfo list of remote address info
        while result != nil {
            
            // Create connection handle
            self.connectionHandle = socket(
                info!.pointee.ai_family,
                info!.pointee.ai_socktype,
                info!.pointee.ai_protocol)
            
            if self.connectionHandle != INVALID_HANDLE {
                // Bind socket to address
                status = bind(
                    self.connectionHandle,
                    info!.pointee.ai_addr,
                    info!.pointee.ai_addrlen)
                
                if status == 0 {
                    break
                }
                else {
                    errorCode = errno
                    functionNameThatReturnedError = "bind"
                    result = result!.pointee.ai_next
                }
            }
            else {
                functionNameThatReturnedError = "socket"
                errorCode = self.connectionHandle
                result = result!.pointee.ai_next
            }
        }
        
        guard status == 0 else {
            if functionNameThatReturnedError == "socket" {
                throw UDPReaderError.socket(error: errorCode)
            }
            else if functionNameThatReturnedError == "bind" {
                throw UDPReaderError.bind(error: errorCode)
            }
            else {
                throw UDPReaderError.unknown
            }
        }
    }
}
