# frozen_string_literal: true

module Engine
  module Core
    module Board
      # ベンチ（最大5枚）
      class Bench
        MAX_SIZE = 5

        attr_reader :slots

        def initialize
          @slots = []
        end

        def add(card)
          return false if full?

          slot = PokemonSlot.new(card)
          @slots << slot
          true
        end

        def remove(index)
          @slots.delete_at(index) if index >= 0 && index < @slots.size
        end

        def get(index)
          @slots[index] if index >= 0 && index < @slots.size
        end

        def full?
          @slots.size >= MAX_SIZE
        end

        def empty?
          @slots.empty?
        end

        def size
          @slots.size
        end
      end
    end
  end
end

