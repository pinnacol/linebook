require File.expand_path('../../../benchmark_helper', __FILE__)
require 'linebook/os/linux'

class LinuxBench < Test::Unit::TestCase
  include Linecook::Test
  include Benchmark
  
  def setup
    super
    use_helpers Linebook::Os::Linux
  end
  
  def test_su_constuction_speed
    bm(20) do |x|
      n = 1
      
      x.report("#{n}k login") do
        setup_recipe
        (n * 1000).times do
          recipe.login { }
        end
      end
      
      x.report("#{n}k su") do
        setup_recipe
        (n * 1000).times do
          recipe.su { }
        end
      end
    end
  end
end