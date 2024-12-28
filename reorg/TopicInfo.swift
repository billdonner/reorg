//
//  TopicInfo.swift
//  basic
//
//  Created by bill donner on 7/31/24.
//

import Foundation


extension TopicInfo {
 

    // MARK: - Mock Instance
    static var mock: Self = {
        TopicInfo(
            name: "mock",
            alloccount: 1,
            freecount: 1,
            replacedcount: 0,
            rightcount: 1,
            wrongcount: 0,
            challengeIndices: [1, 2, 3]
        )
    }()

    // MARK: - Methods
    func checkConsistency() {
        assert(
            alloccount + freecount + replacedcount + rightcount + wrongcount == challengeIndices.count,
            "Inconsistent TopicInfo: the sum of counts does not match challengeIndices count."
        )
    }

    func getChallengesAndStatuses(chmgr: ChaMan) -> ([Challenge], [ChallengeStatus]) {
        checkConsistency()
        var challenges: [Challenge] = []
        var statuses: [ChallengeStatus] = []
        for challengeIdx in challengeIndices {
            challenges.append(chmgr.everyChallenge[challengeIdx])
            statuses.append(chmgr.stati[challengeIdx])
        }
        return (challenges, statuses)
    }

    // MARK: - Persistence
    static func getTopicInfoFilePath() -> URL {
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[0].appendingPathComponent("topicinfo.json")
    }

    static func saveTopicInfo(_ info: [String: TopicInfo]) {
        let filePath = getTopicInfoFilePath()
        do {
            let data = try JSONEncoder().encode(info)
            try data.write(to: filePath)
        } catch {
            print("Failed to save TopicInfo: \(error)")
        }
    }

    static func loadTopicInfo() -> [String: TopicInfo]? {
        let filePath = getTopicInfoFilePath()
        do {
            let data = try Data(contentsOf: filePath)
            let dict = try JSONDecoder().decode([String: TopicInfo].self, from: data)
            return dict
        } catch {
            print("Failed to load TopicInfo: \(error)")
            return nil
        }
    }

    static func dumpTopicInfo(info: [String: TopicInfo]) {
        for (index, inf) in info.enumerated() {
            let tinfo: TopicInfo = inf.value
            print("\(index): \(inf.key) \(tinfo.challengeIndices.count)")
        }
    }
}

// MARK: - ChaMan Extension for TopicInfo
extension ChaMan {
    func setupTopicInfo() {
        // Calculate free counts by topic
        var freeCountByTopic: [String: Int] = [:]
        var challengesByTopic: [String: [Int]] = [:]

        // Iterate through all challenges and count free ones
        for (index, challenge) in everyChallenge.enumerated() {
            if stati[index] == .inReserve {
                freeCountByTopic[challenge.topic, default: 0] += 1
                challengesByTopic[challenge.topic, default: []].append(index)
            } else {
                fatalError("Challenge status mismatch: non-reserved challenge found in setup.")
            }
        }

        // Iterate through all topics and initialize TopicInfo
        for topic in playData.topicData.topics {
            let ti = TopicInfo(
                name: topic.name,
                alloccount: 0,
                freecount: freeCountByTopic[topic.name] ?? 0,
                replacedcount: 0,
                rightcount: 0,
                wrongcount: 0,
                challengeIndices: challengesByTopic[topic.name] ?? []
            )
            tinfo[topic.name] = ti
        }
    }

    func bumpWrongcount(topic: String) {
        if var t = tinfo[topic] {
            t.wrongcount += 1
            t.alloccount -= 1
            tinfo[topic] = t
        }
    }

    func bumpRightcount(topic: String) {
        if var t = tinfo[topic] {
            t.rightcount += 1
            t.alloccount -= 1
            tinfo[topic] = t
        }
    }
}
