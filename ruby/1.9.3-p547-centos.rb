class Ruby193 < FPM::Cookery::Recipe
  description 'The Ruby virtual machine'

  name     'ruby'
  version  '1:1.9.3.547'
  revision 0
  homepage 'http://www.ruby-lang.org/'
  source   'http://ftp.ruby-lang.org/pub/ruby/1.9/ruby-1.9.3-p547.tar.gz'
  md5      '7531f9b1b35b16f3eb3d7bea786babfd'

  section 'interpreters'

  build_depends 'autoconf', 'readline-devel', 'bison', 'zlib-devel',
                'openssl-devel', 'libyaml-devel', 'ncurses-devel'

  depends 'libffi', 'ncurses', 'readline', 'openssl', 
          'libyaml-devel', 'zlib-devel'

  def build
    configure :prefix => prefix, 'disable-install-doc' => true
    make
  end

  def install
    make :install, 'DESTDIR' => destdir
  end
end
