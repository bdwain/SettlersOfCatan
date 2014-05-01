#resource/hex types
RESOURCE_NAME_MAP = {0 => "DESERT", 1 => "WHEAT", 2 => "BRICK", 3 => "WOOD", 4 => "WOOL", 5 => "ORE"}

DESERT = RESOURCE_NAME_MAP.find{|k,v| v == "DESERT"}[0]
WHEAT = RESOURCE_NAME_MAP.find{|k,v| v == "WHEAT"}[0]
BRICK = RESOURCE_NAME_MAP.find{|k,v| v == "BRICK"}[0]
WOOD = RESOURCE_NAME_MAP.find{|k,v| v == "WOOD"}[0]
WOOL = RESOURCE_NAME_MAP.find{|k,v| v == "WOOL"}[0]
ORE = RESOURCE_NAME_MAP.find{|k,v| v == "ORE"}[0]

#development card types
KNIGHT = 1
VICTORY_POINT = 2
ROAD_BUILDING = 3
YEAR_OF_PLENTY = 4
MONOPOLY = 5

#player turn statuses
WAITING_FOR_TURN = 0
PLACING_INITIAL_SETTLEMENT = 1
PLACING_INITIAL_ROAD = 2
READY_TO_ROLL = 3
MOVING_ROBBER = 4
PLAYING_TURN = 5
WAITING_FOR_TRADE_RESPONSE = 6
CONSIDERING_TRADE = 7
DISCARDING_CARDS_DUE_TO_ROBBER = 8
CHOOSING_ROBBER_VICTIM = 9