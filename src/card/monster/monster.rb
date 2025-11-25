# frozen_string_literal: true

module Card
  # ポケモンカードの基底クラス
  class Monster < Card
    attr_reader :hp, :types, :stage, :evolves_from, :retreat_cost, :weakness, :resistance, :attacks

    def initialize(name:, hp:, types:, stage:, evolves_from:, retreat_cost:, weakness:, resistance:, attacks:, rule_box: nil, tags: [])
      super(name: name, kind: :monster, rule_box: rule_box, tags: tags)
      @hp = hp
      @types = types # 配列 [:grass, :fire] など
      @stage = stage # :basic, :stage1, :stage2
      @evolves_from = evolves_from # 進化元の名前（Symbol）
      @retreat_cost = retreat_cost
      @weakness = weakness # { type: :fire, multiplier: 2 } など
      @resistance = resistance # { type: :psychic, value: -30 } など
      @attacks = attacks # [{ name: "つつく", cost: [], damage: 10, effect: nil }]
    end

    def basic?
      @stage == :basic
    end

    def stage1?
      @stage == :stage1
    end

    def stage2?
      @stage == :stage2
    end
  end
end

