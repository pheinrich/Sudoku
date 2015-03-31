#  Sudoku
#  Copyright (c) 2012,2015  Peter Heinrich
#
#  This program is free software; you can redistribute it and/or
#  modify it under the terms of the GNU General Public License
#  as published by the Free Software Foundation; either version 2
#  of the License, or (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin Street, Boston, MA  02110-1301, USA.
# 
class Sudoku
  DIGITS = [*1..9]

  # Determine which values are missing from each row, column, and subsquare.
  def self.constraints( grid )
    r, c, s = [], [], []
  
    (0...9).each do |i| 
      r[i] = DIGITS - grid[i]
      c[i] = DIGITS - grid.map {|row| row[i]}
      s[i] = DIGITS - grid.map {|row| row[i%3 * 3, 3]}[i/3 * 3, 3].flatten
    end
  
    return r, c, s
  end

  # Return a solved version of the puzzle provided, or nil if it is not
  # solvable. The puzzle parameter is a an array of rows with 9 entries each.
  # Here's a simple example.
  #
  #   irb(main):004:0> puzzle = [[0, 0, 5, 0, 8, 0, 7, 0, 0],
  #   irb(main):005:1* [7, 0, 0, 2, 0, 4, 0, 0, 5],
  #   irb(main):006:1* [3, 2, 0, 0, 0, 0, 0, 8, 4],
  #   irb(main):007:1* [0, 6, 0, 1, 0, 5, 0, 4, 0],
  #   irb(main):008:1* [0, 0, 8, 0, 0, 0, 5, 0, 0],
  #   irb(main):009:1* [0, 7, 0, 8, 0, 3, 0, 1, 0],
  #   irb(main):010:1* [4, 5, 0, 0, 0, 0, 0, 9, 1],
  #   irb(main):011:1* [6, 0, 0, 5, 0, 8, 0, 0, 7],
  #   irb(main):012:1* [0, 0, 3, 0, 1, 0, 6, 0, 0]]
  #   => [[0, 0, 5, 0, 8, 0, 7, 0, 0], [7, 0, 0, 2, 0, 4, 0, 0, 5], [3, 2, 0, 0, 0, 0, 0, 8, 4], [0, 6, 0, 1, 0, 5, 0, 4, 0], [0, 0, 8, 0, 0, 0, 5, 0, 0], [0, 7, 0, 8, 0, 3, 0, 1, 0], [4, 5, 0, 0, 0, 0, 0, 9, 1], [6, 0, 0, 5, 0, 8, 0, 0, 7], [0, 0, 3, 0, 1, 0, 6, 0, 0]]
  #   irb(main):013:0> Sudoku.solve(puzzle)
  #   => [[9, 4, 5, 6, 8, 1, 7, 2, 3], [7, 8, 1, 2, 3, 4, 9, 6, 5], [3, 2, 6, 7, 5, 9, 1, 8, 4], [2, 6, 9, 1, 7, 5, 3, 4, 8], [1, 3, 8, 9, 4, 2, 5, 7, 6], [5, 7, 4, 8, 6, 3, 2, 1, 9], [4, 5, 7, 3, 2, 6, 8, 9, 1], [6, 1, 2, 5, 9, 8, 4, 3, 7], [8, 9, 3, 4, 1, 7, 6, 5, 2]]
  #   irb(main):014:0>
  #
  # Splitting a flat array is straightforward:
  #
  #   puzzle = [0,0,1,0,0,7,0,9,0,5,9,0,0,8,0,0,0,1,0,3,0,0,0,0,0,8,0,0,0,0,0,0,5,8,0,0,0,5,0,0,6,0,0,2,0,0,0,4,1,0,0,0,0,0,0,8,0,0,0,0,0,3,0,1,0,0,0,2,0,0,7,9,0,2,0,7,0,0,4,0,0]
  #   solved = Sudoku.solve(puzzle.each_slice(9).to_a)
  #
  def self.solve( puzzle )
    grid = puzzle.map( &:dup )

    # Substitute values as long as there are empty squares.
    while 0 < grid.flatten.count( 0 )
      r, c, s = constraints( grid )
      min, x, y = DIGITS, 0, 0
  
      # Look at each blank square in the grid and determine which values would
      # be valid there. 
      (0...9).each do |i|
        (0...9).each do |j|
          next unless 0 == grid[j][i]
  
          # Only values that are missing from the corresponding row, column,
          # and subsquare are valid.  This may be more than one number, or
          # none.  If none, the puzzle isn't solvable.
          vals = r[j] & c[i] & s[j/3 * 3 + i/3]
          return nil if 0 == vals.count

          # If exactly one number is valid here, hooray.  Go ahead and insert
          # it, then recompute the constraints.
          if 1 == vals.count
            grid[j][i] = vals[0]
            r, c, s = constraints( grid )
          end

          # Chances are (for difficult puzzles), there will be no single
          # choices.  Keep track of the first space with the fewest options
          # for later guessing.
          min, x, y = vals, i, j if vals.count < min.count
        end
      end

      # If there were no "easy wins" above, we must pick a square and insert
      # each of its candidate values in turn, looking for one that leads to a
      # solution.  
      if 1 < min.count
        guess = nil

        # Substitute each candidate value for the chosen square and solve.
        for v in min
          grid[y][x] = v

          # Since this grid isn't solvable, recursively try the next value.
          # One of them must work (if any solution exists at all).
          guess = solve( grid )
          break if guess
        end

        # Return the solution, or nil if this path was a dead end.  In that
        # case, we'll end up backtracking in order to try a different branch.
        return guess
      end
    end

    grid
  end
end
