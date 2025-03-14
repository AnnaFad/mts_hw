 sudo apt install python3.12-venv
 sudo -i -u hadoop
 cd ~
 source ~/.profile
 python3 -m venv .venv
 source .venv/bin/activate
 pip install pyspark
 pip install onetl
 pip install notebook