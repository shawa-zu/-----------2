# frozen_string_literal: true

module Card
  # トレーナーズカードの基底クラス
  class Trainer < Card
    attr_reader :effect

    def initialize(name:, kind:, effect: nil, rule_box: nil, tags: [])
      super(name: name, kind: :trainer, rule_box: rule_box, tags: tags)
      @trainer_kind = kind # :supporter, :goods, :tool, :stadium
      @effect = effect # Effect オブジェクト
    end

    def supporter?
      @trainer_kind == :supporter
    end

    def goods?
      @trainer_kind == :goods
    end

    def tool?
      @trainer_kind == :tool
    end

    def stadium?
      @trainer_kind == :stadium
    end
  end
end

