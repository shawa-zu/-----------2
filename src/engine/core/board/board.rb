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

        def attach_energy(to_active: true, bench_index: nil, energy_card:)
          if to_active
            @active.attach_energy(energy_card)
          elsif bench_index
            slot = @bench.get(bench_index)
            slot&.attach_energy(energy_card)
          end
        end

        def evolve(to_active: true, bench_index: nil, new_card:)
          if to_active
            @active.evolve(new_card)
          elsif bench_index
            slot = @bench.get(bench_index)
            slot&.evolve(new_card)
          end
        end

        def retreat(bench_index, hand)
          # バトル場とベンチを入れ替え
          return false if @active.empty?
          return false if bench_index < 0 || bench_index >= @bench.size

          bench_slot = @bench.get(bench_index)
          return false if bench_slot&.empty?

          # 入れ替え
          active_card = @active.card
          bench_card = bench_slot.card
          active_energies = @active.energies.dup
          bench_energies = bench_slot.energies.dup
          active_damage = @active.damage
          bench_damage = bench_slot.damage
          active_status = @active.status
          bench_status = bench_slot.status

          @active.card = bench_card
          @active.energies = bench_energies
          @active.damage = bench_damage
          @active.status = bench_status

          bench_slot.card = active_card
          bench_slot.energies = active_energies
          bench_slot.damage = active_damage
          bench_slot.status = active_status

          true
        end

        def set_active(card)
          @active = BattleSpot.new(card)
        end

        def clear_active
          @active = BattleSpot.new
        end
      end
    end
  end
end

