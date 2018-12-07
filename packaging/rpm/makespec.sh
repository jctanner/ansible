#!/bin/bash

if [ ! -f packaging/rpm/ansible.spec.orig ]; then
	cp packaging/rpm/ansible.spec packaging/rpm/ansible.spec.orig
fi

cp packaging/rpm/ansible.spec.orig packaging/rpm/ansible.spec
cp packaging/rpm/ansible.spec /tmp/ansible.spec
fgrep -A100 '%changelog' /tmp/ansible.spec > /tmp/ansible.spec.changelog
cat /tmp/ansible.spec | fgrep -v '%changelog' | fgrep -v '* %{release_date}' | fgrep -v 'Release %{rpmversion}-%{rpmrelease}' > /tmp/ansible.spec.main

echo '%exclude %{python_sitelib}/ansible/module_docs_fragments/*' >> /tmp/ansible.spec.main
echo '%exclude %{python_sitelib}/ansible/modules/*' >> /tmp/ansible.spec.main

find lib/ansible/module_utils \
	| sort \
	| egrep -v 'module_utils'$ \
	| egrep -v 'module_utils/__init__.py' \
	| egrep -v $.pyc \
	| egrep -v basic \
	| egrep -v '/common/' \
	| egrep -v '/facts/' \
	| egrep -v parsing \
	| egrep -v pycompat \
	| egrep -v six \
	| egrep -v _text \
	| egrep -v 'module_utils/common' \
	| sed 's|lib|%exclude %{python_sitelib}|g' \
	| sed 's|\.py|\.\*|' \
	>> /tmp/ansible.spec.main

cat /tmp/ansible.spec.main > packaging/rpm/ansible.spec
echo "" >> packaging/rpm/ansible.spec
cat /tmp/ansible.spec.changelog >> packaging/rpm/ansible.spec
