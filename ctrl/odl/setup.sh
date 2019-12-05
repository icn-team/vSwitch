SCRIPT_PATH=$( cd "$(dirname "${BASH_SOURCE}")" ; pwd -P )
tput setaf "1"
cat $SCRIPT_PATH/hicn.txt
tput sgr0
python $SCRIPT_PATH/mounting.py -act add
sleep 3
python $SCRIPT_PATH/facing.py
sleep 3
python $SCRIPT_PATH/routing.py
sleep 3
python $SCRIPT_PATH/punting.py
echo "Routing policy were applied to the network. Enjoy the telemetry Now!"
