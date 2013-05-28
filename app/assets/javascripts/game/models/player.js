SettlersOfCatan.Models.Player = Backbone.Model.extend({
   urlRoot: '/player',
   parse: function(response)
   {
      if(!_.has(this, 'development_cards'))
        this.development_cards = new SettlersOfCatan.Collections.DevelopmentCards(response.development_cards, {parse: true});
      else
        this.development_cards.reset(response.development_cards)
      delete response.development_cards;

      if(!_.has(this, 'settlements'))
        this.settlements = new SettlersOfCatan.Collections.Settlements(response.settlements, {parse: true});
      else
        this.settlements.reset(response.settlements)
      delete response.settlements;

      if(!_.has(this, 'roads'))
        this.roads = new SettlersOfCatan.Collections.Roads(response.roads, {parse: true});
      else
        this.roads.reset(response.roads)
      delete response.roads;

      if(_.has(response, 'resources'))
      {
        if(!_.has(this, 'development_cards'))
          this.resources = new SettlersOfCatan.Collections.Resources(response.resources, {parse: true});
        else
          this.resources.reset(response.resources)
        delete response.resources;
      }

      return response;
    }
});