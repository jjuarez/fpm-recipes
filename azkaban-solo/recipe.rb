##
# Azkaban Solo server from LinkedIn Corp.
class AzkabanSolo < FPM::Cookery::Recipe

  description 'The most simple form of Azkaban server'
  name     'azkaban-solo'
  version  '2.5.0'
  revision 0
  license  'Apache License, Version 2.0'
  homepage 'http://azkaban.github.io/'
  source   "https://s3.amazonaws.com/azkaban2/azkaban2/#{version}/azkaban-solo-server-#{version}.tar.gz"
  md5      'a3a5a681f040cd4f7d4032e40edb0953'
  arch     'all'
  section  'databases'
  depends 'default-jre-headless'

  post_install   'post-install'
  post_uninstall 'post-uninstall'

  config_files %w{
    /etc/default/azkaban-solo
    /etc/azkaban-solo/azkaban-users.xml
    /etc/azkaban-solo/log4j.properties
    /etc/azkaban-solo/global.properties
    /etc/azkaban-solo/azkaban.properties
    /etc/azkaban-solo/azkaban.private.properties
  }

  def build
  end


  def install

		opt('azkaban-solo').install Dir['*']
		opt('azkaban-solo/bin').install workdir('azkaban-solo.sh')

		etc('default').install workdir('azkaban-solo.default'), 'azkaban-solo'
		etc('init.d').install workdir('azkaban-solo.init'), 'azkaban-solo'
		etc('security/limits.d').install workdir('azkaban-solo.limits'), 'azkaban-solo.conf'
		etc('logrotate.d').install workdir('azkaban-solo.logrotate'), 'azkaban-solo.conf'

    etc('azkaban-solo').install Dir['conf/*']
    etc('azkaban-solo').install workdir('log4j.properties')
  end
end

