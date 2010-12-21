require File.expand_path('../test_helper', __FILE__) 
require 'linebook'

class LinebookTest < Test::Unit::TestCase
  DIR_ONE = File.expand_path('../fixtures/dir_one', __FILE__)
  DIR_TWO = File.expand_path('../fixtures/dir_two', __FILE__)
  
  MANIFEST = {
    'a.txt' => File.join(DIR_ONE, 'base/a.txt'),
    'b.txt' => File.join(DIR_TWO, 'base/b.txt'),
    'c.txt' => File.join(DIR_TWO, 'base/c.txt')
  }
  
  NEST_MANIFEST = {
    'a.txt'   => File.join(DIR_ONE, 'base/a.txt'),
    'a/x.txt' => File.join(DIR_ONE, 'base/a/x.txt'),
    'a/y.txt' => File.join(DIR_ONE, 'base/a/y.txt'),
    'b.txt'   => File.join(DIR_TWO, 'base/b.txt'),
    'b/x.txt' => File.join(DIR_ONE, 'base/b/x.txt'),
    'b/y.txt' => File.join(DIR_TWO, 'base/b/y.txt'),
    'b/z.txt' => File.join(DIR_TWO, 'base/b/z.txt'),
    'c.txt'   => File.join(DIR_TWO, 'base/c.txt'),
    'c/y.txt' => File.join(DIR_TWO, 'base/c/y.txt'),
    'c/z.txt' => File.join(DIR_TWO, 'base/c/z.txt')
  }
  
  def test_line_book_returns_manifest_of_matching_files_along_paths
    assert_equal MANIFEST, Linebook(
      'paths' => [
        [DIR_ONE, 'base', '*.txt'],
        [DIR_TWO, 'base', '*.txt']
      ]
    )
    
    assert_equal NEST_MANIFEST, Linebook(
      'paths' => [
        [DIR_ONE, 'base', '**/*.txt'],
        [DIR_TWO, 'base', '**/*.txt']
      ]
    )
  end
end