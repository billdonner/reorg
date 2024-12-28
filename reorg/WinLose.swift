//
// This file is maintained in the mac app Winner, which has about 100 test cases for this vital code
// v 0.991

import Foundation

/// Represents the state of a game cell
//enum GameCellState: Codable {
//  case playedCorrectly
//  case playedIncorrectly
//  case unplayed
//  case blocked
//}
///// Represents a position in the matrix
//struct Coordinate: Hashable {
//  let row: Int
//  let col: Int
//}
 
/// Prints a matrix of `GameCellState` with winning path cells highlighted.
/// - Parameters:
///   - matrix: The game board represented as a 2D array of `GameCellState`.
///   - winningPath: A list of coordinates (row, col) that represent the winning path.
func printMatrix(_ matrix: [[GameCellState]], winningPath: [Coordinate]? = nil) {
    let winningSet = Set(winningPath ?? [])
    
    for (rowIndex, row) in matrix.enumerated() {
        let rowString = row.enumerated().map { colIndex, cell in
          if winningSet.contains(Coordinate(row: rowIndex, col: colIndex)) {
                return "W" // Highlight cells on the winning path
            }
            switch cell {
            case .unplayed:
                return "U"
            case .blocked:
                return "B"
            default:
                return " " // Unreachable in this context but kept for safety
            }
        }.joined(separator: " ")
        print(rowString)
    }
    print() // Add an empty line for spacing
}
func pm(s:String,m:[[GameCellState]])->String {
  printMatrix(m)
  return s
}
/// Determines if there is a valid winning path in the matrix and logs the path if it exists.
/// - Parameter matrix: The game board represented as a 2D array of `GameCellState`
/// - Returns: `true` if a winning path exists, otherwise `false`
/// Finds the actual winning path (if any) in the matrix
/// - Parameter matrix: The game board represented as a 2D array of `GameCellState`
/// - Returns: A tuple containing the winning path as a list of positions and a boolean indicating if a winning path exists/// Determines if there is a valid winning path in the matrix.
/// - Parameter matrix: The game board represented as a 2D array of `GameCellState`.
/// - Returns: `true` if a winning path exists, otherwise `false`.
func isWinningPath(in matrix: [[GameCellState]]) -> Bool {
    // Delegate to `winningPath` to determine if a winning path exists.
    let (_, pathExists) = winningPath(in: matrix)
    return pathExists
}

