# frozen_string_literal: true

module Engine
  module State
    # ゲーム状態
    class GameState
      attr_reader :player1, :player2, :turn_number, :starting_player_index, :winner
      attr_accessor :current_player_index

      def initialize(player1:, player2:)
        @player1 = player1
        @player2 = player2
        @current_player_index = 0
        @turn_number = 0
        @starting_player_index = 0
        @winner = nil
      end

      def start_game(starting_index)
        @starting_player_index = starting_index
        @current_player_index = starting_index
        @turn_number = 1
      end

      def current_player
        @current_player_index.zero? ? @player1 : @player2
      end

      def opponent
        @current_player_index.zero? ? @player2 : @player1
      end

      def opponent_of(player)
        player.equal?(@player1) ? @player2 : @player1
      end

      def mark_winner(player)
        @winner = player
      end

      def starting_player?(player)
        (@starting_player_index.zero? && player.equal?(@player1)) ||
          (@starting_player_index == 1 && player.equal?(@player2))
      end

      def player_first_turn?(player)
        player.turns_taken.zero?
      end

      def next_turn
        current_player.increment_turns_taken
        @current_player_index = (@current_player_index + 1) % 2
        @turn_number += 1
        current_player.reset_turn_flags
      end

      def check_win_condition
        return @winner if @winner

        return @player1 if @player1.prize_count.zero?
        return @player2 if @player2.prize_count.zero?

        return @player1 unless @player2.has_any_pokemon?
        return @player2 unless @player1.has_any_pokemon?

        nil
      end
    end
  end
end

