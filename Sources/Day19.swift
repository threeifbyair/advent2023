import Foundation
import RegexBuilder

struct MachinePart {
    var props: [Substring: Int] = [:]
}

struct MachinePartSet {
    var props: [Substring: [(Int, Int)]] = [:]

    func total() -> Int {
        var total = 1
        for (_, ranges) in props {
            var rangeTotal = 0
            //print("Prop \(p) has ranges \(ranges)")
            for (start, end) in ranges {
                rangeTotal += end - start + 1
            }
            //print("Range total is \(rangeTotal)")
            total *= rangeTotal
        }
        //print("Total is \(total)")
        return total
    }

    func split(rule: WorkflowRule) -> [MachinePartSet] {
        var satisfied = self
        var unsatisfied = self

        satisfied.props[rule.prop] = []
        unsatisfied.props[rule.prop] = []

        for (start, end) in props[rule.prop]! {
            if (rule.greater) {
                if (start > rule.value) {
                    // Easy case, the whole range is satisfied.
                    satisfied.props[rule.prop]!.append((start, end))
                } else if (end <= rule.value) {
                    // Easy case, the whole range is unsatisfied.
                    unsatisfied.props[rule.prop]!.append((start, end))
                }
                else {
                    // The range is split.
                    unsatisfied.props[rule.prop]!.append((start, rule.value))
                    satisfied.props[rule.prop]!.append((rule.value + 1, end))
                }
            }
            else {
                if (end < rule.value) {
                    // Easy case, the whole range is satisfied.
                    satisfied.props[rule.prop]!.append((start, end))
                } else if (start >= rule.value) {
                    // Easy case, the whole range is unsatisfied.
                    unsatisfied.props[rule.prop]!.append((start, end))
                }
                else {
                    // The range is split.
                    satisfied.props[rule.prop]!.append((start, rule.value - 1))
                    unsatisfied.props[rule.prop]!.append((rule.value, end))
                }
            }
        }
        return [satisfied, unsatisfied]
    }
}


struct WorkflowRule {
    var unconditional: Bool
    var prop: Substring
    var greater: Bool
    var value: Int
    var destination: Substring
}

class Workflow {
    var rules: [WorkflowRule] = []

    init(rules: [WorkflowRule]) {
        self.rules = rules
    }
}

class WorkflowSet {
    static let acceptFlow: Workflow = Workflow(rules: [])
    static let rejectFlow: Workflow = Workflow(rules: [])

    var ruleset: [Substring: Workflow] = ["A": WorkflowSet.acceptFlow, "R": WorkflowSet.rejectFlow]

    func processPart(part: MachinePart) -> Bool {
        var curWorkflow: Substring = "in"
        //print("Processing part \(part)")
        while ruleset[curWorkflow] !== WorkflowSet.acceptFlow && ruleset[curWorkflow] !== WorkflowSet.rejectFlow {
            //print("Current workflow is \(curWorkflow), ruleset is \(ruleset[curWorkflow]!.rules)")
            let curSet = ruleset[curWorkflow]!.rules
            for rule in curSet {
                //print("Checking rule \(rule)")
                if rule.unconditional {
                    // It's an unconditional rule, we're done.
                    curWorkflow = rule.destination
                    //print("Unconditional rule, destination is \(curWorkflow)")
                    break
                }
                if part.props[rule.prop] == nil {
                    // We don't have this property. On to the next rule.
                    continue
                }
                let val = part.props[rule.prop]!
                //print("Comparing \(val) to \(rule.value), greater is \(rule.greater), destination is \(rule.destination)")
                if (rule.greater && val > rule.value) || (!rule.greater && val < rule.value) {
                    // The property matched.
                    curWorkflow = rule.destination
                    //print("Property matched, destination is \(curWorkflow)")
                    break
                }
            }
        }
        //print("Final workflow is \(curWorkflow)")
        return ruleset[curWorkflow] === WorkflowSet.acceptFlow
    }



