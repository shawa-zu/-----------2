# frozen_string_literal: true

module Card
  # 基本エネルギー
  class Energy < Card
    attr_reader :type

    def initialize(type:, name: nil, rule_box: nil, tags: [])
      energy_name = name || "#{type.to_s.capitalize}エネルギー"
      super(name: energy_name, kind: :energy, rule_box: rule_box, tags: tags)
      @type = type # :grass, :fire, :water, :lightning, :psychic, :fighting, :darkness, :metal, :colorless
    end

    # 将来特殊エネルギーを追加できる構造
    def basic?
      @rule_box.nil?
    end
  end
end

