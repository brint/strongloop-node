name             'strongloop'
maintainer       'Rackspace Hosting'
maintainer_email 'ryan.walker@rackspace.com'
license          'Apache 2.0'
description      'Installs/Configures StrongLoop'
#long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.2'

%w{apt build-essential firewall nginx nodejs npm openssl supervisor}.each do |cookbook|
  depends cookbook
end