    func processFlow(flow: Substring, part: MachinePartSet, depth: Int = 0) -> (Int, Int) {
        //print(String(repeating: "+", count: depth+1), "Processing flow \(flow) with part \(part.props)")
        if ruleset[flow] === WorkflowSet.acceptFlow {
            return (part.total(), 0)
        }
        if ruleset[flow] === WorkflowSet.rejectFlow {
            return (0, part.total())
        }
        let curSet = ruleset[flow]!.rules
        var combinations = (0, 0)
        var curPart = part
        for rule in curSet {
            if rule.unconditional {
                // It's an unconditional rule, we're done.
                //print(String(repeating: "*", count: depth+1), "Rule \(rule) is unconditional, destination is \(rule.destination)")
                let thisCombination = processFlow(flow: rule.destination, part: curPart, depth: depth + 1)
                //print(String(repeating: "*", count: depth+1), "Rule \(rule) adds \(thisCombination) combinations")
                combinations = (combinations.0 + thisCombination.0, combinations.1 + thisCombination.1)
                break
            }
            let partSplit = curPart.split(rule: rule)
            //print(String(repeating: "*", count: depth+1), "Rule \(rule) splits\n", String(repeating: "*", count: depth+1), "  part \(curPart.props)\n", String(repeating: "*", count: depth+1), "  into \(partSplit[0].props)\n", String(repeating: "*", count: depth+1), "   and \(partSplit[1].props)")
            let thisCombination = processFlow(flow: rule.destination, part: partSplit[0], depth: depth + 1)
            //print(String(repeating: "*", count: depth+1), "Rule \(rule) adds \(thisCombination) combinations")
            combinations = (combinations.0 + thisCombination.0, combinations.1 + thisCombination.1)
            curPart = partSplit[1]
        }
        //print(String(repeating: "-", count: depth+1), "Done processing flow \(flow) with part \(part.props), returning \(combinations)")
        return combinations
    }
}

class Day19: AdventDay {

    override func run() {
        var answer: Int = 0
        var inParts = false
        let workset: WorkflowSet = WorkflowSet()
        let propTest = Reference(Substring.self)
        let greater = Reference(Substring.self)
        let value = Reference(Substring.self)
        let destination = Reference(Substring.self)
        let ex = Regex {
            Capture(as: propTest) {
                OneOrMore(.word)
            }
            Capture(as: greater) {
                ChoiceOf {">"
                          "<"}
            }
            Capture(as: value) {
                OneOrMore(.digit)
            }
            ":"
            Capture(as: destination) {
                OneOrMore(.word)
            }
        }            
        for str in inputStrings {
            if str.length == 0 {
                inParts = true
                continue
            }
            if inParts {
                if partTwo {
                    // The momont we hit this, we're done. Let's calculate.
                    let part = MachinePartSet(props: ["x": [(1, 4000)], "m": [(1, 4000)], "a": [(1, 4000)], "s": [(1, 4000)]])
                    let answerSet = workset.processFlow(flow: "in", part: part)
                    guard answerSet.0 + answerSet.1 == (4000*4000*4000*4000) else {
                        print("Found \(answerSet.0 + answerSet.1) combinations, expected \(4000*4000*4000*4000) -- \(answerSet.0) accepted, \(answerSet.1) rejected")
                        break
                    }
                    answer = answerSet.0
                    break
                }
                else {
                    let earlyIndex = str.index(str.startIndex, offsetBy: 1)
                    let lateIndex = str.index(str.endIndex, offsetBy: -1)
                    let propstr = String(str[earlyIndex ..< lateIndex])
                    let propsplit = propstr.split(separator: ",")
                    var propdict: [Substring: Int] = [:]
                    for prop in propsplit {
                        let undersplit = prop.split(separator: "=")
                        propdict[undersplit[0]] = Int(undersplit[1])!
                    }
                    //print("Part is \(propdict)")
                    let part = MachinePart(props: propdict)
                    if workset.processPart(part: part) {
                        // This part was accepted!
                        let thisAnswer = part.props.map( { $0.value} ).reduce(0, +)
                        answer += thisAnswer
                    }
                }
            }
            else {
                let rulestr = str.split(separator: "{")
                let rulename = rulestr[0]
                let rules = String(rulestr[1])
                let lateIndex = rules.index(rules.endIndex, offsetBy: -1)
                let rulelist = rules[rules.startIndex ..< lateIndex].split(separator: ",")
                var outRules: [WorkflowRule] = []
                for rule in rulelist {
                    if !rule.contains(":") {
                        // This is an unconditional rule.
                        outRules.append(WorkflowRule(unconditional: true, prop: "", greater: false, value: 0, destination: rule))
                    }
                    else {
                        //print("Rule is \(rule)")
                        let rulematch = rule.firstMatch(of: ex)!
                        outRules.append(WorkflowRule(unconditional: false, prop: rulematch[propTest], greater: rulematch[greater] == ">", value: Int(rulematch[value])!, destination: rulematch[destination]))
                    }
                }
                //print("Rule \(rulename) is \(outRules)")
                workset.ruleset[rulename] = Workflow(rules: outRules)
            }
        }
        
        print("Answer is \(answer)")
    }
}
