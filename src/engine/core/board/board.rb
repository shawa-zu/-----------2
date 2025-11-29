# frozen_string_literal: true

module Engine
  module Core
    module Board
      # ボード（バトル場・ベンチ・トラッシュを管理）
      class Board
        attr_reader :active, :bench, :trash

        def initialize
          @active = BattleSpot.new
          @bench = Bench.new
          @trash = Trash.new
        end

        def activate(card, turn_number:)
          @active = BattleSpot.new(card)
          @active.mark_entered(turn_number)
        end

        def active_empty?
          @active.empty?
        end

        def attach_energy(to_active: true, bench_index: nil, energy_card:)
          if to_active
            @active.attach_energy(energy_card)
          elsif !bench_index.nil?
            slot = @bench.get(bench_index)
            slot&.attach_energy(energy_card)
          end
        end

        def evolve(to_active: true, bench_index: nil, new_card:, turn_number:)
          if to_active
            @active.evolve(new_card, turn_number)
          elsif !bench_index.nil?
            slot = @bench.get(bench_index)
            slot&.evolve(new_card, turn_number)
          end
        end

        def retreat(bench_index, energy_to_discard: 0)
          return false if @active.empty?
          return false if bench_index < 0 || bench_index >= @bench.size

          bench_slot = @bench.get(bench_index)
          return false if bench_slot&.empty?

          discarded = @active.remove_energies(energy_to_discard)
          discarded.each { |card| @trash.add(card) }

          swap_slots(@active, bench_slot)
          true
        end

        def promote_from_bench(bench_index)
          return false if bench_index.negative? || bench_index >= @bench.size

          bench_slot = @bench.get(bench_index)
          return false if bench_slot.nil? || bench_slot.empty?

          swap_slots(@active, bench_slot)
          @bench.remove_slot(bench_slot) if bench_slot.empty?
          true
        end

        def swap_slots(slot_a, slot_b)
          a_card = slot_a.card
          b_card = slot_b.card
          a_data = slot_metadata(slot_a)
          b_data = slot_metadata(slot_b)

          slot_a.card = b_card
          slot_a.energies = b_data[:energies]
          slot_a.damage = b_data[:damage]
          slot_a.status = b_data[:status]
          slot_a.entered_turn = b_data[:entered_turn]
          slot_a.last_evolved_turn = b_data[:last_evolved_turn]

          slot_b.card = a_card
          slot_b.energies = a_data[:energies]
          slot_b.damage = a_data[:damage]
          slot_b.status = a_data[:status]
          slot_b.entered_turn = a_data[:entered_turn]
          slot_b.last_evolved_turn = a_data[:last_evolved_turn]
        end

        def set_active(card)
          @active = BattleSpot.new(card)
        end

        def clear_active
          @active = BattleSpot.new
        end

        def place_on_bench(card, turn_number:)
          return false if @bench.full?

          slot = PokemonSlot.new(card)
          slot.mark_entered(turn_number)
          @bench.add_slot(slot)
          true
        end

        def any_pokemon?
          !@active.empty? || @bench.any?
        end

        def slots
          [@active, *@bench.slots]
        end

        def knockout_active
          return if @active.empty?

          move_slot_to_trash(@active)
          clear_active
        end

        def move_slot_to_trash(slot)
          return if slot.empty?

          @trash.add(slot.card)
          slot.energies.each { |energy| @trash.add(energy) }
          slot.card = nil
          slot.energies = []
          slot.damage = 0
          slot.status = nil
          slot.entered_turn = nil
          slot.last_evolved_turn = nil

          @bench.remove_slot(slot) if @bench.slots.include?(slot)
        end

        private

        def slot_metadata(slot)
          {
            energies: slot.energies.dup,
            damage: slot.damage,
            status: slot.status,
            entered_turn: slot.entered_turn,
            last_evolved_turn: slot.last_evolved_turn
          }
        end
      end
    end
  end
end

