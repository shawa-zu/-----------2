# frozen_string_literal: true

module Engine
  module State
    # プレイヤー
    class Player
      attr_reader :name, :deck, :hand, :board, :prize_cards
      attr_accessor :used_supporter, :energy_attached_this_turn

      def initialize(name:, deck_cards:)
        @name = name
        @deck = Core::Deck.new(deck_cards)
        @hand = Core::Hand.new
        @board = Core::Board::Board.new
        @prize_cards = []
        @used_supporter = false
        @energy_attached_this_turn = false

        # 初期化手順
        initialize_game
      end

      private

      def initialize_game
        # 1. デッキをシャッフル（Deck初期化時に実行済み）
        # 2. 初手7枚を引く
        7.times do
          card = @deck.draw(1).first
          @hand.add(card) if card
        end
        # 3. サイド6枚を置く
        6.times do
          card = @deck.draw(1).first
          @prize_cards << card if card
        end
        # 4. バトル場＆ベンチは空（Board初期化時に空）
        # 5. 使用制限フラグ初期化（初期化時に実行済み）
      end

      public

      def take_prize
        return nil if @prize_cards.empty?

        @prize_cards.shift
      end

      def prize_count
        @prize_cards.size
      end

      def reset_turn_flags
        @used_supporter = false
        @energy_attached_this_turn = false
      end
    end
  end
end

