# frozen_string_literal: true

module Engine
  module Core
    module Board
      # バトル場（アクティブポケモン）
      class BattleSpot < PokemonSlot
        def initialize(card = nil)
          super(card)
        end
      end
    end
  end
end

