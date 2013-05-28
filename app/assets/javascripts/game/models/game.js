SettlersOfCatan.Models.Game = Backbone.Model.extend({
   urlRoot: '/game',
   parse: function(response)
   {
      if(!_.has(this, 'players'))
        this.players = new SettlersOfCatan.Collections.Players(response.players, {parse: true});
      else
        this.players.reset(response.players)
      delete response.players;
      
      return response;
   }
});