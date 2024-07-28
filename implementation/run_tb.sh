source ~micasusr/design/scripts/questasim_2022.4.rc

usage() {
  echo "Usage: $0 [-TREE / -CHAIN]"
  exit 1
}

# Check if no arguments are provided
if [ $# -eq 0 ]; then
  usage
fi

# Parse the command-line options
while [[ "$1" != "" ]]; do
  case "$1" in
    -TREE )
      echo "Tree option selected"
      TREE=1 vsim -c -do run_sim_matmul.tcl
      ;;
    -CHAIN )
      echo "Chain option selected"
      TREE=0 vsim -c -do run_sim_matmul.tcl
      ;;
    * )
      echo "Invalid option: $1"
      usage
      ;;
  esac
  shift
done
