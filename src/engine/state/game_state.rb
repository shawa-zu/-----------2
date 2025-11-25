# frozen_string_literal: true

module Engine
  module State
    # ゲーム状態
    class GameState
      attr_reader :player1, :player2, :turn_number
      attr_accessor :current_player_index

      def initialize(player1:, player2:)
        @player1 = player1
        @player2 = player2
        @current_player_index = 0 # 0: player1, 1: player2
        @turn_number = 0
      end

      def current_player
        @current_player_index == 0 ? @player1 : @player2
      end

      def opponent
        @current_player_index == 0 ? @player2 : @player1
      end

      def first_turn?
        @turn_number <= 1
      end

      def next_turn
        @current_player_index = (@current_player_index + 1) % 2
        @turn_number += 1
        current_player.reset_turn_flags
      end

      def check_win_condition
        # 簡易版：サイドが0枚になったら勝利
        return @player1 if @player1.prize_count == 0
        return @player2 if @player2.prize_count == 0

        # デッキ切れ
        return @player1 if @player2.deck.empty? && @player2.hand.empty?
        return @player2 if @player1.deck.empty? && @player1.hand.empty?

        nil
      end
    end
  end
end

