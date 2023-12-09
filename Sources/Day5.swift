enum Almanac: String {
    case seedToSoil = "seed-to-soil"
    case soilToFertilizer = "soil-to-fertilizer"
    case fertilizerToWater = "fertilizer-to-water"
    case waterToLight = "water-to-light"
    case lightToTemperature = "light-to-temperature"
    case temperatureToHumidity = "temperature-to-humidity"
    case humidityToLocation = "humidity-to-location"
}

struct AlmanacMapEntry {
    var from: Int
    var to: Int
    var numElements: Int
}

class AlmanacMap {
    var entries: [AlmanacMapEntry] = []
    
    func addEntry(from: Int, to: Int, numElements: Int) {
        entries.append(AlmanacMapEntry(from: from, to: to, numElements: numElements))
    }

    func findOne(_ at: Int) -> AlmanacMapEntry {
        var before: AlmanacMapEntry = AlmanacMapEntry(from: 0, to: 0, numElements: 0)
        var after: AlmanacMapEntry = AlmanacMapEntry(from: Int.max, to: 123456789, numElements: Int.max)
        for entry in entries {
            if entry.from <= at && at < entry.from + entry.numElements {
                return entry
            }
            if entry.from > at {
                if entry.from < after.from {
                    after = entry
                }
            }
            if entry.from + entry.numElements <= at {
                if entry.from + entry.numElements > before.from + before.numElements {
                    before = entry
                }
            }
        }
        return AlmanacMapEntry(from: before.from + before.numElements, to: before.from + before.numElements, numElements: after.from - (before.from + before.numElements))
    }


    func find(_ at: [AlmanacMapEntry]) -> [AlmanacMapEntry] {
        var answer: [AlmanacMapEntry] = []
        //print("Finding \(at)")
        for cur in at {
            var cur = cur
            //print(" Finding \(cur)")
            while cur.numElements > 0 {
                let entry = findOne(cur.to)
                //print(" Found \(entry)")
                let offset = cur.to - entry.from
                let numElements = min(entry.numElements - offset, cur.numElements)
                answer.append(AlmanacMapEntry(from: cur.to, to: entry.to + offset, numElements: numElements))
                cur.from += numElements
                cur.numElements -= numElements
                cur.to += numElements
                //print(" Cur is now \(cur)")
            }
        }
        //print("Answer is \(answer)")
        return answer
    }
}

class Day5: AdventDay {
    override func run() {
        var answer: Int = 0
        var seeds: [AlmanacMapEntry] = []
        var maps: [Almanac: AlmanacMap] = [:]
        var curMap: Almanac? = nil
        for str in inputStrings {
            if str.length == 0 {
                continue
            }
            if str.hasPrefix("seeds:") {
                // Here are the seeds.
                let split = str.split(separator: ": ")[1].split(separator: " ")
                if partTwo {
                    var curSeed: Int? = nil
                    for seed in split {
                        if curSeed == nil {
                            curSeed = Int(seed)!
                        }
                        else {
                            seeds.append(AlmanacMapEntry(from: curSeed!, to: curSeed!, numElements: Int(seed)!))
                            curSeed = nil
                        }
                    }
                }
                else {
                    for seed in split {
                        seeds.append(AlmanacMapEntry(from: Int(seed)!, to: Int(seed)!, numElements: 1))
                    }
                }
            }
            else if str.contains("map:") {
                // Time for a new map.
                let split = str.split(separator: " ")
                let mapName = Almanac(rawValue: String(split[0]))!
                curMap = mapName
                //print("New map \(mapName)")
                maps[mapName] = AlmanacMap()
            }
            else {
                // There better be three ints here. Update the map.
                let split = str.split(separator: " ")
                let to = Int(split[0])!
                let from = Int(split[1])!
                let numElements = Int(split[2])!
                //print("From \(from) to \(to) with \(numElements) elements")
                maps[curMap!]!.addEntry(from: from, to: to, numElements: numElements)
            }
        }
        // Now we have all the maps. Time to run the seeds through them.
        answer = Int.max
        for seed in seeds {
            let soil = maps[.seedToSoil]!.find([seed])
            let fertilizer = maps[.soilToFertilizer]!.find(soil)
            let water = maps[.fertilizerToWater]!.find(fertilizer)
            let light = maps[.waterToLight]!.find(water)
            let temperature = maps[.lightToTemperature]!.find(light)
            let humidity = maps[.temperatureToHumidity]!.find(temperature)
            let location = maps[.humidityToLocation]!.find(humidity)

            //print("Seed \(seed) -> soil \(soil) -> fertilizer \(fertilizer) -> water \(water) -> light \(light) -> temperature \(temperature) -> humidity \(humidity) -> location \(location)")
            for loc in location {
                if loc.to < answer {
                    answer = loc.to
                }
            }
        }
        print("Answer is \(answer)")
    }
}
