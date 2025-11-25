# frozen_string_literal: true

module Card
  # どうぐ
  class Tool < Trainer
    def initialize(name:, effect: nil, rule_box: nil, tags: [])
      super(name: name, kind: :tool, effect: effect, rule_box: rule_box, tags: tags)
    end
  end
end

