push-to-devel:
	rsync -ave ssh usr-lib-one-sunstone-public-js-plugins/ 		root@$OPENNEBULAFE:/usr/lib/one/sunstone/public/js/plugins/
	rsync -ave ssh var-lib-one-remotes-datastore-gfs2clvm/ 		oneadmin@$OPENNEBULAFE:/var/lib/one/remotes/datastore/gfs2clvm/
	rsync -ave ssh var-lib-one-remotes-tm-gfs2clvm/				oneadmin@$OPENNEBULAFE:/var/lib/one/remotes/tm/gfs2clvm/

