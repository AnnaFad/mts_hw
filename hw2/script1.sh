scp mapred-site.xml tmpl-dn-00:/home/hadoop/hadoop-3.4.0/etc/hadoop
scp mapred-site.xml tmpl-dn-01:/home/hadoop/hadoop-3.4.0/etc/hadoop
scp mapred-site.xml tmpl-nn:/home/hadoop/hadoop-3.4.0/etc/hadoop

scp yarn-site.xml tmpl-dn-00:/home/hadoop/hadoop-3.4.0/etc/hadoop
scp yarn-site.xml tmpl-dn-01:/home/hadoop/hadoop-3.4.0/etc/hadoop
scp yarn-site.xml tmpl-nn:/home/hadoop/hadoop-3.4.0/etc/hadoop

hadoop-3.4.0/sbin/start-yarn.sh
mapred --daemon start historyserver