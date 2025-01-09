//
//  subs.swift
//  qdemo
//
//  Created by bill donner on 5/23/24.
//

import SwiftUI


func flattenDictionaryKeys<K, V>(_ dictionary: [K: V]) -> [K] {
    return Array(dictionary.keys)
}
func flattenDictionaryValues<K, V>(_ dictionary: [K: V]) -> [V] {
    return Array(dictionary.values)
}
func removeInstances<T: Equatable>(from array: [T], removing elements: [T]) -> [T] {
    return array.filter { !elements.contains($0) }
}

func colorize(scheme:ColorSchemeName,topics:[String]) -> [String:FreeportColor] {
  let colors = availableColorsForScheme(  scheme)
  assert(topics.count <= colors.count,"Too many topics \(topics.count) for \(colors.count) colors")
  let colorMap: [String:FreeportColor] = zip(topics,colors).reduce(into: [:]) { result, pair in
    result[pair.0] = pair.1
  }
  return colorMap
}

// Function to convert SwiftUI Color to RGB
func colorToRGB(color: Color) -> RGB {
  // Convert to UIColor (iOS)
  let uiColor = UIColor(color)
  
  // Extract RGB components
  var red: CGFloat = 0
  var green: CGFloat = 0
  var blue: CGFloat = 0
  var alpha: CGFloat = 0
  
  uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
  
  // Return RGB as a struct
  return RGB(red: Double(red) * 255.0,
             green: Double(green) * 255.0,
             blue: Double(blue) * 255.0)
}

/// Determines the contrasting text color (black or white) for a given background color.
func contrastingTextColor(for rgb: RGB) -> Color {
  let luminance = 0.299 * rgb.red + 0.587 * rgb.green + 0.114 * rgb.blue
  return luminance > 186 ? .black : .white
}
func optimalTextColor(for color: Color) -> Color {
  contrastingTextColor(for: colorToRGB(color: color))
}



// Get all available colors as enum values
 func getAllColors() -> [FreeportColor] {
  return FreeportColor.allCases
}

// Computed properties used throughout the app
var allColorSchemes: [[FreeportColor]] {
    allSchemes.map { $0.colors }
}

var allSchemeNames: [String] {
    allSchemes.map { $0.name }
}
func allColorsForScheme(_ schmindx: Int) -> [FreeportColor] {
  let x = allColorSchemes[schmindx]
  assert(x.count == colors_per_scheme, "Scheme \(schmindx) has \(x.count) colors" )
  return x
}
func colorForSchemeAndTopic(scheme schmindx: Int, index topicIndex: Int) -> FreeportColor {
  let theScheme = allColorSchemes[schmindx]
  return theScheme[topicIndex]
}
func availableColorsForScheme (_ schmindx: Int) -> [FreeportColor] {
  return allColorSchemes[schmindx]
}


/*
 Rework the basic topics->mycolor dict from one scheme to another, each topic is separately processed
 
 - get the current color for the topic as specified in in dict as its value ;
 -  lookup the color in the scheme's list of MyColors, obtaining its index or fail
 - find corresponding color for the new/to scheme
 - use that for topic's value
 
 */
func reworkColors(topics:[String:FreeportColor],fromscheme:Int, toscheme:Int) -> [String:FreeportColor] {
  print("Reworking colors for topics  from scheme \(fromscheme) to scheme \(toscheme)")
  return topics.mapValues { mycolor  in
    //find position in "fromscheme"
    guard let  posfrom = allColorSchemes[fromscheme].firstIndex(of: mycolor) else {
      print("did not find \(mycolor) in scheme \(fromscheme)")
      return FreeportColor.myHotPink}
    
    print("found index of \(mycolor) in scheme \(fromscheme) at \(posfrom)")
    // find color in same position in "toscheme" and return it
    guard posfrom >= 0 && posfrom < allColorSchemes[toscheme].count
    else { return FreeportColor.myGoldenrod
    }
    let  newColor = allColorSchemes[toscheme][posfrom]
    print("transformed to \(newColor) in scheme \(toscheme)")
    return newColor
  }
}


extension FreeportColor {
//  static func < (lhs: FreeportColor, rhs: FreeportColor) -> Bool {
//    return lhs.rawValue < rhs.rawValue
//  }
  
    func toColor() -> Color {
        return ColorManager.mycolors[self]?.color ?? Color.clear // Access the color using the enum case
    }
    
    func toColorName() -> String {
        return ColorManager.mycolors[self]?.name ?? "Unknown Color" // Access the name using the enum case
    }
}

