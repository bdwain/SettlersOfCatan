window.SettlersOfCatan = {
  Models: {},
  Collections: {},
  Views: {},
  initialize: function() {
    this.game = new this.Models.Game($("#game_container").data("game"), {parse: true});
  }
};

$(document).ready(function(){
  SettlersOfCatan.initialize();
});
