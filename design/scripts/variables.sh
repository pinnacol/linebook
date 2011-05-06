function countargs () {
  echo "$# args: $*"
}

function get () {
  countargs $1
  countargs "$*"
  countargs "$@"
  echo
  countargs "$(shift 1; echo $*)"
  countargs "$(shift 1; echo $@)"
  countargs $(shift 1; echo $*)
  x=$(shift 1; echo $@)
  countargs $x
  echo
  countargs "$@"
  countargs "$*"
  countargs $1
  echo
  
}

get one two three

X="a b c"

# In this system the output behaves like $*

# "echo #{x}"
echo $X
# "echo #{x.sub('b', 'y')}"
echo ${X/b/y}
# "echo #{x.sub('b', 'y').sub('c', 'z')}"
# ???

echo
# "echo #{x}"
echo $(echo "$X")
# "echo #{x.sub('b', 'y')}"
echo $(X=${X/b/y}; echo "$X")
# "echo #{x.sub('b', 'y').sub('c', 'z')}"
echo $(X=${X/b/y}; X=${X/c/z}; echo "$X")

echo
# "echo #{x}"
echo "$(echo "$X")"
# "echo #{x.sub('b', 'y')}"
echo "$(X=${X/b/y}; echo "$X")"
# "echo #{x.sub('b', 'y').sub('c', 'z')}"
echo "$(X=${X/b/y}; X=${X/c/z}; echo "$X")"