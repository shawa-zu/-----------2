# frozen_string_literal: true

module Engine
  module Core
    module Board
      # トラッシュ
      class Trash
        attr_reader :cards

        def initialize
          @cards = []
        end

        def add(card)
          @cards << card
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
end

