curl radia.run | want_perl=1 bash -s home
# reverse dns
echo 'export BIVIO_HTTPD_PORT=8000' >> ~/.pre_bivio_bashrc
echo 'export BIVIO_HOST_NAME=z50.bivio.biz' >> ~/.pre_bivio_bashrc
