name             'storm-cluster'
maintainer       'Kai Sasaki'
maintainer_email 'lewuathe@me.com'
license          'MIT License'
description      'Installs/Configures storm'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.0.7'
depends          'java'
#source_url       'https://github.com/Lewuathe/storm-cookbook'
#issues_url       'https://github.com/Lewuathe/storm-cookbook/issues'
provides         'storm-cluster::nimbus'
provides         'storm-cluster::supervisor'
supports         'ubuntu'
