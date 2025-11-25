# frozen_string_literal: true

module Card
  # グッズ
  class Goods < Trainer
    def initialize(name:, effect: nil, rule_box: nil, tags: [])
      super(name: name, kind: :goods, effect: effect, rule_box: rule_box, tags: tags)
    end
  end
end

