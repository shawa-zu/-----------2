# frozen_string_literal: true

module Engine
  module Core
    module Board
      # ポケモンスロット（バトル場・ベンチ共通）
      class PokemonSlot
        attr_accessor :card, :energies, :damage, :status

        def initialize(card = nil)
          @card = card
          @energies = []
          @damage = 0
          @status = nil # :poisoned, :burned, :asleep, :paralyzed, :confused
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

        def evolve(new_card)
          @card = new_card
          # ダメージは引き継ぐ
          # エネルギーの扱いは後で実装
        end
      end
    end
  end
end

