# frozen_string_literal: true

module Engine
  module Effect
    # 攻撃効果（ダメージ計算のみ）
    class AttackEffect < Effect
      def initialize(base_damage:, additional_effects: [])
        @base_damage = base_damage
        @additional_effects = additional_effects
      end

      def execute(player, state)
        # 簡易版：ダメージ計算のみ（実際のダメージ処理は後で実装）
        opponent = state.opponent
        active = opponent.board.active

        return 0 if active.empty?

        damage = @base_damage
        # 追加効果の処理は後で実装

        damage
      end
    end
  end
end