extension ColorManager {
  // Ensure every FreeportColor has an entry in the dictionary
  static func validateColorEntries() {
    var missingCases: [FreeportColor] = []
    
    for color in FreeportColor.allCases {
      if mycolors[color] == nil {
        missingCases.append(color)
      }
    }
    
    // Print all missing cases if any
    if !missingCases.isEmpty {
      print("Missing entries for the following colors:")
      for missingColor in missingCases {
        print(missingColor)
      }
    }
    
    // Assert that there are no missing cases
    assert(missingCases.isEmpty, "Missing entries for FreeportColor cases.")
  }
  
}



extension Color {
  static let offBlack = Color(red: 0.1, green: 0.1, blue: 0.1)
  static let offWhite = Color(red: 0.95, green: 0.95, blue: 0.95)
}
class OrientationLockedViewController: UIViewController {
  override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    return .portrait
  }
}
class AppDelegate: NSObject, UIApplicationDelegate {
    static var orientationLock = UIInterfaceOrientationMask.portrait

    static func lockOrientation(_ orientation: UIInterfaceOrientationMask) {
        self.orientationLock = orientation
        
        // Notify the system to update the orientation
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            // This call requests an update to the geometry of the scene.
          windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait)) // Use .landscape if needed
        }
    }

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return AppDelegate.orientationLock
    }
}

var isIpad: Bool {
  UIDevice.current.systemName == "iPadOS"
}
func removeElements<T: Equatable>(from array: [T], elementsToRemove: [T]) -> [T] {
    return array.filter { !elementsToRemove.contains($0) }
}
func colorPaletteBackground(for scheme:ColorSchemeName) -> LinearGradient {
  switch scheme{
  case 1://.winter:
    return LinearGradient(gradient: Gradient(colors: [Color.blue, Color.cyan]), startPoint: .topLeading, endPoint: .bottomTrailing)
  case 2:// .spring:
    return LinearGradient(gradient: Gradient(colors: [Color.green, Color.yellow]), startPoint: .topLeading, endPoint: .bottomTrailing)
  case  3://.summer:
    return LinearGradient(gradient: Gradient(colors: [Color.green, Color.orange]), startPoint: .topLeading, endPoint: .bottomTrailing)
  case 4:// .autumn:
    return LinearGradient(gradient: Gradient(colors: [Color.brown, Color.orange]), startPoint: .topLeading, endPoint: .bottomTrailing)
  default://case 0:// .bleak:
    return LinearGradient(gradient: Gradient(colors: [Color.gray, Color.purple]), startPoint: .topLeading, endPoint: .bottomTrailing)
  }
}
func TSLog(_ message: String) {
    // Cache the DateFormatter instance for efficiency
    struct DateFormatterCache {
        static let shared = DateFormatter()
    }
    
    // Configure the DateFormatter only once
    let dateFormatter = DateFormatterCache.shared
    if dateFormatter.dateFormat.isEmpty {
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
    }
    // Generate the timestamp
  
    let timestamp = dateFormatter.string(from: Date())
    
    // Print the log with the timestamp
    NSLog("[\(timestamp)] \(message)")
}
 func conditionalAssert(_ condition: @autoclosure () -> Bool, _ message: @autoclosure () -> String = "", file: StaticString = #file, line: UInt = #line) {
    if shouldAssert {
        assert(condition(), message(), file: file, line: line)
    } else {
        if !condition() {
            print("ConditionalAssertion failed at \(file):\(line) - \(message())")
          
        }
    }
}
func warning(_ condition: @autoclosure () -> Bool, _ message: @autoclosure () -> String = "", file: StaticString = #file, line: UInt = #line) {
   if shouldAssert {
       assert(condition(), message(), file: file, line: line)
   } else {
       if !condition() {
           print("ConditionalAssertion failed at \(file):\(line) - \(message())")
       }
   }
}
func compareVersionStrings(_ version1: String, _ version2: String) -> ComparisonResult {
    // Split the version strings into components
    let components1 = version1.split(separator: ".").compactMap { Int($0) }
    let components2 = version2.split(separator: ".").compactMap { Int($0) }
    
    // Determine the maximum length between the two version components
    let maxLength = max(components1.count, components2.count)
    
    // Compare each corresponding component, treating missing components as 0
    for i in 0..<maxLength {
        let value1 = i < components1.count ? components1[i] : 0
        let value2 = i < components2.count ? components2[i] : 0
        
        if value1 < value2 {
            return .orderedAscending
        } else if value1 > value2 {
            return .orderedDescending
        }
    }
    
    return .orderedSame
}

