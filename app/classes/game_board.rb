module GameBoard
  class GameBoard
    def initialize(map, players)
      @hexes = Array.new(map.num_rows, Array.new(map.num_rows))
      map.hexes.each do |hex|
        @hexes[hex.pos_x][hex.pos_y] = hex
      end

      @edges = Array.new(map.num_rows*2+2, Array.new(map.num_rows*2+2))
      @vertices = Array.new(map.num_rows*2+2, Array.new(map.num_rows*2+2))
      players.each do |player|
        player.roads.each do |road|
          @edges[road.edge_x][road.edge_y] = road
        end
        player.settlements.each do |settlement|
          @vertices[settlement.vertex_x][settlement.vertex_y] = settlement
        end
      end
    end

    public
    def vertex_is_free_for_building?(x, y)
      vertex_is_on_board?(x, y) && !@vertices[x][y] && !get_vertices_adjacent_to_vertex(x, y).any?
    end

    private
    def hex_is_on_board?(x, y)
      x >= 0 && y >= 0 && x < @hexes.count && y < @hexes.count && @hexes[x][y]
    end
    
    def get_hexes_from_vertex(x, y)
      x_offset = x % 2
      y_offset = y % 2
      points = [[x-1, (y+x_offset)/2 -1], [x - (1-y_offset)*x_offset, (y-1)/2], [x, (y - x_offset)/2]]
      points.reject {|point| !hex_is_on_board?(point[0], point[1])}.collect{ |point| @hexes[point[0]][point[1]]}
    end

    def vertex_is_on_board?(x, y)
      x >= 0 && y >= 0 && x < @vertices.count && y < @vertices.count && get_hexes_from_vertex(x, y).count > 0
    end

    def get_vertices_adjacent_to_vertex(x, y)
      points = [[x, y+1], [x+1, y], [x-1, y]]
      points.reject{ |point| !vertex_is_on_board?(point[0], point[1])}.collect{|point| @vertices[point[0]][point[1]]}
    end
  end
end