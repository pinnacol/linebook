Defines the check status function.

()
--
  function 'check_status' do |expected, actual, error, message|
    if_ actual.ne(expected) do
      message.default = '?'
      writeln "echo [#{actual}] #{program_name}:#{message}"
      exit_ error
    end
    
    else_ do
      return_ actual
    end
  end
