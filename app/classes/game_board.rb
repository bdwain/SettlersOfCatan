module GameBoard
  class GameBoard
    def initialize(map, players)
      @hexes = Array.new(map.num_rows) {Array.new(map.num_rows)}
      map.hexes.each do |hex|
        @hexes[hex.pos_x][hex.pos_y] = hex
      end

      @edges = Array.new(map.num_rows*2+2) {Array.new(map.num_rows*2+2)}
      @vertices = Array.new(map.num_rows*2+2) {Array.new(map.num_rows*2+2)}
      players.each do |player|
        player.roads.each do |road|
          @edges[road.edge_x][road.edge_y] = Edge.new(road.edge_x, road.edge_y, road)
        end
        player.settlements.each do |settlement|
          @vertices[settlement.vertex_x][settlement.vertex_y] = Vertex.new(settlement.vertex_x, settlement.vertex_y, settlement)
        end
      end

      @edges.each_with_index do |row, x|
        row.each_with_index do |edge, y|
          @edges[x][y] = Edge.new(x, y, nil) unless edge
        end
      end

      @vertices.each_with_index do |row, x|
        row.each_with_index do |vertex, y|
          @vertices[x][y] = Vertex.new(x, y, nil) unless vertex
        end
      end
    end

    public
    def vertex_is_free_for_building?(x, y)
      vertex_is_on_board?(x, y) && @vertices[x][y].empty? && get_vertices_adjacent_to_vertex(@vertices[x][y]).all?{|vertex| vertex.empty?}
    end

    def edge_is_free_for_building_by_player?(x, y, player)
      edge_is_on_board?(x, y) && @edges[x][y].empty? && edge_is_connected_to_player?(@edges[x][y], player)
    end

    def get_hexes_from_vertex(x,y)
      x_offset = x % 2
      y_offset = y % 2
      points = [[x-1, (y+x_offset)/2 -1], [x - (1-y_offset)*x_offset, (y-1)/2], [x, (y - x_offset)/2]]
      points.uniq.reject {|point| !hex_is_on_board?(point[0], point[1])}.collect{ |point| @hexes[point[0]][point[1]]}
    end

    private
    class Edge
      def initialize(x, y, road)
        self.x = x
        self.y = y
        self.road = road
      end
      attr_accessor :x, :y, :road

      def empty?
        !road
      end
    end

    class Vertex
      def initialize(x, y, settlement)
        self.x = x
        self.y = y
        self.settlement = settlement
      end
      attr_accessor :x, :y, :settlement

      def empty?
        !settlement
      end
    end

    def hex_is_on_board?(x, y)
      x >= 0 && y >= 0 && x < @hexes.count && y < @hexes.count && @hexes[x][y]
    end

    def vertex_is_on_board?(x, y)
      x >= 0 && y >= 0 && x < @vertices.count && y < @vertices.count && get_hexes_from_vertex(x,y).count > 0
    end

    def edge_is_on_board?(x, y)
      x >= 0 && y >= 0 && x < @edges.count && y < @edges.count && get_vertices_attached_to_edge(@edges[x][y]).count == 2
    end

    def get_vertices_adjacent_to_vertex(vertex)
      x = vertex.x
      y = vertex.y
      points = [[x, y+1], [x+1, y], [x-1, y]]
      points.uniq.reject{ |point| !vertex_is_on_board?(point[0], point[1])}.collect{|point| @vertices[point[0]][point[1]]}
    end

    def get_vertices_attached_to_edge(edge)
      x = edge.x
      y = edge.y
      if x % 2 == 0
        points = [[x/2, y], [x/2, y+1]]
      else
        points = [[(x-1)/2, y], [(x+1)/2,y]]
      end
      points.uniq.reject{ |point| !vertex_is_on_board?(point[0], point[1])}.collect{|point| @vertices[point[0]][point[1]]}
    end

    def get_edges_from_vertex(vertex)
      x = vertex.x
      y = vertex.y
      points = [[x*2, y], [x*2+1, y], [x*2-1, y]]
      points.uniq.reject{ |point| !edge_is_on_board?(point[0], point[1])}.collect{|point| @edges[point[0]][point[1]]}
    end

    def edge_is_connected_to_player?(edge, player)
      vertices = get_vertices_attached_to_edge(edge)
      vertices.any?{|vertex| (!vertex.empty? && vertex.settlement.player == player) || (vertex.empty? && get_edges_from_vertex(vertex).any?{|connectedEdge| connectedEdge != edge && !connectedEdge.empty? && connectedEdge.road.player == player})}
    end
  end
end