import Foundation
import RegexBuilder
import HeapModule

enum PulsarType: String, Hashable {
    case broadcaster = "b"
    case flipflop = "%"
    case conjunction = "&"
    case output = "o"
}

class PulsarState: Hashable {
    var pulsarType: PulsarType
    var name: Substring
    var inputs: [Substring: Bool] = [:]
    var state: Bool = false

    init(_ source: Pulsar) {
        self.pulsarType = source.pulsarType
        self.name = source.name
        self.inputs = source.inputs
        self.state = source.state
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(pulsarType)
        hasher.combine(inputs)
        hasher.combine(state)
    }

    static func == (lhs: PulsarState, rhs: PulsarState) -> Bool {
        return lhs.name == rhs.name && lhs.pulsarType == rhs.pulsarType && lhs.inputs == rhs.inputs && lhs.state == rhs.state
    }
}

class PulsarEvent: Comparable {
    var time: Int
    var destination: Substring
    var highPulse: Bool
    
    init(time: Int, destination: Substring, highPulse: Bool) {
        self.time = time
        self.destination = destination
        self.highPulse = highPulse
    }
    
    static func < (lhs: PulsarEvent, rhs: PulsarEvent) -> Bool {
        return lhs.time < rhs.time
    }

    static func == (lhs: PulsarEvent, rhs: PulsarEvent) -> Bool {
        return lhs.time == rhs.time && lhs.destination == rhs.destination && lhs.highPulse == rhs.highPulse
    }
}

class Pulsar {
    var pulsarType: PulsarType
    var name: Substring
    var parent: PulsarNetwork
    var destinations: [Substring] = []
    var inputs: [Substring: Bool] = [:]
    var state: Bool = false
    var history: [Int: Bool] = [:]

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
            history[parent.time()] = highPulse
            for destination in destinations {
                parent.queuePulse(source: name, destination: destination, highPulse: highPulse, verbose: verbose)
            }
        case .flipflop:
            if highPulse {
                // Do nothing.
            }
            else {
                state = !state
                history[parent.time()] = state
                for destination in destinations {
                    parent.queuePulse(source: name, destination: destination, highPulse: state, verbose: verbose)
                }
            }
        case .conjunction:
            inputs[source] = highPulse
            let pulse = !inputs.values.reduce(true, { $0 && $1 })
            history[parent.time()] = pulse
            for destination in destinations {
                parent.queuePulse(source: name, destination: destination, highPulse: pulse, verbose: verbose)
            }
        case .output:
            parent.registerOutputPulse(source: name, highPulse: highPulse, verbose: verbose)
            break
        }
    }

    func compressHistory() -> [Int: Bool] {
        var newHistory: [Int: Bool] = [:]
        var lastValue: Bool = false
        for (time, value) in history.sorted(by: { $0.key < $1.key }) {
            if value != lastValue {
                newHistory[time] = value
                lastValue = value
            }
        }
        return newHistory
    }
}

