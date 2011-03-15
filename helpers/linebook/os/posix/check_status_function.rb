Adds the check status function.
()
--
  function 'check_status', ' if [ $2 -ne $1 ]; then echo "[$2] $0:${4:-?}"; exit $3; else return $2; fi '
