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

ovs_dir=/var/lib/openvswitch

if [ -f $ovs_dir/flows ]; then
    rm -f $ovs_dir/flows
fi
if [ -d $ovs_dir/saved_flows ]; then
    rm -rf $ovs_dir/saved_flows
fi

# Saving the flows here in order to avoid disrupting gateway datapath. We need
# to make sure ovsdb-server is running to use the save-flows command
# https://github.com/openvswitch/ovs/blob/85d19a5edd160a91b1407561cc49296380663b61/utilities/ovs-save#L34
# which allows us to keep the flows while reloading the pod. This is based on
# the initial reload option for ovs
# https://github.com/openvswitch/ovs/commit/ea36b04688f37cf45b7c2304ce31f0d29f212d54#diff-dcb4491325151a3044b5073d4419d9ffe2a9af86c6ba6e042772d7b32cd303e9
ovs-vsctl -- --real list-br > $bridges
/usr/share/openvswitch/scripts/ovs-save save-flows $bridges > $ovs_dir/flows

tmp_dir=$(cat $ovs_dir/flows | tail -1 | awk '{split($0,a,"\""); split(a[2],b,"/"); print b[3]}')
mkdir ${ovs_dir}/saved_flows
cp /tmp/${tmp_dir}/* ${ovs_dir}/saved_flows/.
sed -i "s|/tmp/ovs-save.*/|$openvswitch/saved_flows/|g" ${ovs_dir}/flows

/usr/share/openvswitch/scripts/ovs-ctl stop --no-ovsdb-server

# Once save-flows logic is complete it no longer needs ovsdb-server, this file
# unlocks the db preStop script, working as a semaphore
touch $ovs_dir/is_safe_to_stop_ovsdb_server
