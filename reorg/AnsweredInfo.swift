//
//  AnsweredInfo.swift
//  basic
//
//  Created by bill donner on 8/3/24.
//

import Foundation


extension AnsweredInfo {
  
  func checkConsistency() {
    assert (outcome == .playedCorrectly || outcome == .playedCorrectly || outcome == .abandoned)
  }
  // Get the file path for storing challenge statuses
  static func getAnsweredInfoFilePath() -> URL {
      let fileManager = FileManager.default
      let urls = fileManager.urls(for:.documentDirectory, in: .userDomainMask)
      return urls[0].appendingPathComponent("answeredinfo.json")
  }
  static func saveAnsweredInfo (_ info:[String:AnsweredInfo]) {
    //TSLog("SAVE ANSWER INFO")
    let filePath = Self.getAnsweredInfoFilePath()
      do {
          let data = try JSONEncoder().encode(info)
          try data.write(to: filePath)
      } catch {
          print("Failed to save AnsweredInfo: \(error)")
      }
  }
  // Load  from a file
  static func loadAnsweredInfo() -> [String:AnsweredInfo]? {
    let filePath = getAnsweredInfoFilePath()
      do {
          let data = try Data(contentsOf: filePath)
          let dict = try JSONDecoder().decode([String:AnsweredInfo].self, from: data)
          return dict
      } catch {
          print("Failed to load AnsweredInfo: \(error)")
          return nil
      }
  }
  static func dumpAnsweredInfo(info:[String:AnsweredInfo]) {
        for (index,inf) in info.enumerated() {
          let tinfo:AnsweredInfo =    inf.value
          print("\(index): \(inf.key) \(tinfo.answer) \(tinfo.timestamp) \(tinfo.timetoanswer) \(tinfo.gamenumber) \(tinfo.movenumber  )")
        }
  }
  
}
