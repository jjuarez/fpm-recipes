##
# Azkaban Solo server from LinkedIn Corp.
class AzkabanSolo < FPM::Cookery::Recipe

  description 'Azkaban solo server with LDAP support'

  name     'azkaban-solo'
  version  '2.5.0'
  revision 'tuenti1'
  license  'Apache License, Version 2.0'
  homepage 'http://azkaban.github.io/'
  source   "https://s3.amazonaws.com/azkaban2/azkaban2/#{version}/azkaban-solo-server-#{version}.tar.gz"
  md5      'a3a5a681f040cd4f7d4032e40edb0953'
  arch     'all'
  section  'databases'

# depends 'default-jre-headless'

  post_install   'post-install'
  post_uninstall 'post-uninstall'

  config_files %w{
    /etc/security/limits.d/azkaban-solo.conf
    /etc/logrotate.d/azkaban-solo.conf
    /etc/default/azkaban-solo
    /etc/azkaban-solo/azkaban-users.xml
    /etc/azkaban-solo/log4j.properties
    /etc/azkaban-solo/global.properties
    /etc/azkaban-solo/azkaban.properties
    /etc/azkaban-solo/azkaban.private.properties
  }

  def build
    # nothing to do here...
  end

  def install

    # Files from the original .tar.gz
    opt('azkaban-solo').install Dir['*']

    # Additional plugins
    opt('azkaban-solo/plugins').install workdir('plugins/azkaban-ldap-usermanager-1.0.3.jar'), 'azkaban-ldap-usermanager-1.0.3.jar'

    # System configuration
    etc('security/limits.d').install workdir('config/azkaban-solo.limits'), 'azkaban-solo.conf'
    etc('logrotate.d').install       workdir('config/azkaban-solo.logrotate'), 'azkaban-solo.conf'
    etc('default').install           workdir('config/azkaban-solo.default'), 'azkaban-solo'
    etc('init.d').install            workdir('scripts/azkaban-solo.init'), 'azkaban-solo'
    etc('azkaban-solo').install      workdir('config/log4j.properties')

    # Service basic configuration
    etc('azkaban-solo').install Dir['conf/*'] # The .tar.gz basic configuration
  end
end

