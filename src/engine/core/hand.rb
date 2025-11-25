# frozen_string_literal: true

module Engine
  module Core
    # 手札
    class Hand
      attr_reader :cards

      def initialize(cards = [])
        @cards = cards.dup
      end

      def add(card)
        @cards << card
      end

      def remove(card)
        @cards.delete(card)
      end

      def sorted_cards
        # モンスター → サポート → グッズ → 道具 → スタジアム → エネルギーの順
        monsters = @cards.select(&:monster?)
        trainers = @cards.select(&:trainer?)
        energies = @cards.select(&:energy?)

        supporters = trainers.select(&:supporter?)
        goods = trainers.select(&:goods?)
        tools = trainers.select(&:tool?)
        stadiums = trainers.select(&:stadium?)

        monsters + supporters + goods + tools + stadiums + energies
      end

      def size
        @cards.size
      end

      def empty?
        @cards.empty?
      end
    end
  end
end

