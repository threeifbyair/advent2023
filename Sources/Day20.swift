import Foundation
import RegexBuilder

enum PulsarType: String {
    case broadcaster = "b"
    case flipflop = "%"
    case conjunction = "&"
    case output = "o"
}


class Pulsar {
    var pulsarType: PulsarType
    var name: Substring
    var parent: PulsarNetwork
    var destinations: [Substring] = []
    var inputs: [Substring: Bool] = [:]
    var state: Bool = false

    init(type: PulsarType, name: Substring, parent: PulsarNetwork) {
        self.pulsarType = type
        self.name = name
        self.parent = parent
    }

    func addDestination(destination: Substring) {
        destinations.append(destination)
    }

    func addSource(input: Substring) {
        inputs[input] = false
    }

    func pulse(source: Substring, highPulse: Bool, verbose: Bool = false) {
        switch pulsarType {
        case .broadcaster:
            for destination in destinations {
                parent.queuePulse(source: name, destination: destination, highPulse: highPulse, verbose: verbose)
            }
        case .flipflop:
            if highPulse {
                // Do nothing.
            }
            else {
                state = !state
                for destination in destinations {
                    parent.queuePulse(source: name, destination: destination, highPulse: state, verbose: verbose)
                }
            }
        case .conjunction:
            inputs[source] = highPulse            
            for destination in destinations {
                parent.queuePulse(source: name, destination: destination, highPulse: !inputs.values.reduce(true, { $0 && $1 }), verbose: verbose)
            }
        case .output:
            parent.registerOutputPulse(source: name, highPulse: highPulse, verbose: verbose)
            break
        }
    }
}

class PulsarNetwork {
    var pulsars: [Substring: Pulsar] = [:]
    var pulseQueue: [(Substring, Substring, Bool)] = []
    var pulseCount = [0, 0]
    var gotOutputPulse = false
    
    func addPulsar(name: Substring, type: PulsarType) {
        pulsars[name] = Pulsar(type: type, name: name, parent: self)
    }

    func addConnection(source: Substring, destination: Substring) {
        pulsars[source]!.addDestination(destination: destination)
        pulsars[destination]!.addSource(input: source)
    }

    func queuePulse(source: Substring, destination: Substring, highPulse: Bool, verbose: Bool = false) {
        if verbose {
            print("Queueing pulse from \(source) to \(destination) is \(highPulse ? "high" : "low")")
        }
        pulseQueue.append((source, destination, highPulse))
    }

    func registerOutputPulse(source: Substring, highPulse: Bool, verbose: Bool = false) {
        if verbose {
            print("Output pulse from \(source) is \(highPulse ? "high" : "low")")
        }
        if !highPulse {
            gotOutputPulse = true
        }
    }
    

    func pressButton(verbose: Bool) {
        pulseCount[0] += 1 // Low pulse
        if verbose {
            print("Pulse from button to roadcaster is low")
        }
        pulsars["roadcaster"]!.pulse(source: "button", highPulse: false, verbose: verbose)
        var time = 0
        while pulseQueue.count > 0 {
            let thesePulses = pulseQueue
            pulseQueue = []
            if verbose {
                print("\nTime \(time) has \(thesePulses.count) pulses")
            }
            for (source, destination, highPulse) in thesePulses {
                if verbose {
                    print("Pulse from \(source) to \(destination) is \(highPulse ? "high" : "low")")
                }
                pulseCount[highPulse ? 1 : 0] += 1
                pulsars[destination]!.pulse(source: source, highPulse: highPulse, verbose: verbose)
            }
            time += 1
        }
    }
}




class Day20: AdventDay {

    override func run() {
        var answer: Int = 0
        let network: PulsarNetwork = PulsarNetwork()
        var destinations: [Substring: [Substring]] = [:]

        for str in inputStrings {
            if str.length == 0 {
                continue
            }
            let pulsarStr = str.split(separator: " -> ")
            let pulsarName = pulsarStr[0]
            let pulsarType = PulsarType(rawValue: String(pulsarName.first!))!
            let pulsarIndex = pulsarName.index(pulsarName.startIndex, offsetBy: 1)
            let pulsarShortName = pulsarName[pulsarIndex ..< pulsarName.endIndex]
            network.addPulsar(name: pulsarShortName, type: pulsarType)
            let destinationList = pulsarStr[1].split(separator: ", ")
            destinations[pulsarShortName] = destinationList
        }

        // Now hook up all the pulsars.
        for (pulsarName, destinationList) in destinations {
            //print("\(pulsarName) -> \(destinationList)")
            for destination in destinationList {
                if network.pulsars[destination] == nil {
                    network.addPulsar(name: destination, type: .output)
                }
                network.addConnection(source: pulsarName, destination: destination)
            }
        }

        let buttonPresses = argint ?? (partTwo ? Int.max : 1000)

        for i in 0 ..< buttonPresses {
            network.pressButton(verbose: false)
            if partTwo && network.gotOutputPulse {
                print("Got low output pulse after \(i+1) button presses")
                answer = i+1
                break
            }
        }

        print("Low pulses: \(network.pulseCount[0]), high pulses: \(network.pulseCount[1])")

        if !partTwo {
             answer = network.pulseCount[1] * network.pulseCount[0]
        }
        
        print("Answer is \(answer)")
    }
}
