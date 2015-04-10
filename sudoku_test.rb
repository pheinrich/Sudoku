require './sudoku.rb'

describe Sudoku do
  it "solves Sudoku puzzles" do; end

  before( :all ) do
    @puzzle = [[0, 0, 5, 0, 0, 0, 0, 0, 6],
               [0, 7, 0, 0, 0, 9, 0, 2, 0],
               [0, 0, 0, 5, 0, 0, 1, 0, 7],
               [8, 0, 4, 1, 5, 0, 0, 0, 0],
               [0, 0, 0, 8, 0, 3, 0, 0, 0],
               [0, 0, 0, 0, 9, 2, 8, 0, 5],
               [9, 0, 7, 0, 0, 6, 0, 0, 0],
               [0, 3, 0, 4, 0, 0, 0, 1, 0],
               [2, 0, 0, 0, 0, 0, 6, 0, 0]]
  end

  describe ".constraints" do
    it "find missing values for each each row, column, and subsquare" do
      r, c, s = Sudoku.constraints( @puzzle )
      
      expect( r.flatten.inject( :+ ) ).to eq( 272 )
      expect( c.flatten.count ).to eq( 55 )
      expect( s[2] ).to eq( [3, 4, 5, 8, 9] )
      expect( (r[3] & c[6] & s[5]) ).to eq( [2, 3, 7, 9] )
    end
  end

  describe ".solve" do
    it "fills in blank squares, or returns nil if impossible" do
      solved = Sudoku.solve( @puzzle )
      expect( solved ).to_not be_nil
      expect( solved[6] ).to eq( [9, 8, 7, 2, 1, 6, 4, 5, 3] )
      expect( solved.map {|row| row[3]} ).to eq( [7, 3, 5, 1, 8, 6, 2, 4, 9] )

      @puzzle[2][5] = 1
      expect( Sudoku.solve( @puzzle ) ).to be_nil
    end
  end
end
