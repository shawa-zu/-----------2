# frozen_string_literal: true

module Engine
  module Effect
    # ドロー効果
    class DrawEffect < Effect
      def initialize(count)
        @count = count
      end

      def execute(player, state)
        drawn = player.deck.draw(@count)
        drawn.each { |card| player.hand.add(card) }
        drawn.size
      end
    end
  end
end

