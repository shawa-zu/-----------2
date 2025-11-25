# frozen_string_literal: true

module Card
  # 2進化ポケモン
  class Stage2 < Monster
    def initialize(name:, hp:, types:, evolves_from:, retreat_cost: 0, weakness: nil, resistance: nil, attacks: [], rule_box: nil, tags: [])
      super(
        name: name,
        hp: hp,
        types: types,
        stage: :stage2,
        evolves_from: evolves_from,
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

