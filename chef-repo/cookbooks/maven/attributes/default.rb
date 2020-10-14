#
# Cookbook:: maven
# Attributes:: default
#
# Author:: Seth Chisamore (<schisamo@chef.io>)
# Author:: Bryan W. Berry (<bryan.berry@gmail.com>)
#
# Copyright:: 2010-2016, Chef Software, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

default['maven']['m2_home'] = '/usr/local/maven'
default['maven']['mavenrc']['opts'] = '-Dmaven.repo.local=$HOME/.m2/repository -Xmx384m'
default['maven']['version'] = '3.5.2'
# default['maven']['url'] = "http://archive.apache.org/dist/maven/maven-#{node['maven']['version'].split('.')[0]}/#{node['maven']['version']}/binaries/apache-maven-#{node['maven']['version']}-bin.tar.gz"
# default['maven']['checksum'] = '707b1f6e390a65bde4af4cdaf2a24d45fc19a6ded00fff02e91626e3e42ceaff'
# default['maven']['plugin_version'] = '2.10'
default['maven']['url'] = "https://s3.amazonaws.com/repo.camsys-apps.com/third-party/org/apache/maven/maven/3.5.4/apache-maven-3.5.4-bin.tar.gz"
default['maven']['checksum'] = 'ce50b1c91364cb77efe3776f756a6d92b76d9038b0a0782f7d53acf1e997a14d'
default['maven']['version'] = '3.5.4'
default['maven']['repositories'] = ['http://repo1.maven.apache.org/maven']
default['maven']['setup_bin'] = true