/// Finds the actual winning path (if any) in the matrix.
/// - Parameter matrix: The game board represented as a 2D array of `GameCellState`.
/// - Returns: A tuple containing:
///   - The winning path as a list of positions.
///   - A boolean indicating if a winning path exists.
func winningPath(in matrix: [[GameCellState]]) -> ([Coordinate], Bool) {
    let n = matrix.count
    guard n > 0 else { return ([], false) }

    // Define diagonals with start and end points
    let diagonals = [
        (start: Coordinate(row: 0, col: 0), end: Coordinate(row: n - 1, col: n - 1)),
        (start: Coordinate(row: 0, col: n - 1), end: Coordinate(row: n - 1, col: 0))
    ]

    // Directions for exploring neighbors (all 8 directions)
    let directions = [
        (0, 1), (1, 0), (0, -1), (-1, 0), (1, 1), (1, -1), (-1, 1), (-1, -1)
    ]

    /// Helper function to perform BFS
    func bfs(start: Coordinate, end: Coordinate) -> [Coordinate]? {
        var queue: [(Coordinate, [Coordinate])] = [(start, [start])]
        var visited: Set<Coordinate> = [start]

        while !queue.isEmpty {
            let (current, path) = queue.removeFirst()

            if current == end {
                return path
            }

            for direction in directions {
                let neighbor = Coordinate(
                    row: current.row + direction.0,
                    col: current.col + direction.1
                )

                if neighbor.row >= 0, neighbor.row < n, neighbor.col >= 0, neighbor.col < n,
                   !visited.contains(neighbor),
                   matrix[neighbor.row][neighbor.col] == .playedCorrectly {
                    visited.insert(neighbor)
                    queue.append((neighbor, path + [neighbor]))
                }
            }
        }

        return nil
    }

    // Check each diagonal
    for (start, end) in diagonals {
        if matrix[start.row][start.col] == .playedCorrectly, matrix[end.row][end.col] == .playedCorrectly {
            if let path = bfs(start: start, end: end) {
                return (path, true)
            }
        }
    }

    return ([], false)
}
/// Determines if a theoretical winning path is possible
/// - Parameter matrix: The game board represented as a 2D array of `GameCellState`
/// - Returns: `true` if a possible path exists, otherwise `false`
func isPossibleWinningPath(in matrix: [[GameCellState]]) -> Bool {
    let n = matrix.count
    guard n > 0 else { return false }

    // Check for losing conditions
    if hasLosingCornerCondition(in: matrix) {
        return false
    }

    // Define start and end points for diagonals
    let startPoints = [(0, 0), (0, n - 1)]
    let endPoints = [(n - 1, n - 1), (n - 1, 0)]
    let directions = [
        (0, 1), (1, 0), (0, -1), (-1, 0), (1, 1), (1, -1), (-1, 1), (-1, -1),
    ]

    /// Helper function to check if a cell is valid for traversal
    func isValidCell(_ row: Int, _ col: Int) -> Bool {
        return row >= 0 && row < n && col >= 0 && col < n &&
               matrix[row][col] != .blocked && matrix[row][col] != .playedIncorrectly
    }

    /// Breadth-first search to determine if a path exists
    func bfs(start: (Int, Int), end: (Int, Int)) -> Bool {
        var queue = [start]
        var visited = Set<String>()
        visited.insert("\(start.0),\(start.1)")

        while !queue.isEmpty {
            let (row, col) = queue.removeFirst()

            // Check if we've reached the end point
            if (row, col) == end {
                return true
            }

            // Explore neighbors
            for dir in directions {
                let newRow = row + dir.0
                let newCol = col + dir.1
                let key = "\(newRow),\(newCol)"

                if isValidCell(newRow, newCol), !visited.contains(key) {
                    queue.append((newRow, newCol))
                    visited.insert(key)
                }
            }
        }

        return false
    }

    // Check each diagonal separately
    for (start, end) in zip(startPoints, endPoints) {
        if isValidCell(start.0, start.1) && isValidCell(end.0, end.1) {
            if bfs(start: start, end: end) {
                return true
            }
        }
    }

    return false
}
/// Checks if there are conditions that would automatically result in a loss
/// - Parameter matrix: The game board represented as a 2D array of `GameCellState`
/// - Returns: `true` if losing conditions exist, otherwise `false`
func hasLosingCornerCondition(in matrix: [[GameCellState]]) -> Bool {
  let n = matrix.count
  guard n > 1 else { return false }

  // Check for incorrect corners on the same side
  let sameSideCorners = [
    (matrix[0][0], matrix[n - 1][0]),  // Left side
    (matrix[0][0], matrix[0][n - 1]),  // Top side
    (matrix[0][n - 1], matrix[n - 1][n - 1]),  // Right side
    (matrix[n - 1][0], matrix[n - 1][n - 1]),  // Bottom side
  ]

  for (corner1, corner2) in sameSideCorners {
    if corner1 == .playedIncorrectly && corner2 == .playedIncorrectly {
      return true
    }
  }

  return false
}

