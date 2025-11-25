# frozen_string_literal: true

module Engine
  module Rule
    # ルール判定クラス（YES/NO判定のみ）
    class RuleSet
      def can_attack?(player, state)
        return false if player.board.active.empty?
        return false unless player.board.active.can_attack?
        return false if state.first_turn? && state.current_player == player

        true
      end

      def can_play_supporter?(player, state)
        return false if player.used_supporter
        return false if state.first_turn? && state.current_player == player

        true
      end

      def can_attach_energy?(player, state)
        return false if player.energy_attached_this_turn
        return false if state.first_turn? && state.current_player == player

        true
      end

      def can_evolve?(slot, card, state)
        return false if slot.empty?
        return false unless card.monster?
        return false if state.first_turn? && state.current_player_index == 0

        current_card = slot.card
        return false unless current_card.monster?

        # 進化段階のチェック
        stage_order = { basic: 0, stage1: 1, stage2: 2 }
        current_stage_value = stage_order[current_card.stage] || -1
        new_stage_value = stage_order[card.stage] || -1
        return false if current_stage_value >= new_stage_value

        case card.stage
        when :stage1
          current_card.basic? && current_card.name.to_s == card.evolves_from.to_s
        when :stage2
          current_card.stage1? && current_card.name.to_s == card.evolves_from.to_s
        else
          false
        end
      end

      def can_retreat?(player, state)
        return false if player.board.active.empty?
        return false if player.board.active.status == :paralyzed

        active = player.board.active
        retreat_cost = active.card.retreat_cost
        return true if retreat_cost == 0

        # 必要なエネルギーをチェック（簡易版：エネルギーの数だけチェック）
        energy_count = active.energies.size
        energy_count >= retreat_cost
      end

      def can_play_goods?(player, state)
        # グッズは基本的にいつでも使える（先行1ターン目も可）
        true
      end

      def can_play_tool?(player, state)
        # どうぐは基本的にいつでも使える
        true
      end

      def can_play_stadium?(player, state)
        # スタジアムは基本的にいつでも使える
        true
      end
    end
  end
end

