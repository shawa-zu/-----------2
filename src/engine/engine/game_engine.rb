# frozen_string_literal: true

module Engine
  module Engine
    # 本物のポケカルールに準拠したCLIゲームエンジン
    class GameEngine
      def initialize(game_state)
        @state = game_state
        @rule_set = Rule::RuleSet.new
        @logger = Logger.new
      end

      def start
        @logger.info('=== ポケモンカードゲーム開始 ===')
        setup_game
        @state.current_player.reset_turn_flags

        loop do
          winner = @state.check_win_condition
          break announce_winner(winner) if winner

          play_turn
          winner = @state.check_win_condition
          break announce_winner(winner) if winner

          @state.next_turn
        end
      end

      private

      def play_turn
        player = @state.current_player
        opponent = @state.opponent

        @logger.info('')
        @logger.info("=== ターン #{@state.turn_number} ===")
        @logger.info("#{player.name}のターン")
        @logger.info('')

        return if draw_phase(player)

        show_game_status(player, opponent)
        main_phase_loop(player)
        pokemon_check
      end

      # --- セットアップ関連 ---
      def setup_game
        @logger.info('=== セットアップ開始 ===')
        starting_index = choose_starting_player
        players.each(&:shuffle_deck)
        players.each_with_index do |player, idx|
          opponent = players[(idx + 1) % 2]
          perform_mulligan(player, opponent)
        end
        handle_mulligan_bonus_draws
        players.each { |player| select_active_and_bench(player) }
        players.each(&:place_prizes)
        @state.start_game(starting_index)
        @logger.info('=== セットアップ完了 ===')
      end

      def choose_starting_player
        @logger.info('先攻プレイヤーを選択してください (1: プレイヤー1, 2: プレイヤー2, その他: ランダム)')
        print '選択: '
        choice = gets.chomp.to_i
        return 0 if choice == 1
        return 1 if choice == 2

        rand(2)
      end

      def players
        [@state.player1, @state.player2]
      end

      def perform_mulligan(player, opponent)
        loop do
          player.draw_to_hand(7)
          if player.hand.has_basic?
            @logger.info("#{player.name}はたねポケモンを確保")
            break
          end

          player.mulligan_count += 1
          @logger.warn("#{player.name}はマリガン！ (#{player.mulligan_count}回目)")
          reveal_hand(player)
          player.return_hand_to_deck
        end
      end

      def reveal_hand(player)
        @logger.info("#{player.name}の手札を公開:")
        player.hand.each { |card| @logger.info(" - #{card.name}") }
      end

      def handle_mulligan_bonus_draws
        players.each do |player|
          opponent = @state.opponent_of(player)
          next if opponent.mulligan_count.zero?

          max_draw = opponent.mulligan_count
          @logger.info("#{opponent.name}のマリガン#{max_draw}回につき追加で何枚引きますか？ (0〜#{max_draw})")
          draw_count = prompt_integer(0, max_draw)
          cards = player.draw_cards(draw_count)
          @logger.info("#{player.name}は追加で#{cards.size}枚ドローした")
        end
      end

      def select_active_and_bench(player)
        basics = player.basic_pokemon_in_hand
        if basics.empty?
          @logger.error("#{player.name}はたねポケモンを持っていません。ゲームを終了します。")
          exit(1)
        end

        @logger.info("#{player.name}のアクティブポケモンを選択してください")
        active_card = prompt_select_card(basics)
        player.hand.remove(active_card)
        player.board.activate(active_card, turn_number: 0)
        @logger.info("#{active_card.name}をバトル場に置きました")

        loop do
          remaining = player.basic_pokemon_in_hand
          break if remaining.empty? || player.board.bench.full?
          break unless prompt_yes_no("#{player.name}はベンチにたねポケモンを追加しますか？ (y/n)")

          @logger.info('ベンチに出すポケモンを選択してください')
          bench_card = prompt_select_card(remaining)
          player.hand.remove(bench_card)
          player.board.place_on_bench(bench_card, turn_number: 0)
          @logger.info("#{bench_card.name}をベンチに置きました")
        end
      end

      # --- ターン進行 ---
      def draw_phase(player)
        @logger.info('--- ドローフェイズ ---')
        drawn = player.draw_cards(1)
        if drawn.empty?
          @logger.warn("#{player.name}は山札を引けず敗北しました")
          @state.mark_winner(@state.opponent_of(player))
          true
        else
          @logger.info("#{player.name}は#{drawn.first.name}をドロー")
          false
        end
      end

      def main_phase_loop(player)
        loop do
          action = show_action_menu(player)
          case action
          when :retreat
            handle_retreat(player)
          when :use_hand_card
            handle_use_hand_card(player)
          when :attack
            handle_attack(player)
            break
          when :end_turn
            break
          end
          break if @state.winner
        end
      end

      def show_game_status(player, opponent)
        @logger.info("--- #{player.name}の状態 ---")
        @logger.info("手札: #{player.hand.size}枚")
        @logger.info("デッキ: #{player.deck.size}枚")
        @logger.info("サイド: #{player.prize_count}枚")
        if player.board.active.empty?
          @logger.info('バトル場: なし')
        else
          active = player.board.active
          @logger.info("バトル場: #{active.card.name} (残りHP: #{active.hp_remaining}/#{active.card.hp})")
        end
        @logger.info("ベンチ: #{player.board.bench.size}枚")
        @logger.info('')

        @logger.info("--- #{opponent.name}の状態 ---")
        @logger.info("手札: #{opponent.hand.size}枚")
        @logger.info("デッキ: #{opponent.deck.size}枚")
        @logger.info("サイド: #{opponent.prize_count}枚")
        if opponent.board.active.empty?
          @logger.info('バトル場: なし')
        else
          active = opponent.board.active
          @logger.info("バトル場: #{active.card.name} (残りHP: #{active.hp_remaining}/#{active.card.hp})")
        end
        @logger.info("ベンチ: #{opponent.board.bench.size}枚")
        @logger.info('')
      end

      def show_action_menu(player)
        actions = []
        actions << :retreat if @rule_set.can_retreat?(player, @state)
        actions << :use_hand_card
        actions << :attack if @rule_set.can_attack?(player, @state)
        actions << :end_turn

        loop do
          @logger.info('--- 行動を選択してください ---')
          actions.each_with_index do |action, index|
            label = case action
                    when :retreat then '逃げる'
                    when :use_hand_card then '手札のカードを使う'
                    when :attack then '攻撃する'
                    when :end_turn then 'ターン終了'
                    end
            @logger.info("#{index + 1}. #{label}")
          end
          @logger.info('')

          print '選択: '
          choice = gets.chomp.to_i
          selected = actions[choice - 1]
          return selected if selected

          @logger.warn('無効な選択です')
        end
      end

      # --- 行動処理 ---
      def handle_retreat(player)
        unless @rule_set.can_retreat?(player, @state)
          @logger.warn('逃げることはできません')
          return
        end

        @logger.info('入れ替えるベンチポケモンを選択してください')
        player.board.bench.slots.each_with_index do |slot, index|
          next if slot.empty?

          @logger.info("#{index + 1}. #{slot.card.name}")
        end
        print '選択: '
        index = gets.chomp.to_i - 1
        unless index.between?(0, player.board.bench.size - 1)
          @logger.warn('無効な選択です')
          return
        end

        retreat_cost = player.board.active.card.retreat_cost
        if player.board.retreat(index, energy_to_discard: retreat_cost)
          player.retreated_this_turn = true
          @logger.info('逃げました')
        else
          @logger.warn('逃げることができません')
        end
      end

      def handle_use_hand_card(player)
        sorted = player.hand.sorted_cards
        if sorted.empty?
          @logger.warn('手札が空です')
          return
        end

        @logger.info('--- 手札からカードを選択してください ---')
        sorted.each_with_index do |card, index|
          type_label = case card
                       when Card::Monster then "[ポケモン] #{card.name}"
                       when Card::Supporter then "[サポート] #{card.name}"
                       when Card::Goods then "[グッズ] #{card.name}"
                       when Card::Tool then "[どうぐ] #{card.name}"
                       when Card::Stadium then "[スタジアム] #{card.name}"
                       when Card::Energy then "[エネルギー] #{card.name}"
                       else
                         card.name
                       end
          @logger.info("#{index + 1}. #{type_label}")
        end
        @logger.info("#{sorted.size + 1}. キャンセル")
        print '選択: '
        choice = gets.chomp.to_i - 1
        return if choice.negative? || choice >= sorted.size

        card = sorted[choice]
        handle_card_play(player, card)
      end

      def handle_card_play(player, card)
        case card
        when Card::Monster
          handle_monster_card(player, card)
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
        else
          @logger.warn('このカードはまだ対応していません')
        end
      end

      def handle_monster_card(player, card)
        if card.basic?
          if player.board.active_empty?
            player.board.activate(card, turn_number: @state.turn_number)
            player.hand.remove(card)
            @logger.info("#{card.name}をバトル場に出しました")
            return
          end

          if player.board.place_on_bench(card, turn_number: @state.turn_number)
            player.hand.remove(card)
            @logger.info("#{card.name}をベンチに出しました")
          else
            @logger.warn('ベンチが満杯です')
          end
        else
          handle_evolution(player, card)
        end
      end

      def handle_evolution(player, card)
        options = []
        options << { slot: player.board.active, label: 'バトル場' } unless player.board.active.empty?
        player.board.bench.slots.each_with_index do |slot, index|
          next if slot.empty?
          options << { slot: slot, label: "ベンチ#{index + 1}" }
        end

        if options.empty?
          @logger.warn('進化させるポケモンがいません')
          return
        end

        @logger.info('進化させるポケモンを選択してください')
        options.each_with_index do |option, idx|
          @logger.info("#{idx + 1}. #{option[:label]}: #{option[:slot].card.name}")
        end
        print '選択: '
        choice = gets.chomp.to_i - 1
        return unless choice.between?(0, options.size - 1)

        slot = options[choice][:slot]
        unless @rule_set.can_evolve?(player, slot, card, @state)
          @logger.warn('進化条件を満たしていません')
          return
        end

        is_active = slot == player.board.active
        bench_index = is_active ? nil : player.board.bench.slots.index(slot)
        player.board.evolve(
          to_active: is_active,
          bench_index: bench_index,
          new_card: card,
          turn_number: @state.turn_number
        )
        player.hand.remove(card)
        @logger.info("#{slot.card.name}に進化しました")
      end

      def handle_play_supporter(player, card)
        unless @rule_set.can_play_supporter?(player, @state)
          @logger.warn('サポートは1ターンに1枚までです（先攻1ターン目は不可）')
          return
        end

        card.effect&.execute(player, @state)
        player.used_supporter = true
        player.hand.remove(card)
        player.board.trash.add(card)
        @logger.info("#{card.name}を使用しトラッシュしました")
      end

      def handle_play_goods(player, card)
        card.effect&.execute(player, @state)
        player.hand.remove(card)
        player.board.trash.add(card)
        @logger.info("#{card.name}を使用しトラッシュしました")
      end

      def handle_play_energy(player, card)
        unless @rule_set.can_attach_energy?(player, @state)
          @logger.warn('エネルギーは1ターンに1枚までです')
          return
        end

        targets = []
        targets << { slot: player.board.active, label: 'バトル場' } unless player.board.active.empty?
        player.board.bench.slots.each_with_index do |slot, index|
          next if slot.empty?
          targets << { slot: slot, label: "ベンチ#{index + 1}" }
        end

        if targets.empty?
          @logger.warn('エネルギーを付けられるポケモンがいません')
          return
        end

        targets.each_with_index do |target, idx|
          @logger.info("#{idx + 1}. #{target[:label]}: #{target[:slot].card.name}")
        end
        print '選択: '
        choice = gets.chomp.to_i - 1
        return unless choice.between?(0, targets.size - 1)

        target = targets[choice]
        is_active = target[:slot] == player.board.active
        bench_index = is_active ? nil : player.board.bench.slots.index(target[:slot])

        player.board.attach_energy(
          to_active: is_active,
          bench_index: bench_index,
          energy_card: card
        )
        player.energy_attached_this_turn = true
        player.hand.remove(card)
        @logger.info("#{card.name}を付けました")
      end

      def handle_play_tool(_player, _card)
        @logger.warn('ポケモンのどうぐは未実装です')
      end

      def handle_play_stadium(_player, _card)
        @logger.warn('スタジアムは未実装です')
      end

      def handle_attack(player)
        unless @rule_set.can_attack?(player, @state)
          @logger.warn('攻撃できません')
          return
        end

        active = player.board.active
        if active.empty? || active.card.attacks.empty?
          @logger.warn('攻撃がありません')
          return
        end

        @logger.info('--- 攻撃を選択してください ---')
        active.card.attacks.each_with_index do |attack, idx|
          cost = (attack[:cost] || []).map(&:to_s).join(',')
          @logger.info("#{idx + 1}. #{attack[:name]} | コスト: #{cost} | ダメージ: #{attack[:damage] || 0}")
        end
        print '選択: '
        choice = gets.chomp.to_i - 1
        return unless choice.between?(0, active.card.attacks.size - 1)

        attack = active.card.attacks[choice]
        unless @rule_set.meets_attack_cost?(active, attack)
          @logger.warn('必要なエネルギーが不足しています')
          return
        end

        opponent = @state.opponent
        damage = attack[:damage] || 0
        opponent.board.active.add_damage(damage)
        @logger.info("#{attack[:name]}！ #{opponent.board.active.card.name}に#{damage}ダメージ")
        resolve_knockouts(opponent, player)
      end

      # --- 勝敗処理 ---
      def resolve_knockouts(defender, attacker)
        slot = defender.board.active
        return if slot.empty? || !slot.knocked_out?

        @logger.info("#{slot.card.name}はきぜつした")
        defender.board.move_slot_to_trash(slot)

        prize = attacker.take_prize
        if prize
          attacker.hand.add(prize)
          @logger.info("#{attacker.name}はサイドを1枚獲得した")
        end

        if defender.board.bench.empty?
          @logger.warn("#{defender.name}の場にポケモンがいません")
          @state.mark_winner(attacker)
          return
        end

        promote_new_active(defender)
      end

      def promote_new_active(player)
        @logger.info("#{player.name}の新しいアクティブを選択してください")
        player.board.bench.slots.each_with_index do |slot, index|
          next if slot.empty?
          @logger.info("#{index + 1}. #{slot.card.name}")
        end
        print '選択: '
        choice = gets.chomp.to_i - 1
        unless choice.between?(0, player.board.bench.size - 1)
          @logger.warn('無効な選択です')
          return promote_new_active(player)
        end

        unless player.board.promote_from_bench(choice)
          @logger.warn('入れ替えに失敗しました')
          promote_new_active(player)
        end
      end

      def pokemon_check
        [@state.player1, @state.player2].each do |player|
          slot = player.board.active
          next if slot.empty?

          slot.end_of_turn_status_resolution(@logger)
          resolve_knockouts(player, @state.opponent_of(player))
          break if @state.winner
        end
      end

      def announce_winner(winner)
        return unless winner

        @logger.info('=== ゲーム終了 ===')
        @logger.info("#{winner.name}の勝利！")
      end

      # --- CLIユーティリティ ---
      def prompt_select_card(cards)
        cards.each_with_index do |card, idx|
          @logger.info("#{idx + 1}. #{card.name}")
        end
        print '選択: '
        choice = gets.chomp.to_i - 1
        return cards[choice] if choice.between?(0, cards.size - 1)

        @logger.warn('無効な選択です')
        prompt_select_card(cards)
      end

      def prompt_integer(min, max)
        print '入力: '
        value = gets.chomp.to_i
        return value if value.between?(min, max)

        @logger.warn('範囲外です')
        prompt_integer(min, max)
      end

      def prompt_yes_no(message)
        print "#{message} "
        answer = gets.chomp.downcase
        return true if %w[y yes].include?(answer)
        return false if %w[n no].include?(answer)

        @logger.warn('y か n を入力してください')
        prompt_yes_no(message)
      end
    end
  end
end

