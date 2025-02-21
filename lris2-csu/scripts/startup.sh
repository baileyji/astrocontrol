#!/bin/zsh
source /opt/conda/bin/activate lris2csu
pip install -e /opt/app
jupyter notebook --ip=0.0.0.0 --port=8888 --allow-root --NotebookApp.token=''
#python /opt/app/daemon.py &\n\
wait