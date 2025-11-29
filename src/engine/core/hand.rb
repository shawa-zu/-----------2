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
        @cards << card if card
      end

      def add_many(cards)
        Array(cards).each { |card| add(card) }
      end

      def remove(card)
        @cards.delete(card)
      end

      def clear
        @cards.clear
      end

      def select_monsters(&block)
        @cards.select { |card| card.is_a?(Card::Monster) && (block.nil? || block.call(card)) }
      end

      def basic_monsters
        select_monsters(&:basic?)
      end

      def has_basic?
        !basic_monsters.empty?
      end

      def delete_at(index)
        @cards.delete_at(index)
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

      def each(&block)
        @cards.each(&block)
      end
    end
  end
end

