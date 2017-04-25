module SafeShell
  module Mock
    NOOP = ': ;'
    ECHO_PIPE = 'read a; echo $a;'

    class << self
      def make cmd_name, code=nil
        func_body = code.nil? ? 'echo $@ ;' : code
        "#{cmd_name} () { #{func_body} }"
      end
    end
  end
end
