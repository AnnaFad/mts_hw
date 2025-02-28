sudo ln -s /etc/nginx/sites-available/ya /etc/nginx/sites-enabled/ya
sudo ln -s /etc/nginx/sites-available/dh /etc/nginx/sites-enabled/dh
sudo systemctl reload nginx
sudo systemctl status nginx
ssh -L 9870:tmpl-nn:9870 -L 8088:tmpl-nn:8088 -L 19888:tmpl-nn:19888 team@176.109.91.10 