/// Determines if there is any potential path between diagonally opposite corners
/// - Parameter matrix: The game board represented as a 2D array of `GameCellState`
/// - Returns: `true` if a potential path exists, otherwise `false`
func hasPotentialPath(in matrix: [[GameCellState]]) -> Bool {
  let n = matrix.count
  guard n > 1 else { return false }

  let directions = [
    (0, 1), (1, 0), (0, -1), (-1, 0), (1, 1), (1, -1), (-1, 1), (-1, -1),
  ]
  let startPoints = [
    (Coordinate(row: 0, col: 0), Coordinate(row: n - 1, col: n - 1)),
    (Coordinate(row: 0, col: n - 1), Coordinate(row: n - 1, col: 0)),
  ]

  /// Depth-first search to check if a path exists
  func dfs(
    position: Coordinate, end: Coordinate, visited: inout Set<Coordinate>
  ) -> Bool {
    if position == end && matrix[position.row][position.col] == .playedCorrectly
    {
      return true
    }

    if visited.contains(position)
      || matrix[position.row][position.col] == .blocked
      || matrix[position.row][position.col] != .playedCorrectly
    {
      return false
    }

    visited.insert(position)

    for direction in directions {
      let newPosition = Coordinate(
        row: position.row + direction.0, col: position.col + direction.1)
      if newPosition.row >= 0, newPosition.row < n, newPosition.col >= 0,
        newPosition.col < n
      {
        if dfs(position: newPosition, end: end, visited: &visited) {
          return true
        }
      }
    }

    return false
  }

  for (start, end) in startPoints {
    var visited = Set<Coordinate>()
    if dfs(position: start, end: end, visited: &visited) {
      return true
    }
  }

  return false
}

/// Checks if a specific cell has adjacent neighbors in specified states
/// - Parameters:
///   - states: A set of cell states to check for
///   - matrix: The game board represented as a 2D array of `GameCellState`
///   - cell: The position of the cell to check
/// - Returns: `true` if there is an adjacent neighbor in one of the specified states, otherwise `false`
func hasAdjacentNeighbor(
  withStates states: Set<GameCellState>, in matrix: [[GameCellState]],
  for cell: Coordinate
) -> Bool {
  let n = matrix.count
  let directions = [
    (0, 1), (1, 0), (0, -1), (-1, 0), (1, 1), (1, -1), (-1, 1), (-1, -1),
  ]

  for direction in directions {
    let newRow = cell.row + direction.0
    let newCol = cell.col + direction.1
    if newRow >= 0, newRow < n, newCol >= 0, newCol < n {
      if states.contains(matrix[newRow][newCol])
        && matrix[newRow][newCol] != .blocked
      {
        return true
      }
    }
  }

  return false
}

/// Counts the number of possible moves in the matrix
/// - Parameter matrix: The game board represented as a 2D array of `GameCellState`
/// - Returns: The number of possible moves
func numberOfPossibleMoves(in matrix: [[GameCellState]]) -> Int {
  let n = matrix.count
  guard n > 0 else { return 0 }

  let directions = [
    (0, 1), (1, 0), (0, -1), (-1, 0), (1, 1), (1, -1), (-1, 1), (-1, -1),
  ]
  var possibleMoves = 0

  for row in 0..<n {
    for col in 0..<n where matrix[row][col] == .unplayed {
      for direction in directions {
        let newRow = row + direction.0
        let newCol = col + direction.1
        if newRow >= 0, newRow < n, newCol >= 0, newCol < n,
          matrix[newRow][newCol] == .playedCorrectly
        {
          possibleMoves += 1
          break
        }
      }
    }
  }

  return possibleMoves
}

