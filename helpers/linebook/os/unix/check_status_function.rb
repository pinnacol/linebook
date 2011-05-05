Defines the check status function.

()
--
  function 'check_status' do |expected, actual, error, message|
    if_ "[ #{actual} -ne #{expected} ]" do
      writeln "echo [#{actual}] #{program_name}:${4:-?}"
      exit_ error
    end
    
    else_ do
      return_ actual
    end
  end
