#!/bin/sh
#
# Copyright 2024 Red Hat Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
ovs_dir=/var/lib/openvswitch

# ovs_vswitchd container needs to terminate before ovsdb-server because it need
# access to the db on the preStop script. This semaphore ensures it is not torn
# down.
while [ ! -f $ovs_dir/is_safe_to_stop_ovsdb_server ]
do
  sleep 0.5
done

rm $ovs_dir/is_safe_to_stop_ovsdb_server
/usr/share/openvswitch/scripts/ovs-ctl stop --no-ovs-vswitchd
