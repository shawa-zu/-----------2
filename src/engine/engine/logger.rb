# frozen_string_literal: true

module Engine
  module Engine
    # ロガー（コンソール出力のみ）
    class Logger
      def self.log(message)
        puts "[LOG] #{message}"
      end

      def self.info(message)
        puts "[INFO] #{message}"
      end

      def self.warn(message)
        puts "[WARN] #{message}"
      end

      def self.error(message)
        puts "[ERROR] #{message}"
      end

      def log(message)
        self.class.log(message)
      end

      def info(message)
        self.class.info(message)
      end

      def warn(message)
        self.class.warn(message)
      end

      def error(message)
        self.class.error(message)
      end
    end
  end
end

