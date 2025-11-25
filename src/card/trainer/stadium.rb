# frozen_string_literal: true

module Card
  # スタジアム
  class Stadium < Trainer
    def initialize(name:, effect: nil, rule_box: nil, tags: [])
      super(name: name, kind: :stadium, effect: effect, rule_box: rule_box, tags: tags)
    end
  end
end

