require File.expand_path('../../../benchmark_helper', __FILE__)
require 'linebook/os/posix'

class PosixBench < Test::Unit::TestCase
  include Linecook::Test
  include Benchmark
  
  def setup
    super
    use_helpers Linebook::Os::Linux
  end
  
  def test_unless_construction_speed
    bm(20) do |x|
      n = 1
      
      x.report("#{n}k unless_") do
        (n * 1000).times do
          recipe.unless_('false') { }
        end
      end
    end
  end
end