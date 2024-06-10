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
set -ex

source $(dirname $0)/functions

ovs_dir=/var/lib/openvswitch

wait_for_ovsdb_server

# Start vswitchd by asking it to wait till flow restore is finished.
ovs-vsctl --no-wait set open_vswitch . other_config:flow-restore-wait=true
/usr/sbin/ovs-vswitchd --pidfile --mlockall --detach

# Restore saved flows and inform vswitchd that we are done.
if [ -f ${ovs_dir}/flows ]; then
    eval "$(cat ${ovs_dir}/flows)"
fi

ovs-vsctl --if-exists remove open_vswitch . other_config flow-restore-wait=true

sleep infinity
