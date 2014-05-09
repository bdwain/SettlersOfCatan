module GameBoard
  class GameBoard
    def initialize(map, players)
      @hexes = Array.new(map.num_rows) {Array.new(map.num_rows)}
      map.hexes.each do |hex|
        @hexes[hex.pos_x][hex.pos_y] = hex
      end

      @roads = Hash.new
      @settlements = Hash.new

      players.each do |player|
        player.roads.each do |road|
          @roads[[road.edge_x, road.edge_y, road.side]] = road
        end
        player.settlements.each do |settlement|
          @settlements[[settlement.vertex_x, settlement.vertex_y, settlement.side]] = settlement
        end
      end
    end

    #attr_accessor :hexes, :roads, :settlements #for debugging only

    public
    def vertex_is_free_for_building?(x, y, side)
      vertex_is_on_board?(x, y, side) && !@settlements.has_key?([x, y, side]) && 
        get_vertex_points_adjacent_to_vertex(x, y, side).all? {|point| !@settlements.has_key?(point)}
    end

    def edge_is_free_for_building_by_player?(x, y, side, player)
      edge_is_on_board?(x, y, side) && !@roads.has_key?([x, y, side]) && edge_is_connected_to_player?(x, y, side, player)
    end

    def get_hexes_from_vertex(x, y, side)
      if side == 0
        points = [[x, y], [x-1, y+1], [x, y+1]]
      else
        points = [[x, y], [x, y-1], [x+1, y-1]]
      end

      get_hexes_from_points(points)
    end

    def edge_is_connected_to_vertex?(edge_x, edge_y, edge_side, vertex_x, vertex_y, vertex_side)
      get_edge_points_from_vertex(vertex_x, vertex_y, vertex_side).include? [edge_x, edge_y, edge_side]
    end

    def get_settlements_touching_hex(x,y)
      get_vertex_points_touching_hex(x,y).reject{|point| !@settlements.has_key?(point)}.collect{|point| @settlements[point]}
    end

    def hex_is_on_board?(x, y)
      @hexes[x] && @hexes[x][y]
    end

    def vertex_is_connected_to_player?(x, y, side, player)
      get_edge_points_from_vertex(x, y, side).any?{|pt| @roads.has_key?(pt) && @roads[pt].player == player}
    end

    private
    def get_hexes_from_points(points)
      points.reject {|point| !hex_is_on_board?(point[0], point[1])}.collect{ |point| @hexes[point[0]][point[1]]}
    end

    def vertex_is_on_board?(x, y, side)
      get_hexes_from_vertex(x, y, side).count != 0
    end

    def edge_is_on_board?(x, y, side)
      get_hexes_from_edge(x, y, side).count != 0
    end

    def get_hexes_from_edge(x, y, side)
      if side == 0
        points = [[x, y], [x, y+1]]
      elsif side == 1
        points = [[x, y], [x+1, y]]
      else
        points = [[x, y], [x+1, y-1]]
      end

      get_hexes_from_points(points)
    end

    def get_vertex_points_touching_hex(x,y)
      [[x,y,0], [x,y,1], [x-1,y+1,1], [x,y-1,0], [x+1,y-1,0], [x,y+1,1]]
    end

    def get_vertex_points_adjacent_to_vertex(x, y, side)
      if side == 0
        points = [[x-1, y+2, 1], [x-1, y+1, 1], [x, y+1, 1]]
      else
        points = [[x, y-1, 0], [x+1, y-1, 0], [x+1, y-2, 0]]
      end

      points.reject{ |point| !vertex_is_on_board?(point[0], point[1], point[2])}
    end

    def get_vertex_points_attached_to_edge(x, y, side)
      if side == 0
        points = [[x, y, 0], [x, y+1, 1]]
      elsif side == 1
        points = [[x, y+1, 1], [x+1, y-1, 0]]
      else
        points = [[x+1, y-1, 0], [x, y, 1]]
      end

      points.reject{ |point| !vertex_is_on_board?(point[0], point[1], point[2])}
    end

    def get_edge_points_from_vertex(x, y, side)
      if side == 0
        points = [[x, y, 0], [x-1, y+1, 1], [x-1, y+1, 2]]
      else
        points = [[x, y, 2], [x, y-1, 0], [x, y-1, 1]]
      end

      points.reject{ |point| !edge_is_on_board?(point[0], point[1], point[2])}
    end

    def edge_is_connected_to_player?(x, y, side, player)
      points = get_vertex_points_attached_to_edge(x, y, side)
      points.any?{|vertexPoint| (@settlements.has_key?(vertexPoint) && @settlements[vertexPoint].player == player) || 
        (!@settlements.has_key?(vertexPoint) && get_edge_points_from_vertex(vertexPoint[0], vertexPoint[1], vertexPoint[2]).any?{|edgePoint| @roads.has_key?(edgePoint) && @roads[edgePoint].player == player})}
    end
  end
end