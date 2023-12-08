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

struct SeedRange {
    var from: Int
    var numElements: Int
}

struct SeedMap {
    var from: SeedMap?
    var to: SeedRange
}

class AlmanacMap {
    var entries: [AlmanacMapEntry] = []
    
    func addEntry(from: Int, to: Int, numElements: Int) {
        entries.append(AlmanacMapEntry(from: from, to: to, numElements: numElements))
    }

    func find(_ from: [SeedMap]) -> [SeedMap] {
        // FINISHME.
        for entry in entries {
            if entry.from <= from && from < entry.from + entry.numElements {
                return entry.to + (from - entry.from)
            }
        }
        return from
    }
}

class Day5: AdventDay {
    override func run() {
        var answer: Int = 0
        var seeds: Set<SeedRange> = Set([])
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
                            seeds.insert(SeedRange(from: curSeed!, numElements: Int(seed)!))
                            curSeed = nil
                        }
                    }
                }
                else {
                    for seed in split {
                        seeds.insert(SeedRange(from: Int(seed)!, numElements: 1))
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
        answer = 999999999
        for seed in seeds {
            let soil = maps[.seedToSoil]!.find([seed])
            let fertilizer = maps[.soilToFertilizer]!.find(soil)
            let water = maps[.fertilizerToWater]!.find(fertilizer)
            let light = maps[.waterToLight]!.find(water)
            let temperature = maps[.lightToTemperature]!.find(light)
            let humidity = maps[.temperatureToHumidity]!.find(temperature)
            let location = maps[.humidityToLocation]!.find(humidity)

            //print("Seed \(seed) -> soil \(soil) -> fertilizer \(fertilizer) -> water \(water) -> light \(light) -> temperature \(temperature) -> humidity \(humidity) -> location \(location)")
            
            if location < answer {
                answer = location
            }
        }
        print("Answer is \(answer)")
    }
}
