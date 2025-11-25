# frozen_string_literal: true

module Engine
  module Effect
    # サーチ効果
    class SearchEffect < Effect
      def initialize(condition)
        @condition = condition # ブロックまたは条件オブジェクト
      end

      def execute(player, state)
        found = player.deck.search(@condition)
        if found
          player.hand.add(found)
          found
        else
          nil
        end
      end
    end
  end
end

