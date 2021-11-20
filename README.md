# UDPReader

UDPReader is a simple package for reading udp packets

For Example

```
        do {
            // Listen
            let reader = try UDPReader(listen: "8081")
            
            while true {
                // Check the result from the client is not nil
                if let data = reader.read(amount: 1024) {
                    print(String(decoding: data, as: UTF8.self), result)
                }
                else {
                    print("Did not read any packets")
                    break
                }
            }

        } catch UDPReaderError.bind(let error) {
            print("Could not bind \(error)")
        } catch UDPReaderError.getAddrInfo(let error) {
            print("Could not get address info \(error)")
        } catch UDPReaderError.socket(let error) {
            print("Could not get socket \(error)")
        } catch UDPReaderError.unknown {
            print("Unkuown socket error")
        } catch {
            print("Unknown error")
        }
```

Supports MacOS 12 Swift 5.5



