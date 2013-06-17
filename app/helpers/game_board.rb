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
      player.settlements.each do |settlment|
        @vertices[settlment.vertex_x][settlment.vertex_y] = settlement
      end
    end
  end
end