func haveMajorComponentsChanged(_ version1: String, _ version2: String) -> Bool {
    // Split the version strings into components
    let components1 = version1.split(separator: ".").compactMap { Int($0) }
    let components2 = version2.split(separator: ".").compactMap { Int($0) }
    
    // Compare the w, x, and y components
    for i in 0..<3 {
        let value1 = i < components1.count ? components1[i] : 0
        let value2 = i < components2.count ? components2[i] : 0
        
        if value1 != value2 {
            return true
        }
    }
    
    return false
}


func testcc() {
  let comparisonResult1 = compareVersionStrings("1.2.3.4", "1.2.3.5") // Should return .orderedAscending
  let comparisonResult2 = compareVersionStrings("1.2.3", "1.2.3.0")    // Should return .orderedSame
  let comparisonResult3 = compareVersionStrings("2.0.0.0", "1.9.9.9")  // Should return .orderedDescending

  // Checking if major components (w, x, or y) have changed with four-component versions
  let hasChanged1 = haveMajorComponentsChanged("1.2.3.4", "1.2.4") // Should return true (y component changed)
  let hasChanged2 = haveMajorComponentsChanged("1.2.3.4", "1.2.3") // Should return false (only z component changed)
  let hasChanged3 = haveMajorComponentsChanged("1.2.3.4", "2.0.0") //
  
  print("comparison results, \(comparisonResult1),\(comparisonResult2),\(comparisonResult3)")
  
  print("haschangec ",hasChanged1,hasChanged2,hasChanged3)
  
}
// Helper function to dismiss the keyboard
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}


func deleteFiles(at fileURLs: [URL]) {
    for fileURL in fileURLs {
        do {
            try FileManager.default.removeItem(at: fileURL)
            print("Successfully deleted file at: \(fileURL)")
        } catch {
            print("Failed to delete file at: \(fileURL). Error: \(error)")
        }
    }
}

func deleteAllState() {
  print("--> deleting saved state")
  deleteFiles(at: [AnsweredInfo.getAnsweredInfoFilePath(),
                   ChaMan.getchallengeStatusesFilePath(),
                   GameState.getGameStateFilePath(),
                   TopicInfo.getTopicInfoFilePath()
                  ])
}
extension  ChaMan {
 static func getchallengeStatusesFilePath() -> URL {
    return URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0], isDirectory: true).appendingPathComponent("challengeStatuses.json")
  }
}

extension String {
    /// Pads or truncates the string to the specified length.
    ///
    /// - Parameters:
    ///   - length: The target length for the string.
    ///   - padCharacter: The character to use for padding, default is a space.
    /// - Returns: The padded or truncated string.
    func paddedOrTruncated(toLength length: Int, withPadCharacter padCharacter: Character = " ") -> String {
        if self.count < length {
            // Pad the string
            return self + String(repeating: padCharacter, count: length - self.count)
        } else if self.count > length {
            // Truncate the string
            let endIndex = self.index(self.startIndex, offsetBy: length)
            return String(self[..<endIndex])
        } else {
            // The string is already of the desired length
            return self
        }
    }
}
// Function to truncate text to 30 characters
func truncatedText(_ text: String,count: Int ) -> String {
    if text.count > count {
        let index = text.index(text.startIndex, offsetBy: count)
        return String(text[..<index]) + "..."
    } else {
        return text
    }
}


func formatTimeInterval(_ interval: TimeInterval) -> String {
    let seconds = Int(interval) % 60
    return "\(seconds)"
}
func removeString(from array: [String], stringToRemove: String) -> [String] {
  var newArray = array
  if let index = newArray.firstIndex(of: stringToRemove) {
    newArray.remove(at: index)
  }
  return newArray
}
func removeStrings(from array: [String], stringsToRemove: [String]) -> [String] {
  var newArray = array
  for string in stringsToRemove {
    while let index = newArray.firstIndex(of: string) {
      newArray.remove(at: index)
    }
  }
  return newArray
}