/// Determines if a given cell is a corner cell.
/// - Parameters:
///   - row: The row index of the cell.
///   - col: The column index of the cell.
///   - size: The size of the square matrix.
/// - Returns: `true` if the cell is a corner cell, otherwise `false`.
func isCornerCell(row: Int, col: Int, size: Int) -> Bool {
    return (row == 0 && col == 0) ||                     // Top-left corner
           (row == 0 && col == size - 1) ||             // Top-right corner
           (row == size - 1 && col == 0) ||             // Bottom-left corner
           (row == size - 1 && col == size - 1)         // Bottom-right corner
}
/// Generates a random game board matrix with configurable constraints for blocked and unplayed cells.
///
/// ### Constraints:
/// 1. Blocked Cell Distribution:
///    a. Blocked cells should be distributed as evenly as possible with no clustering.
///    b. Blocked cells must not be vertically or horizontally adjacent, but diagonal adjacency is allowed.
/// 2. Fallback for Placement Constraints:
///    a. If strict adherence to constraints is not possible due to high `blockedPercentage`, allow slight adjacency violations.
/// 3. Blocked Percentage:
///    a. The percentage of blocked cells must not exceed 60% of the matrix.
/// 4. Edge and Corner Constraints:
///    a. Corners must never be blocked.
///    b. Each corner must have at least two adjacent `unplayed` cells.
/// 5. Randomization:
///    a. Fully random placement is fine (does not need reproducibility via seeding).
/// 6. Local Restrictions:
///    a. A single row or column can have at most 50% blocked cells.
///    b. No more than 40% of the cells on a diagonal can be blocked.
///
/// - Parameters:
///   - size: The size of the square matrix (e.g., 4 for a 4x4 matrix).
///   - configuration: A `MatrixConfiguration` struct containing the rules for blocked cells.
/// - Returns: A 2D array of `GameCellState`.
///
///
func generateRandomMatrix(size: Int, configuration: MatrixConfiguration) -> [[GameCellState]] {
    guard size > 0 else { return [] }
    guard configuration.maxBlockedPercentage >= configuration.minBlockedPercentage,
          configuration.maxBlockedPercentage <= 100 else {
        fatalError("Invalid blocked percentage configuration. Ensure 0 <= minBlockedPercentage <= maxBlockedPercentage <= 100.")
    }

    let totalCells = size * size
    let maxBlockedCells = Int(round(Double(totalCells * configuration.maxBlockedPercentage) / 100.0))
    let minBlockedCells = Int(round(Double(totalCells * configuration.minBlockedPercentage) / 100.0))
    let maxBlockedPerRowCol = (size * configuration.maxBlockedPerRowCol) / 100
    let maxBlockedPerDiagonal = (size * configuration.maxBlockedPerDiagonal) / 100
    let maxAdjacentBlockedCells = (totalCells * configuration.maxAdjacentBlockedPercentage) / 100

    var matrix = Array(repeating: Array(repeating: GameCellState.unplayed, count: size), count: size)
    var blockedCount = 0
    var adjacentBlockedCount = 0

    /// Helper function to validate blocked cell placement
    func isValidBlockedPlacement(row: Int, col: Int) -> Bool {
        if isCornerCell(row: row, col: col, size: size) { return false }

        // Limit blocked cells per row/column
        let rowBlocked = matrix[row].filter { $0 == .blocked }.count
        let colBlocked = (0..<size).filter { matrix[$0][col] == .blocked }.count
        if rowBlocked >= maxBlockedPerRowCol || colBlocked >= maxBlockedPerRowCol {
            return false
        }

        // Limit blocked cells on diagonals
        if row == col || row + col == size - 1 {
            let diagonalBlocked = (0..<size).filter { matrix[$0][$0] == .blocked }.count
            let antiDiagonalBlocked = (0..<size).filter { matrix[$0][size - 1 - $0] == .blocked }.count
            if (row == col && diagonalBlocked >= maxBlockedPerDiagonal) ||
                (row + col == size - 1 && antiDiagonalBlocked >= maxBlockedPerDiagonal) {
                return false
            }
        }

        // Check adjacency constraints for larger boards
        let neighbors = [
            (row - 1, col), (row + 1, col), (row, col - 1), (row, col + 1)
        ]
        var adjacentBlocked = 0
        for (r, c) in neighbors {
            if r >= 0 && r < size && c >= 0 && c < size && matrix[r][c] == .blocked {
                adjacentBlocked += 1
            }
        }
        if size > 3 && adjacentBlockedCount + adjacentBlocked > maxAdjacentBlockedCells {
            return false
        }

        return true
    }

    /// Adjust corners to ensure compliance with adjacency rules
    func adjustCorners() {
        let corners = [
            (0, 0),                  // Top-left corner
            (0, size - 1),           // Top-right corner
            (size - 1, 0),           // Bottom-left corner
            (size - 1, size - 1)     // Bottom-right corner
        ]
        let directions = [
            (-1, -1), (-1, 0), (-1, 1),
            (0, -1),         (0, 1),
            (1, -1), (1, 0), (1, 1)
        ]

        for corner in corners {
            let (row, col) = corner
            let adjacentCells = directions.map { (dr, dc) in
                (row + dr, col + dc)
            }.filter { r, c in
                r >= 0 && r < size && c >= 0 && c < size
            }

            let unplayedNeighbors = adjacentCells.filter {
                matrix[$0.0][$0.1] == .unplayed
            }

            // Ensure at least two adjacent unplayed cells
            if unplayedNeighbors.count < configuration.cornersRequireAdjacentUnplayed {
                for neighbor in adjacentCells {
                    if matrix[neighbor.0][neighbor.1] == .blocked {
                        matrix[neighbor.0][neighbor.1] = .unplayed
                    }
                    if unplayedNeighbors.count >= configuration.cornersRequireAdjacentUnplayed {
                        break
                    }
                }
            }
        }
    }

    // Populate the matrix with blocked cells while adhering to constraints
    var validCells = [(Int, Int)]()
    for row in 0..<size {
        for col in 0..<size {
            validCells.append((row, col))
        }
    }
    validCells.shuffle()

    for (row, col) in validCells {
        if blockedCount >= maxBlockedCells { break }
        if isValidBlockedPlacement(row: row, col: col) {
            matrix[row][col] = .blocked
            blockedCount += 1

            // Count adjacent blocked cells for larger boards
            if size > 3 {
                let neighbors = [
                    (row - 1, col), (row + 1, col), (row, col - 1), (row, col + 1)
                ]
                for (r, c) in neighbors {
                    if r >= 0 && r < size && c >= 0 && c < size && matrix[r][c] == .blocked {
                        adjacentBlockedCount += 1
                    }
                }
            }
        }
    }

    // If fewer than minBlockedCells, add more blocked cells even if constraints are slightly violated
    validCells.shuffle()
    while blockedCount < minBlockedCells {
        if let (row, col) = validCells.popLast() {
            matrix[row][col] = .blocked
            blockedCount += 1
        }
    }

    // Ensure corner adjustments after placement
    adjustCorners()

    return matrix
}


