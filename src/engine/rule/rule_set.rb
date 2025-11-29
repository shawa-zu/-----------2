# frozen_string_literal: true

module Engine
  module Rule
    # ルール判定クラス（YES/NO判定のみ）
    class RuleSet
      def can_attack?(player, state)
        return false if player.board.active.empty?
        return false unless player.board.active.can_attack?
        return false if state.player_first_turn?(player) && state.starting_player?(player)

        true
      end

      def can_play_supporter?(player, state)
        return false if player.used_supporter
        return false if state.player_first_turn?(player) && state.starting_player?(player)

        true
      end

      def can_attach_energy?(player, _state)
        !player.energy_attached_this_turn
      end

      def can_evolve?(player, slot, card, state)
        return false if slot.nil? || slot.empty?
        return false unless card.monster?

        current_card = slot.card
        return false unless current_card.monster?
        return false if state.player_first_turn?(player)
        return false if slot.came_into_play_this_turn?(state.turn_number)
        return false if slot.evolved_this_turn?(state.turn_number)

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

      def can_retreat?(player, _state)
        return false if player.board.active.empty?
        return false if player.board.active.status == :paralyzed
        return false if player.retreated_this_turn
        return false if player.board.bench.empty?

        active = player.board.active
        retreat_cost = active.card.retreat_cost
        energy_count = active.energies.size
        energy_count >= retreat_cost
      end

      def can_play_goods?(_player, _state)
        true
      end

      def can_play_tool?(_player, _state)
        true
      end

      def can_play_stadium?(_player, _state)
        true
      end

      def meets_attack_cost?(slot, attack)
        slot.meets_cost?(attack[:cost])
      end
    end
  end
end

