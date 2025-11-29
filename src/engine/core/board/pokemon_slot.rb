# frozen_string_literal: true

module Engine
  module Core
    module Board
      # ポケモンスロット（バトル場・ベンチ共通）
      class PokemonSlot
        attr_accessor :card, :energies, :damage, :status, :entered_turn, :last_evolved_turn

        def initialize(card = nil)
          @card = card
          @energies = []
          @damage = 0
          @status = nil # :poisoned, :burned, :asleep, :paralyzed, :confused
          @entered_turn = nil
          @last_evolved_turn = nil
        end

        def empty?
          @card.nil?
        end

        def attach_energy(energy_card)
          @energies << energy_card
        end

        def can_attack?
          return false if empty?
          return false if @status == :asleep || @status == :paralyzed

          true
        end

        def can_use_ability?
          return false if empty?
          return false if @status == :asleep || @status == :paralyzed

          true
        end

        def add_damage(amount)
          @damage += amount
        end

        def heal(amount)
          return if empty?

          @damage = [@damage - amount, 0].max
        end

        def set_status(new_status)
          @status = new_status
        end

        def clear_status
          @status = nil
        end

        def hp_remaining
          return 0 if empty?
          [@card.hp - @damage, 0].max
        end

        def knocked_out?
          return false if empty?
          hp_remaining <= 0
        end

        def evolve(new_card, current_turn)
          @card = new_card
          @last_evolved_turn = current_turn
        end

        def mark_entered(turn_number)
          @entered_turn = turn_number
        end

        def came_into_play_this_turn?(current_turn)
          return false if @entered_turn.nil?

          @entered_turn == current_turn
        end

        def evolved_this_turn?(current_turn)
          return false if @last_evolved_turn.nil?

          @last_evolved_turn == current_turn
        end

        def remove_energies(count)
          removed = @energies.shift(count)
          removed.compact
        end

        def total_energy_count
          hash = Hash.new(0)
          @energies.each { |energy| hash[energy.type] += 1 }
          hash
        end

        def meets_cost?(cost)
          return true if cost.nil? || cost.empty?
          return false if empty?

          counts = total_energy_count
          colorless_available = counts.values.sum
          cost.each do |symbol|
            if symbol == :colorless
              colorless_available -= 1
              return false if colorless_available.negative?
            else
              if counts[symbol].positive?
                counts[symbol] -= 1
                colorless_available -= 1
              else
                return false
              end
            end
          end
          true
        end

        def end_of_turn_status_resolution(logger)
          return if empty? || @status.nil?

          case @status
          when :poisoned
            add_damage(10)
            logger.info("#{card.name}はどくで10ダメージを受けた")
          when :burned
            if rand(2).zero?
              add_damage(20)
              logger.info("#{card.name}はやけどで20ダメージを受けた")
            else
              logger.info("#{card.name}のやけどはダメージなし")
            end
          when :asleep
            if rand(2).zero?
              clear_status
              logger.info("#{card.name}はねむりから目を覚ました")
            else
              logger.info("#{card.name}はまだねむっている")
            end
          when :paralyzed
            clear_status
            logger.info("#{card.name}のまひが治った")
          end
        end

        def reset_turn_based_flags(turn_number)
          @entered_turn ||= turn_number
        end
      end
    end
  end
end

