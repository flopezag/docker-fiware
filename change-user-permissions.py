#!/usr/bin/env python
# -*- encoding: utf-8 -*-
##
# Copyright 2017 FIWARE Foundation, e.V.
# All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
##
from django.contrib.auth.models import User
import os

username = os.environ["MY_USERNAME"]
superuser = True if os.environ["MY_SUPERUSER"] == "True" else False

print("username: {}\nsuperuser: {}\n".format(username, superuser))

# construct the argument parse and parse the arguments
user = User.objects.get(username=username)
user.is_staff = superuser
user.is_superuser = superuser
user.username = user.first_name

# Save the data
user.save()
