# frozen_string_literal: true

module Engine
  module State
    # プレイヤー
    class Player
      attr_reader :name, :deck, :hand, :board, :prize_cards
      attr_accessor :used_supporter, :energy_attached_this_turn, :retreated_this_turn,
                    :turns_taken, :mulligan_count

      def initialize(name:, deck_cards:)
        @name = name
        @deck = Core::Deck.new(deck_cards)
        @hand = Core::Hand.new
        @board = Core::Board::Board.new
        @prize_cards = []
        @used_supporter = false
        @energy_attached_this_turn = false
        @retreated_this_turn = false
        @turns_taken = 0
        @mulligan_count = 0
      end

      def shuffle_deck
        @deck.shuffle
      end

      def draw_cards(count)
        cards = @deck.draw(count)
        @hand.add_many(cards)
        cards
      end

      def draw_to_hand(count)
        draw_cards(count)
      end

      def take_from_deck(count)
        @deck.draw(count)
      end

      def return_hand_to_deck
        cards = @hand.cards.dup
        @hand.clear
        @deck.return_and_shuffle(cards)
      end

      def place_prizes
        @prize_cards = @deck.draw(6)
      end

      def take_prize
        return nil if @prize_cards.empty?

        @prize_cards.shift
      end

      def prize_count
        @prize_cards.size
      end

      def prizes_remaining?
        prize_count.positive?
      end

      def reset_turn_flags
        @used_supporter = false
        @energy_attached_this_turn = false
        @retreated_this_turn = false
      end

      def increment_turns_taken
        @turns_taken += 1
      end

      def has_any_pokemon?
        @board.any_pokemon?
      end

      def active_basic_present?
        !@board.active_empty?
      end

      def basic_pokemon_in_hand
        @hand.basic_monsters
      end

      def attach_energy_limit_reached?
        @energy_attached_this_turn
      end
    end
  end
end