class PulsarNetwork {
    var pulsars: [Substring: Pulsar] = [:]
    var pulseQueue: [(Substring, Substring, Bool)] = []
    var pulseCount = [0, 0]
    var gotOutputPulse = false
    var coneOfInfluence: [Substring: Set<Substring>] = [:]
    var sentLowPulse: Set<Substring> = Set()
    var pushCount = 0
    var subTime = 0
    
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
        if !highPulse {
            sentLowPulse.insert(source)
        }
    }

    func registerOutputPulse(source: Substring, highPulse: Bool, verbose: Bool = false) {
        if verbose {
            print("Output pulse from \(source) is \(highPulse ? "high" : "low")")
        }
        if !highPulse {
            gotOutputPulse = true
        }
    }

    func time() -> Int {
        guard subTime < 1000 else {
            fatalError("Too many subtime pulses")
        }
        return pushCount * 1000 + subTime
    }

    func pressButton(verbose: Bool) {
        sentLowPulse = Set()
        pulseCount[0] += 1 // Low pulse
        if verbose {
            print("Pulse from button to roadcaster is low")
        }
        pushCount += 1
        subTime = 0
        pulsars["roadcaster"]!.pulse(source: "button", highPulse: false, verbose: verbose)
        processAllPulses(verbose: verbose)
    }

    func processAllPulses(verbose: Bool) {
        while pulseQueue.count > 0 {
            processOneClockCycle(verbose: verbose)
            subTime += 1
        }
    }

    func processOneClockCycle(verbose: Bool) {
        let thesePulses = pulseQueue
        pulseQueue = []
        if verbose {
            print("\nTime \(subTime) has \(thesePulses.count) pulses")
        }
        for (source, destination, highPulse) in thesePulses {
            if verbose {
                print("Pulse from \(source) to \(destination) is \(highPulse ? "high" : "low")")
            }
            pulseCount[highPulse ? 1 : 0] += 1
            pulsars[destination]!.pulse(source: source, highPulse: highPulse, verbose: verbose)
        }
    }
    
    func createConeOfInfluence(destination: Substring, stack: inout [Substring]) -> Set<Substring> {
        //print("Creating cone of influence for \(destination)")
        if stack.contains(destination) {
            //print("Already in stack")
            return Set()
        }
        if coneOfInfluence[destination] != nil {
            //print("Already calculated as \(coneOfInfluence[destination]!)")
            return coneOfInfluence[destination]!
        }
        var result: Set<Substring> = Set([destination])
        stack.append(destination)
        for source in pulsars[destination]!.inputs.keys {
            //print("Checking source \(source)")
            let coi = createConeOfInfluence(destination: source, stack: &stack)
            //print("Got \(coi)")
            result.formUnion(coi)
        }
        stack.removeLast()
        //print("Cone of influence for \(destination) is \(result)")
        coneOfInfluence[destination] = result
        return result
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

        if partTwo {
            // Find the inputs of rx, and then _their_ inputs, until we get to something
            // that isn't a conjunction. Then create cones of influence for each of those inputs.
            var latePulsars: Set<Substring> = Set()
            var influencePulsars: [Substring: Set<Substring>] = [:]
            var pulsarQueue: [Substring] = ["rx"]

            while pulsarQueue.count > 0 {
                let tempPulsarQueue: [Substring] = pulsarQueue
                pulsarQueue = []
                for pulsar in tempPulsarQueue {
                    //print("Checking \(pulsar), inputs \(network.pulsars[pulsar]!.inputs)")
                    if network.pulsars[pulsar]!.inputs.map({ network.pulsars[$0.key]!.pulsarType == .conjunction }).reduce(true, { $0 && $1 }) {
                        // All inputs are conjunctions, so this is another late pulsar.
                        //print("All inputs are conjunctions")
                        latePulsars.insert(pulsar)
                        for input in network.pulsars[pulsar]!.inputs.keys {
                            pulsarQueue.append(input)
                        }
                    }
                    else {
                        // This is a pulsar whose cone of influence we need to know.
                        if influencePulsars[pulsar] == nil {
                            //print("All inputs are NOT conjunctions, creating cone of influence")
                            var stack: [Substring] = []
                            influencePulsars[pulsar] = network.createConeOfInfluence(destination: pulsar, stack: &stack)
                        }
                    }
                }
            }
            // Now press the button until we get to a state we've seen before.
            var seenStates: [Substring: [Set<PulsarState>: Int]] = [:]
            var seenRepeat: [Substring: [(Int, Int, Int)]] = [:]
            for i in influencePulsars.keys {
                seenStates[i] = [:]
                seenRepeat[i] = []
            }

            //print("Influence pulsars: \(influencePulsars)")
            //print("Seen states: \(seenStates)")
            //print("Seen repeats: \(seenRepeat)")

            
            while (!seenRepeat.map({ $0.value.count != 0 }).reduce(true, { $0 && $1 })) {
                network.pressButton(verbose: verbose)
                for (pulsar, coi) in influencePulsars {
                    let state = Set(coi.map({ PulsarState(network.pulsars[$0]!) }))
                    if seenStates[pulsar]![state] == nil {
                        seenStates[pulsar]![state] = network.pushCount
                    }
                    else if seenRepeat[pulsar]!.count == 0 {
                        seenRepeat[pulsar]!.append((network.pushCount, seenStates[pulsar]![state]!, network.pushCount - seenStates[pulsar]![state]!))
                    }
                }
            }

            // Sad to say, the brute force method below takes too long. All we need to do is
            // LCM the repeat counts and that's the answer.
            answer = influencePulsars.keys.map({ (seenRepeat[$0] ?? [(0,0,0)])[0].2 }).reduce(1, { lcm($0, $1) })


            
            /*
            let influenceHistory = influencePulsars.map({ ($0.key, network.pulsars[$0.key]!.compressHistory().sorted(by: { $0.key < $1.key })) })
            //print("History: \(influenceHistory)")
            
            // From here, I think we can do this by brute force.
            // Let's keep a queue of the times when the pulsars will turn off
            // and on, and then pull events off the queue in order until we
            // emit a low pulse.
            var eventHeap: Heap<PulsarEvent> = Heap<PulsarEvent>()

            for (pulsar, history) in influenceHistory {
                for (time, state) in history {
                    eventHeap.insert(PulsarEvent(time: time, destination: pulsar, highPulse: state))
                }
            }

            //print("Event heap: \(eventHeap.unordered)")
            //print("Late pulsars: \(latePulsars)")

            print("Influence pulsars:")
            for pulsar in influencePulsars.keys {
                print("\(pulsar) -> \(network.pulsars[pulsar]!.destinations)")
            }
            print("\nLate pulsars:")
            for pulsar in latePulsars {
                print("\(pulsar) -> \(network.pulsars[pulsar]!.destinations)")
            }
            
            // Set up a simplified pulsar network that only has the late pulsars
            // plus the influence pulsars as broadcasters.
            let lateNetwork: PulsarNetwork = PulsarNetwork()
            for pulsar in influencePulsars.keys {
                lateNetwork.addPulsar(name: pulsar, type: .broadcaster)
            }
            for pulsar in latePulsars {
                lateNetwork.addPulsar(name: pulsar, type: (pulsar == "rx" ? .output : .conjunction))
            }

            for pulsar in influencePulsars.keys {
                for dest in network.pulsars[pulsar]!.destinations {
                    if latePulsars.contains(dest) {
                        lateNetwork.addConnection(source: pulsar, destination: dest)
                    }
                }
            }
            for pulsar in latePulsars {
                for dest in network.pulsars[pulsar]!.destinations {
                    if latePulsars.contains(dest) {
                        lateNetwork.addConnection(source: pulsar, destination: dest)
                    }
                }
            }
            
            print("Late network: \(lateNetwork.pulsars.keys)")

            
            var currentTime: Int = 0
            var curEvent: PulsarEvent? = eventHeap.popMin()!
            while true {
                if verbose {
                    print("Current time: \(currentTime), top of heap: \(curEvent?.time ?? -1), queue: \(lateNetwork.pulseQueue.count)")
                }
                if curEvent != nil {
                    if curEvent!.time < currentTime {
                        fatalError("Event at time \(curEvent!.time) is in the past")
                    } else if curEvent!.time == currentTime {
                        // Process the pulse.
                        if verbose {
                            print("Pulsar \(curEvent!.destination) at time \(curEvent!.time), high \(curEvent!.highPulse)")
                        }
                        // Now recur this event for the next time.
                        eventHeap.insert(PulsarEvent(time: curEvent!.time + seenRepeat[curEvent!.destination]![0].2 * 1000, destination: curEvent!.destination, highPulse: curEvent!.highPulse))
                        // Send the pulse.
                        lateNetwork.pulsars[curEvent!.destination]!.pulse(source: "virtual", highPulse: curEvent!.highPulse, verbose: verbose)
                        // And get the next one.
                        curEvent = eventHeap.popMin()
                    }
                }
                if lateNetwork.pulseQueue.count > 0 {
                    lateNetwork.processOneClockCycle(verbose: verbose)
                    lateNetwork.subTime += 1
                }
                if lateNetwork.gotOutputPulse {
                    print("Got output pulse at time \(lateNetwork.pushCount * 1000 + lateNetwork.subTime)")
                    break
                }
                if lateNetwork.pulseQueue.count == 0 && curEvent != nil {
                    // We're out of events, but we still have pulses to process.
                    // So advance the clock to the next event.
                    if verbose {
                        print("\n\nAdvancing clock to \(curEvent!.time)")
                    }
                    currentTime = curEvent!.time
                    lateNetwork.pushCount = Int(currentTime / 1000)
                    lateNetwork.subTime = currentTime % 1000
                }
            }
            answer = Int(lateNetwork.pushCount)
            */
        }
        else {
            let buttonPresses = argint ?? 1000
            
            for _ in 0 ..< buttonPresses {
                //print("Button press \(i)")
                network.pressButton(verbose: verbose)
            }
            //print("Low pulses: \(network.pulseCount[0]), high pulses: \(network.pulseCount[1])")

            answer = network.pulseCount[1] * network.pulseCount[0]
        }
        print("Answer is \(answer)")
    }
}
