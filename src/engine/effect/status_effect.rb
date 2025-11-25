# frozen_string_literal: true

module Engine
  module Effect
    # 状態異常効果
    class StatusEffect < Effect
      def initialize(status_type)
        @status_type = status_type # :poisoned, :burned, :asleep, :paralyzed, :confused
      end

      def execute(player, state)
        target = state.opponent.board.active
        return false if target.empty?

        target.set_status(@status_type)
        true
      end
    end
  end
end

