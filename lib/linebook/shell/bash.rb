require 'erb'

module Linebook
  module Shell
    module Bash
      def shell_path
        @shell_path ||= '/bin/bash'
      end
    end
  end
end
