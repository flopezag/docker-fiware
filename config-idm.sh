#!/bin/bash

#########################
# Reconfigure settings.py
#########################

clientid=$1
clientsecret=$2

# Add url('', include('social_django.urls', namespace='social')),
line1="    # 'wirecloud.oauth2provider',"
line2="    'social_django',"

printf "%s\n%s\n" "$line1" "$line2" > ./wirecloud_instance/a.out

sed "/'wirecloud.oauth2provider',/ d" ./wirecloud_instance/settings.py > ./wirecloud_instance/settings1.py
sed "/'wirecloud.fiware',/ r ./wirecloud_instance/a.out" ./wirecloud_instance/settings1.py > ./wirecloud_instance/settings2.py

echo "AUTHENTICATION_BACKENDS = ("                              >> ./wirecloud_instance/settings2.py
echo "    'wirecloud.fiware.social_auth_backend.FIWAREOAuth2'," >> ./wirecloud_instance/settings2.py
echo "    'django.contrib.auth.backends.ModelBackend',"         >> ./wirecloud_instance/settings2.py
echo ")"                                                        >> ./wirecloud_instance/settings2.py

echo                                                            >> ./wirecloud_instance/settings2.py


echo "FIWARE_IDM_SERVER = 'http://fiware-idm:3000'"             >> ./wirecloud_instance/settings2.py
echo                                                            >> ./wirecloud_instance/settings2.py
echo "SOCIAL_AUTH_FIWARE_KEY = '$clientid'"                     >> ./wirecloud_instance/settings2.py
echo                                                            >> ./wirecloud_instance/settings2.py
echo "SOCIAL_AUTH_FIWARE_SECRET = '$clientsecret'"              >> ./wirecloud_instance/settings2.py

rm ./wirecloud_instance/settings.py
rm ./wirecloud_instance/settings.pyc
rm ./wirecloud_instance/settings1.py
mv ./wirecloud_instance/settings2.py ./wirecloud_instance/settings.py

#####################
# Reconfigure urls.py
#####################

# Search 'from wirecloud.commons import authentication as wc_auth'
# and add 'from wirecloud.fiware import views as wc_fiware'
sed "s/from wirecloud.commons import authentication as wc_auth/from wirecloud.commons import authentication as wc_auth%from wirecloud.fiware import views as wc_fiware/" < ./wirecloud_instance/urls.py | tr "%" "\n" > ./wirecloud_instance/urls1.py

# Add url(r'^login/?$', wc_fiware.login, name="login"),
# Remove url(r'^login/?$', django_auth.login, name="login"),
sed "s/django_auth\.login/wc_fiware\.login/" < ./wirecloud_instance/urls1.py > ./wirecloud_instance/urls2.py

# Add url('', include('social_django.urls', namespace='social')),
line1="    # Social django"
line2="    url('', include('social_django.urls', namespace='social')),"

printf "\n%s\n%s\n" "$line1" "$line2" > ./wirecloud_instance/a.out

sed "/url(r'^admin\/', include(admin.site.urls)),/ r ./wirecloud_instance/a.out" ./wirecloud_instance/urls2.py > ./wirecloud_instance/urls3.py

rm ./wirecloud_instance/a.out
rm ./wirecloud_instance/urls1.py ./wirecloud_instance/urls2.py
mv ./wirecloud_instance/urls3.py ./wirecloud_instance/urls.py
rm ./wirecloud_instance/urls.pyc
