require File.expand_path('../test_helper', __FILE__) 
require 'linebook'

class LinebookTest < Test::Unit::TestCase
  include Linebook
  
  DIR_ONE = File.expand_path('../fixtures/dir_one', __FILE__)
  DIR_TWO = File.expand_path('../fixtures/dir_two', __FILE__)
  
  MANIFEST = {
    'a.txt' => File.join(DIR_ONE, 'base/a.txt'),
    'b.txt' => File.join(DIR_TWO, 'base/b.txt'),
    'c.txt' => File.join(DIR_TWO, 'base/c.txt')
  }
  
  MANIFEST_ONE = {
    'a.txt'   => File.join(DIR_ONE, 'base/a.txt'),
    'a/x.txt' => File.join(DIR_ONE, 'base/a/x.txt'),
    'a/y.txt' => File.join(DIR_ONE, 'base/a/y.txt'),
    'b.txt'   => File.join(DIR_ONE, 'base/b.txt'),
    'b/x.txt' => File.join(DIR_ONE, 'base/b/x.txt'),
    'b/y.txt' => File.join(DIR_ONE, 'base/b/y.txt')
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
  
  #
  # Linebook test
  #
  
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
  
  def test_line_book_splits_and_expands_paths
    assert_equal MANIFEST, Linebook(
      'patterns' => 'base/*.txt',
      'paths'    => "#{DIR_ONE}:#{DIR_TWO}"
    )
  end
  
  def test_line_book_splits_and_expands_patterns
    assert_equal MANIFEST_ONE, Linebook(
      'patterns' => 'base/*.txt:base/*/*.txt',
      'paths'    => DIR_ONE
    )
  end
  
  #
  # README tests
  #
  
  def test_line_book_string_form
    assert_equal NEST_MANIFEST, Linebook(
      'patterns' => 'base/*.txt:base/*/*.txt',
      'paths'    => "#{DIR_ONE}:#{DIR_TWO}"
    )
  end
  
  def test_line_book_split_form
    assert_equal NEST_MANIFEST, Linebook(
      'patterns' => ['base/*.txt', 'base/*/*.txt'],
      'paths'    => [DIR_ONE, DIR_TWO]
    )
  end
  
  def test_line_book_paths_form
    assert_equal NEST_MANIFEST, Linebook(
      'paths' => [
        [DIR_ONE, 'base', '*.txt'],
        [DIR_ONE, 'base', '*/*.txt'],
        [DIR_TWO, 'base', '*.txt'],
        [DIR_TWO, 'base', '*/*.txt']
      ]
    )
  end
  
  def test_line_book_hash_patterns
    assert_equal MANIFEST, Linebook(
      'patterns' => { 'base' => '*.txt' },
      'paths'    => [DIR_ONE, DIR_TWO]
    )
  end
  
  def test_line_book_multiple_hash_patterns
    assert_equal MANIFEST_ONE, Linebook(
      'patterns' => { 'base' => '*.txt:*/*.txt' },
      'paths'    => DIR_ONE
    )
    
    assert_equal MANIFEST_ONE, Linebook(
      'patterns' => { 'base' => ['*.txt', '*/*.txt'] },
      'paths'    => DIR_ONE
    )
  end
  
  def test_line_book_allows_mixed_path_and_pattern_inputs
    assert_equal NEST_MANIFEST, Linebook(
      'patterns' => ['base/*.txt', ['base', '*/*.txt']],
      'paths'    => [DIR_ONE, [DIR_TWO, 'base', '**/*.txt']]
    )
  end
  
  def test_line_book_overrides_results_with_manifest
    assert_equal MANIFEST_ONE, Linebook(
      'patterns' => { 'base' => '*/*.txt' },
      'paths'    => DIR_ONE,
      'manifest' => {
        'a.txt' => File.join(DIR_ONE, 'base/a.txt'),
        'b.txt' => File.join(DIR_ONE, 'base/b.txt'),
      }
    )
  end
  
  #
  # __manifest test
  #
  
  def test__manifest_returns_manifest_of_matching_files_along_paths
    assert_equal MANIFEST, __manifest(
      'paths' => [
        [DIR_ONE, 'base', '*.txt'],
        [DIR_TWO, 'base', '*.txt']
      ]
    )
    
    assert_equal NEST_MANIFEST, __manifest(
      'paths' => [
        [DIR_ONE, 'base', '**/*.txt'],
        [DIR_TWO, 'base', '**/*.txt']
      ]
    )
  end
  
  #
  # __paths test
  #
  
  def test__paths_splits_string_paths
    assert_equal [
      ['dir', 'base', 'pattern'],
      ['DIR', 'base', 'pattern']
    ], __paths(
      'patterns' => [['base', 'pattern']],
      'paths'    => 'dir:DIR'
    )
  end
  
  def test__paths_splits_and_divides_string_patterns
    assert_equal [
      ['dir', 'base', 'pat/tern'],
      ['dir', 'BASE', 'PAT/TERN']
    ], __paths(
      'patterns' => 'base/pat/tern:BASE/PAT/TERN',
      'paths'    => 'dir'
    )
  end
  
  def test__paths_returns_full_paths
    assert_equal [['dir', 'base', 'pattern']], __paths('paths' => [['dir', 'base', 'pattern']])
  end
  
  def test__paths_assumes_no_paths
    assert_equal [], __paths('patterns' => [['base', 'pattern']])
  end
  
  def test__paths_assumes_no_patterns
    assert_equal [], __paths('paths' => [DIR_ONE, DIR_TWO])
  end
  
  #
  # __normalize_patterns test
  #

  def test__normalize_patterns_returns_array_patterns
    assert_equal [
      ['base', 'pattern']
    ], __normalize_patterns([
      ['base', 'pattern']
    ])
  end
  
  def test__normalize_patterns_arrayifies_hash_patterns
    assert_equal [
      ['base', 'pattern'],
      ['BASE', 'PATTERN']
    ].sort, __normalize_patterns({
      'base' => ['pattern'],
      'BASE' => ['PATTERN']
    }).sort
  end
  
  def test__normalize_patterns_splits_string_values_in_hash_patterns
    assert_equal [
      ['base', 'pattern'],
      ['base', 'PATTERN']
    ], __normalize_patterns({
      'base' => 'pattern:PATTERN'
    })
  end
  
  def test__normalize_raises_error_for_non_hash_or_array_patterns
    obj = Object.new
    err = assert_raises(RuntimeError) { __normalize_patterns(obj) }
    assert_equal "invalid patterns: #{obj.inspect}", err.message
  end
  
  #
  # __combine test
  #
  
  def test__combine_combines_patterns_with_string_paths
    assert_equal [
      ['dir', 'base', 'pattern'],
      ['dir', 'BASE', 'PATTERN'],
      ['DIR', 'base', 'pattern'],
      ['DIR', 'BASE', 'PATTERN']
    ], __combine(
      [['base', 'pattern'], ['BASE', 'PATTERN']],
      ['dir', 'DIR']
    )
  end
  
  def test__combine_does_not_combine_patterns_with_array_paths
    assert_equal [
      ['dir', 'base', 'pattern'],
      ['DIR', 'BASE', 'PATTERN']
    ], __combine(
      [['base', 'pattern']],
      ['dir', ['DIR', 'BASE', 'PATTERN']]
    )
  end
  
  def test__combine_raises_error_for_non_string_or_array_path
    obj = Object.new
    err = assert_raises(RuntimeError) { __combine([], [obj]) }
    assert_equal "invalid path: #{obj.inspect}", err.message
  end
end