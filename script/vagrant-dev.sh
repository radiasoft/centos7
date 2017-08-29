curl radia.run | want_perl=1 bash -s home
# reverse dns
echo 'export BIVIO_HTTPD_PORT=8000' >> ~/.pre_bivio_bashrc
echo 'export BIVIO_HOST_NAME=z50.bivio.biz' >> ~/.pre_bivio_bashrc

bivio dev setup
bivio sql init_dbms
bivio project link_facade_files
bivio sql -force create_test_db

groupadd -g gid gname
useradd -g gname -u uid -s shell -G group1,group2 uname

useradd -g vagrant vagrant
usermod -G group1,group2 vagrant # absolute
usermod -a -G group3 vagrant # appends
