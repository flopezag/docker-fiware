#########################
# Reconfigure settings.py
#########################

read -p "Client ID: " clientid
read -p "Client Secret: " clientsecret


sed "s/'wirecloud.oauth2provider',/# 'wirecloud.oauth2provider',%    'social_django',/" < ./wirecloud_instance/settings.py | tr "%" "\n" > ./wirecloud_instance/settings1.py

echo "AUTHENTICATION_BACKENDS = ("                              >> ./wirecloud_instance/settings1.py
echo "    'wirecloud.fiware.social_auth_backend.FIWAREOAuth2'," >> ./wirecloud_instance/settings1.py
echo "    'wirecloud.fiware.social_auth_backend.FIWAREOAuth2'," >> ./wirecloud_instance/settings1.py
echo "    'django.contrib.auth.backends.ModelBackend',"         >> ./wirecloud_instance/settings1.py
echo ")"                                                        >> ./wirecloud_instance/settings1.py

echo                                                            >> ./wirecloud_instance/settings1.py


echo "FIWARE_IDM_SERVER = 'http://127.0.0.1:3000'"              >> ./wirecloud_instance/settings1.py
echo                                                            >> ./wirecloud_instance/settings1.py
echo "SOCIAL_AUTH_FIWARE_KEY = '$clientid'"                     >> ./wirecloud_instance/settings1.py
echo                                                            >> ./wirecloud_instance/settings1.py
echo "SOCIAL_AUTH_FIWARE_SECRET = '$clientsecret'"              >> ./wirecloud_instance/settings1.py

rm ./wirecloud_instance/settings.py
rm ./wirecloud_instance/settings.pyc
mv ./wirecloud_instance/settings1.py ./wirecloud_instance/settings.py

#####################
# Reconfigure urls.py
#####################

