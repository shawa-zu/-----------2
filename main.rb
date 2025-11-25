# frozen_string_literal: true

# 必要なファイルを読み込む
require_relative 'src/card/card'
require_relative 'src/card/monster/monster'
require_relative 'src/card/monster/basic'
require_relative 'src/card/monster/stage1'
require_relative 'src/card/monster/stage2'
require_relative 'src/card/trainer/trainer'
require_relative 'src/card/trainer/supporter'
require_relative 'src/card/trainer/goods'
require_relative 'src/card/trainer/tool'
require_relative 'src/card/trainer/stadium'
require_relative 'src/card/energy'

require_relative 'src/engine/core/deck'
require_relative 'src/engine/core/hand'
require_relative 'src/engine/core/board/trash'
require_relative 'src/engine/core/board/pokemon_slot'
require_relative 'src/engine/core/board/battle_spot'
require_relative 'src/engine/core/board/bench'
require_relative 'src/engine/core/board/board'

require_relative 'src/engine/state/player'
require_relative 'src/engine/state/game_state'

require_relative 'src/engine/rule/rule_set'

require_relative 'src/engine/effect/effect'
require_relative 'src/engine/effect/draw_effect'
require_relative 'src/engine/effect/search_effect'
require_relative 'src/engine/effect/attack_effect'
require_relative 'src/engine/effect/status_effect'

require_relative 'src/engine/engine/logger'
require_relative 'src/engine/engine/game_engine'

# 簡易デッキを作成
def create_simple_deck(name_prefix)
  deck = []

  # たねポケモン（20枚）
  10.times do |i|
    deck << Card::Basic.new(
      name: "#{name_prefix}ピカチュウ#{i + 1}",
      hp: 60,
      types: [:lightning],
      retreat_cost: 1,
      weakness: { type: :fighting, multiplier: 2 },
      attacks: [
        { name: "でんきショック", cost: [:lightning], damage: 20, effect: nil }
      ]
    )
  end

  10.times do |i|
    deck << Card::Basic.new(
      name: "#{name_prefix}フシギダネ#{i + 1}",
      hp: 50,
      types: [:grass],
      retreat_cost: 1,
      weakness: { type: :fire, multiplier: 2 },
      attacks: [
        { name: "つるのムチ", cost: [:grass], damage: 10, effect: nil }
      ]
    )
  end

  # サポート（10枚）
  5.times do
    deck << Card::Supporter.new(
      name: "ナンとママ",
      effect: Engine::Effect::DrawEffect.new(3)
    )
  end

  5.times do
    deck << Card::Supporter.new(
      name: "ポケモンいれかえ",
      effect: nil
    )
  end

  # グッズ（10枚）
  10.times do
    deck << Card::Goods.new(
      name: "モンスターボール",
      effect: Engine::Effect::SearchEffect.new(->(card) { card.monster? && card.basic? })
    )
  end

  # エネルギー（20枚）
  10.times do
    deck << Card::Energy.new(type: :lightning)
  end

  10.times do
    deck << Card::Energy.new(type: :grass)
  end

  deck
end

# メイン処理
def main
  puts "=== ポケモンカードゲームエンジン ==="
  puts ""

  # 2人分のデッキを作成
  deck1 = create_simple_deck("プレイヤー1")
  deck2 = create_simple_deck("プレイヤー2")

  # プレイヤーを作成
  player1 = Engine::State::Player.new(name: "プレイヤー1", deck_cards: deck1)
  player2 = Engine::State::Player.new(name: "プレイヤー2", deck_cards: deck2)

  # ゲーム状態を作成
  game_state = Engine::State::GameState.new(player1: player1, player2: player2)

  # ゲームエンジンを起動
  engine = Engine::Engine::GameEngine.new(game_state)
  engine.start
end

# 実行
main if __FILE__ == $PROGRAM_NAME

