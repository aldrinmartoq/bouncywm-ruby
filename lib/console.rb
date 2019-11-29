module Bouncy
  module Console
    def console
      Kernel.define_method :reload! do
        puts "======= reload! base: #{__dir__} ======="
        $LOADED_FEATURES.select { |feature| feature.start_with? __dir__ }.each do |feature|
          puts "   reload: #{load feature}\tpath: #{feature}"
        end
        nil
      end

      require 'pry'
      binding.pry # rubocop:disable Lint/Debugger
    end
  end
end
