# frozen_string_literal: true

module Card
  # たねポケモン
  class Basic < Monster
    def initialize(name:, hp:, types:, retreat_cost: 0, weakness: nil, resistance: nil, attacks: [], rule_box: nil, tags: [])
      super(
        name: name,
        hp: hp,
        types: types,
        stage: :basic,
        evolves_from: nil,
        retreat_cost: retreat_cost,
        weakness: weakness,
        resistance: resistance,
        attacks: attacks,
        rule_box: rule_box,
        tags: tags
      )
    end
  end
end