/// Ensures that each corner cell has at least one adjacent `unplayed` cell.
/// - Parameters:
///   - corners: Indices of corner cells.
///   - flatMatrix: The flat matrix array of `GameCellState`.
///   - size: The size of the square matrix.
private func ensureAdjacentUnplayedCells(forCorners corners: [Int], in flatMatrix: inout [GameCellState], size: Int) {
    let totalCells = size * size

    for corner in corners {
        // Determine the adjacent cells based on the corner's position
        let adjacentIndices: [Int] = {
            switch corner {
            case 0: // Top-left corner
                return [1, size]
            case size - 1: // Top-right corner
                return [size - 2, 2 * size - 1]
            case totalCells - size: // Bottom-left corner
                return [totalCells - 2 * size, totalCells - size + 1]
            case totalCells - 1: // Bottom-right corner
                return [totalCells - size - 1, totalCells - 2]
            default:
                return []
            }
        }()

        // Ensure at least one adjacent cell is unplayed
        if !adjacentIndices.contains(where: { flatMatrix[$0] == .unplayed }) {
            // If all adjacent cells are blocked, unblock one randomly
            if let randomBlockedIndex = adjacentIndices.first(where: { flatMatrix[$0] == .blocked }) {
                flatMatrix[randomBlockedIndex] = .unplayed
            }
        }
    }
}
