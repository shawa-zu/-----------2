# frozen_string_literal: true

module Card
  # サポート
  class Supporter < Trainer
    def initialize(name:, effect: nil, rule_box: nil, tags: [])
      super(name: name, kind: :supporter, effect: effect, rule_box: rule_box, tags: tags)
    end
  end
end

