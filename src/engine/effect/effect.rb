# frozen_string_literal: true

module Engine
  module Effect
    # 効果の基底クラス
    class Effect
      def execute(player, state)
        # サブクラスで実装
        raise NotImplementedError
      end
    end
  end
end

