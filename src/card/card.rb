# frozen_string_literal: true

module Card
  # カードの抽象基底クラス
  class Card
    attr_reader :name, :kind, :rule_box, :tags

    def initialize(name:, kind:, rule_box: nil, tags: [])
      @name = name
      @kind = kind # :monster, :trainer, :energy
      @rule_box = rule_box # :ex, :gx, :v, :vmax など
      @tags = tags # [:ancient, :future, :tera] など
    end

    def monster?
      @kind == :monster
    end

    def trainer?
      @kind == :trainer
    end

    def energy?
      @kind == :energy
    end
  end
end

