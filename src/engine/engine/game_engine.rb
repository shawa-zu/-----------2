# frozen_string_literal: true

module Engine
  module Engine
    # ゲームエンジン（UI統合）
    class GameEngine
      def initialize(game_state)
        @state = game_state
        @rule_set = Rule::RuleSet.new
        @logger = Logger.new
      end

      def start
        @logger.info("=== ポケモンカードゲーム開始 ===")
        @logger.info("プレイヤー1: #{@state.player1.name}")
        @logger.info("プレイヤー2: #{@state.player2.name}")
        @logger.info("")

        loop do
          winner = @state.check_win_condition
          if winner
            @logger.info("=== ゲーム終了 ===")
            @logger.info("#{winner.name}の勝利！")
            break
          end

          play_turn
          @state.next_turn
        end
      end

      private

      def play_turn
        player = @state.current_player
        opponent = @state.opponent

        @logger.info("")
        @logger.info("=== ターン #{@state.turn_number + 1} ===")
        @logger.info("#{player.name}のターン")
        @logger.info("")

        show_game_status(player, opponent)

        loop do
          action = show_action_menu(player)
          break if action == :end_turn

          case action
          when :retreat
            handle_retreat(player)
          when :use_hand_card
            handle_use_hand_card(player)
          when :attack
            handle_attack(player)
          when :ability
            handle_ability(player)
          when :stadium
            handle_stadium(player)
          end
        end
      end

      def show_game_status(player, opponent)
        @logger.info("--- #{player.name}の状態 ---")
        @logger.info("手札: #{player.hand.size}枚")
        @logger.info("デッキ: #{player.deck.size}枚")
        @logger.info("サイド: #{player.prize_count}枚")
        if player.board.active.empty?
          @logger.info("バトル場: なし")
        else
          active = player.board.active
          @logger.info("バトル場: #{active.card.name} (HP: #{active.hp_remaining}/#{active.card.hp}, ダメージ: #{active.damage})")
        end
        @logger.info("ベンチ: #{player.board.bench.size}枚")
        @logger.info("")

        @logger.info("--- #{opponent.name}の状態 ---")
        @logger.info("手札: #{opponent.hand.size}枚")
        @logger.info("デッキ: #{opponent.deck.size}枚")
        @logger.info("サイド: #{opponent.prize_count}枚")
        if opponent.board.active.empty?
          @logger.info("バトル場: なし")
        else
          active = opponent.board.active
          @logger.info("バトル場: #{active.card.name} (HP: #{active.hp_remaining}/#{active.card.hp}, ダメージ: #{active.damage})")
        end
        @logger.info("ベンチ: #{opponent.board.bench.size}枚")
        @logger.info("")
      end

      def show_action_menu(player)
        @logger.info("--- 行動を選択してください ---")
        @logger.info("1. 逃げる") if @rule_set.can_retreat?(player, @state)
        @logger.info("2. 手札のカードを使う")
        @logger.info("3. 攻撃する") if @rule_set.can_attack?(player, @state)
        @logger.info("4. 特性を使う") if !player.board.active.empty? && player.board.active.can_use_ability?
        @logger.info("5. スタジアムを使う")
        @logger.info("6. ターン終了")
        @logger.info("")

        print "選択: "
        choice = gets.chomp.to_i

        case choice
        when 1
          @rule_set.can_retreat?(player, @state) ? :retreat : show_action_menu(player)
        when 2
          :use_hand_card
        when 3
          @rule_set.can_attack?(player, @state) ? :attack : show_action_menu(player)
        when 4
          (!player.board.active.empty? && player.board.active.can_use_ability?) ? :ability : show_action_menu(player)
        when 5
          :stadium
        when 6
          :end_turn
        else
          @logger.warn("無効な選択です")
          show_action_menu(player)
        end
      end

      def handle_retreat(player)
        unless @rule_set.can_retreat?(player, @state)
          @logger.warn("逃げることはできません")
          return
        end

        if player.board.bench.empty?
          @logger.warn("ベンチにポケモンがいません")
          return
        end

        @logger.info("ベンチからポケモンを選択してください")
        player.board.bench.slots.each_with_index do |slot, i|
          next if slot.empty?
          @logger.info("#{i + 1}. #{slot.card.name}")
        end

        print "選択: "
        index = gets.chomp.to_i - 1

        if index >= 0 && index < player.board.bench.size
          if player.board.retreat(index, player.hand)
            @logger.info("逃げました")
          else
            @logger.warn("逃げることができません")
          end
        else
          @logger.warn("無効な選択です")
        end
      end

      def handle_use_hand_card(player)
        sorted = player.hand.sorted_cards

        if sorted.empty?
          @logger.warn("手札が空です")
          return
        end

        @logger.info("--- 手札からカードを選択してください ---")
        sorted.each_with_index do |card, i|
          type_label = case card
                       when Card::Monster
                         "[ポケモン] #{card.name} (HP: #{card.hp})"
                       when Card::Supporter
                         "[サポート] #{card.name}"
                       when Card::Goods
                         "[グッズ] #{card.name}"
                       when Card::Tool
                         "[どうぐ] #{card.name}"
                       when Card::Stadium
                         "[スタジアム] #{card.name}"
                       when Card::Energy
                         "[エネルギー] #{card.name}"
                       else
                         card.name
                       end
          @logger.info("#{i + 1}. #{type_label}")
        end
        @logger.info("#{sorted.size + 1}. キャンセル")
        @logger.info("")

        print "選択: "
        choice = gets.chomp.to_i - 1

        if choice < 0 || choice >= sorted.size
          return
        end

        card = sorted[choice]
        handle_card_play(player, card)
      end

      def handle_card_play(player, card)
        case card
        when Card::Monster
          handle_play_monster(player, card)
        when Card::Supporter
          handle_play_supporter(player, card)
        when Card::Goods
          handle_play_goods(player, card)
        when Card::Energy
          handle_play_energy(player, card)
        when Card::Tool
          handle_play_tool(player, card)
        when Card::Stadium
          handle_play_stadium(player, card)
        end
      end

      def handle_play_monster(player, card)
        if card.basic?
          if player.board.active.empty?
            @logger.info("#{card.name}をバトル場に出しますか？ (y/n)")
            if gets.chomp.downcase == 'y'
              player.board.set_active(card)
              player.hand.remove(card)
              @logger.info("#{card.name}をバトル場に出しました")
            end
          else
            @logger.info("ベンチに出すか、進化させますか？")
            @logger.info("1. ベンチに出す")
            @logger.info("2. 進化させる")
            @logger.info("3. キャンセル")

            choice = gets.chomp.to_i
            case choice
            when 1
              if player.board.bench.full?
                @logger.warn("ベンチが満杯です")
              else
                player.board.bench.add(card)
                player.hand.remove(card)
                @logger.info("#{card.name}をベンチに出しました")
              end
            when 2
              handle_evolve(player, card)
            end
          end
        else
          handle_evolve(player, card)
        end
      end

      def handle_evolve(player, card)
        @logger.info("進化させるポケモンを選択してください")
        @logger.info("1. バトル場")
        player.board.bench.slots.each_with_index do |slot, i|
          next if slot.empty?
          @logger.info("#{i + 2}. ベンチ#{i + 1}: #{slot.card.name}")
        end

        choice = gets.chomp.to_i
        is_active = (choice == 1)

        if is_active
          slot = player.board.active
          bench_index = nil
        else
          bench_index = choice - 2
          slot = player.board.bench.get(bench_index)
        end

        if slot && @rule_set.can_evolve?(slot, card, @state)
          player.board.evolve(to_active: is_active, bench_index: bench_index, new_card: card)
          player.hand.remove(card)
          @logger.info("#{slot.card.name}に進化しました")
        else
          @logger.warn("進化できません")
        end
      end

      def handle_play_supporter(player, card)
        unless @rule_set.can_play_supporter?(player, @state)
          @logger.warn("サポートは1ターンに1枚までです")
          return
        end

        if card.effect
          card.effect.execute(player, @state)
          @logger.info("#{card.name}を使用しました")
        end

        player.used_supporter = true
        player.hand.remove(card)
        player.board.trash.add(card)
      end

      def handle_play_goods(player, card)
        unless @rule_set.can_play_goods?(player, @state)
          @logger.warn("グッズを使えません")
          return
        end

        if card.effect
          card.effect.execute(player, @state)
          @logger.info("#{card.name}を使用しました")
        end

        player.hand.remove(card)
        player.board.trash.add(card)
      end

      def handle_play_energy(player, card)
        unless @rule_set.can_attach_energy?(player, @state)
          @logger.warn("エネルギーは1ターンに1枚まで付けられます")
          return
        end

        @logger.info("エネルギーを付けるポケモンを選択してください")
        @logger.info("1. バトル場")
        player.board.bench.slots.each_with_index do |slot, i|
          next if slot.empty?
          @logger.info("#{i + 2}. ベンチ#{i + 1}: #{slot.card.name}")
        end

        choice = gets.chomp.to_i
        is_active = (choice == 1)

        if is_active
          player.board.attach_energy(to_active: true, energy_card: card)
        else
          bench_index = choice - 2
          player.board.attach_energy(to_active: false, bench_index: bench_index, energy_card: card)
        end

        player.energy_attached_this_turn = true
        player.hand.remove(card)
        @logger.info("#{card.name}を付けました")
      end

      def handle_play_tool(player, card)
        # どうぐの実装は後で
        @logger.info("どうぐの実装は後で追加します")
      end

      def handle_play_stadium(player, card)
        # スタジアムの実装は後で
        @logger.info("スタジアムの実装は後で追加します")
      end

      def handle_attack(player)
        unless @rule_set.can_attack?(player, @state)
          @logger.warn("攻撃できません")
          return
        end

        active = player.board.active
        if active.empty? || active.card.attacks.empty?
          @logger.warn("攻撃がありません")
          return
        end

        @logger.info("--- 攻撃を選択してください ---")
        active.card.attacks.each_with_index do |attack, i|
          @logger.info("#{i + 1}. #{attack[:name]} (ダメージ: #{attack[:damage] || 0})")
        end

        choice = gets.chomp.to_i - 1
        if choice >= 0 && choice < active.card.attacks.size
          attack = active.card.attacks[choice]
          @logger.info("#{attack[:name]}を使用しました")

          # 簡易版：ダメージ処理は後で実装
          opponent = @state.opponent
          if !opponent.board.active.empty?
            damage = attack[:damage] || 0
            opponent.board.active.add_damage(damage)
            @logger.info("#{opponent.board.active.card.name}に#{damage}ダメージ！")

            if opponent.board.active.knocked_out?
              @logger.info("#{opponent.board.active.card.name}は気絶しました")
              prize = player.take_prize
              if prize
                player.hand.add(prize)
                @logger.info("サイドを1枚獲得しました")
              end
              # 気絶したポケモンをトラッシュへ
              ko_card = opponent.board.active.card
              opponent.board.trash.add(ko_card)
              opponent.board.clear_active
            end
          end
        else
          @logger.warn("無効な選択です")
        end
      end

      def handle_ability(player)
        @logger.info("特性の実装は後で追加します")
      end

      def handle_stadium(player)
        @logger.info("スタジアムの実装は後で追加します")
      end
    end
  end
end

