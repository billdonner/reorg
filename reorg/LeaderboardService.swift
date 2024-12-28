//
//  LeaderboardService.swift
//  qandao
//
//  Created by bill donner on 8/30/24.
//

import SwiftUI

import CloudKit

// MARK: - Model
struct PlayerScore: Identifiable {
    let id: CKRecord.ID
    let playerName: String
    let score: Int
    let date: Date

    init(record: CKRecord) {
        self.id = record.recordID
        self.playerName = record["playerName"] as? String ?? "Unknown"
        self.score = record["score"] as? Int ?? 0
        self.date = record["date"] as? Date ?? Date()
    }

    init(playerName: String, score: Int, date: Date) {
        self.id = CKRecord.ID()
        self.playerName = playerName
        self.score = score
        self.date = date
    }

    func toCKRecord() -> CKRecord {
        let record = CKRecord(recordType: "PlayerScore", recordID: id)
        record["playerName"] = playerName as CKRecordValue
        record["score"] = score as CKRecordValue
        record["date"] = date as CKRecordValue
        return record
    }
}
@Observable
class LeaderboardService {
    private let container: CKContainer?
    private let publicDatabase: CKDatabase?
    var scores: [PlayerScore] = []

    init() {
      if cloudKitBypass {
        self.container = nil
        self.publicDatabase = nil
      } else {
        self.container = CKContainer(identifier:  cloudKitLeaderBoardContainerID)
        self.publicDatabase = container?.publicCloudDatabase
     
        fetchScores()
      }
    }

    func fetchScores() {
      if !cloudKitBypass {
        
        let query = CKQuery(recordType: "PlayerScore", predicate: NSPredicate(value: true))
        query.sortDescriptors = [NSSortDescriptor(key: "score", ascending: false)]
        
        let operation = CKQueryOperation(query: query)
        
        operation.recordMatchedBlock = { recordID, result in
          switch result {
          case .success(let record):
            DispatchQueue.main.async {
              let score = PlayerScore(record: record)
              self.scores.append(score)
            }
          case .failure(let error):
            print("Error fetching record: \(error.localizedDescription)")
          }
        }
        
        operation.queryResultBlock = { [weak self] result in
          switch result {
          case .success:
            DispatchQueue.main.async {
              self?.scores.sort { $0.score > $1.score }
            }
          case .failure(let error):
            print("Error completing query: \(error.localizedDescription)")
          }
        }
        
        publicDatabase?.add(operation)
      }
    }

    // Re-adding the addScore method
    func addScore(playerName: String, score: Int) {
      if !cloudKitBypass {
        let newScore = PlayerScore(playerName: playerName, score: score, date: Date())
        let record = newScore.toCKRecord()
        
        publicDatabase?.save(record) { [weak self] _, error in
          if let error = error {
            print("Error saving score: \(error.localizedDescription)")
          } else {
            DispatchQueue.main.async {
              self?.scores.append(newScore)
              self?.scores.sort { $0.score > $1.score }
            }
          }
        }
      }
    }

  func clearScores() {
    if !cloudKitBypass {
      
      let query = CKQuery(recordType: "PlayerScore", predicate: NSPredicate(value: true))
      let operation = CKQueryOperation(query: query)
      
      operation.recordMatchedBlock = { recordID, result in
        switch result {
        case .success(_):
          self.publicDatabase?.delete(withRecordID: recordID) { _, error in
            if let error = error {
              print("Error deleting record: \(error.localizedDescription)")
            }
          }
        case .failure(let error):
          print("Error fetching record: \(error.localizedDescription)")
        }
      }
      
      operation.queryResultBlock = { [weak self] result in
        switch result {
        case .success:
          DispatchQueue.main.async {
            self?.scores.removeAll()
          }
        case .failure(let error):
          print("Error completing query: \(error.localizedDescription)")
        }
      }
      
      publicDatabase?.add(operation)
    }
  }
}