func joinWithCommasAnd(_ array: [String]) -> String {
    guard !array.isEmpty else { return "" }
    
    if array.count == 1 {
        return array[0]
    } else if array.count == 2 {
        return "\(array[0]) and \(array[1])"
    } else {
        let allButLastTwo = array.dropLast(2).joined(separator: ", ")
        let lastTwo = "\(array[array.count - 2]) and \(array.last!)"
        return "\(allButLastTwo), \(lastTwo)"
    }
}
extension Array {
  /// Chunks the array into arrays with a maximum size
  func chunked(into size: Int) -> [[Element]] {
    stride(from: 0, to: count, by: size).map {
      Array(self[$0..<Swift.min($0 + size, count)])
    }
  }
}
enum AppIconProvider {
    static func appIcon(in bundle: Bundle = .main) -> String {
       // # 1
        guard let icons = bundle.object(forInfoDictionaryKey: "CFBundleIcons") as? [String: Any],
           //   # 2
              let primaryIcon = icons["CFBundlePrimaryIcon"] as? [String: Any],
            //  # 3
              let iconFiles = primaryIcon["CFBundleIconFiles"] as? [String],
           //   # 4
              let iconFileName = iconFiles.last else {
            print("Could not find icons in bundle")
          return ""
        }
        return iconFileName
    }
}

enum AppNameProvider {
    static func appName(in bundle: Bundle = .main) -> String {
        guard let x = bundle.object(forInfoDictionaryKey: "CFBundleName") as? String else {
            fatalError("CFBundleName missing from info dictionary")
        }
        return x
    }
}


func dumpAppStorage() {

  @AppStorage("elementWidth") var elementWidth = 100.0
  @AppStorage("shuffleUp")  var shuffleUp = true
  @AppStorage("fontsize")  var fontsize = 24.0
  @AppStorage("padding")  var padding = 2.0
  @AppStorage("border") var  border = 3.0
  
  
 // let t = gameState.topics.compactMap  {$0.isLive ? $0.topic : nil}
  
  print("Dump of AppStorage")
  print("================")

  print("elementWidth ",elementWidth)
  print("shuffleUp ",shuffleUp)
  print("fontsize ",fontsize)
  print("padding ",padding)
  print("border ",border)
  print("================")
}



// MARK: - ColorScheme

fileprivate extension Color {
#if os(macOS)
  typealias SystemColor = NSColor
#else
  typealias SystemColor = UIColor
#endif
  
  var colorComponents: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)? {
    var r: CGFloat = 0
    var g: CGFloat = 0
    var b: CGFloat = 0
    var a: CGFloat = 0
    
#if os(macOS)
    SystemColor(self).getRed(&r, green: &g, blue: &b, alpha: &a)
    // Note that non RGB color will raise an exception, that I don't now how to catch because it is an Objc exception.
#else
    guard SystemColor(self).getRed(&r, green: &g, blue: &b, alpha: &a) else {
      // Pay attention that the color should be convertible into RGB format
      // Colors using hue, saturation and brightness won't work
      return nil
    }
#endif
    
    return (r, g, b, a)
  }
}

extension Color: Codable {
  enum CodingKeys: String, CodingKey {
    case red, green, blue
  }
  
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let r = try container.decode(Double.self, forKey: .red)
    let g = try container.decode(Double.self, forKey: .green)
    let b = try container.decode(Double.self, forKey: .blue)
    
    self.init(red: r, green: g, blue: b)
  }
  
  public func encode(to encoder: Encoder) throws {
    guard let colorComponents = self.colorComponents else {
      return
    }
    
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(colorComponents.red, forKey: .red)
    try container.encode(colorComponents.green, forKey: .green)
    try container.encode(colorComponents.blue, forKey: .blue)
  }
}

// Helper function to calculate luminance
func calculateLuminance(red: CGFloat, green: CGFloat, blue: CGFloat) -> CGFloat {
    return 0.299 * red + 0.587 * green + 0.114 * blue
}

// Function with Color argument
func foregroundColorFrom( backgroundColor: Color) -> Color {
    // Convert Color to UIColor to extract components
    let uiColor = UIColor(backgroundColor)
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    var alpha: CGFloat = 0
    
    uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    
    // Use the helper function to calculate luminance
    let luminance = calculateLuminance(red: red, green: green, blue: blue)
    
    // Return either white or black based on luminance
    return luminance > 0.5 ? Color.black : Color.white
}

// Function with RGB values as arguments
func foregroundColorFrom( red: CGFloat, green: CGFloat, blue: CGFloat) -> Color {
    // Use the helper function to calculate luminance
    let luminance = calculateLuminance(red: red, green: green, blue: blue)
    
    // Return either white or black based on luminance
    return luminance > 0.5 ? Color.black : Color.white
}

/// Returns a specified number of random topics from a provided list.
func getRandomTopics(_ count: Int, from topics: [String]) -> [String] {
    let t =  Array(topics.shuffled().prefix(count))
  TSLog("Choosing \(count) random topics : \(t)")
  return t
}

