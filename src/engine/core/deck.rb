# frozen_string_literal: true

module Engine
  module Core
    # デッキ
    class Deck
      attr_reader :cards

      def initialize(cards = [])
        @cards = cards.dup
        shuffle
      end

      def shuffle
        @cards.shuffle!
      end

      def draw(count = 1)
        drawn = @cards.shift(count)
        drawn.compact
      end

      def take_top
        draw(1).first
      end

      def return_and_shuffle(cards)
        return if cards.nil? || cards.empty?

        @cards.concat(cards)
        shuffle
      end

      def search(condition)
        # condition はブロックまたは条件オブジェクト
        found = @cards.find { |card| condition.call(card) if condition.respond_to?(:call) }
        if found
          @cards.delete(found)
          found
        else
          nil
        end
      end

      def size
        @cards.size
      end

      def empty?
        @cards.empty?
      end

      def add(card)
        @cards << card
      end

      def remove(card)
        @cards.delete(card)
      end
    end
  end
end

