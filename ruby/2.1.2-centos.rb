class Ruby210 < FPM::Cookery::Recipe
  description 'The Ruby virtual machine'

  name     'ruby'
  version  '1:2.1.2'
  revision 0
  homepage 'http://www.ruby-lang.org/'
  source   'http://cache.ruby-lang.org/pub/ruby/2.1/ruby-2.1.2.tar.bz2'
  sha256   '6948b02570cdfb89a8313675d4aa665405900e27423db408401473f30fc6e901'

  section       'interpreters'
  build_depends 'autoconf', 'bison', 'readline-devel', 'zlib-devel', 'openssl-devel', 'libyaml-devel'
  depends       'ffi', 'ncurses', 'readline', 'openssl', 'tinfo5', 'libyaml', 'zlib'

  def build

    configure :prefix => prefix, 'disable-install-doc' => true
    make
  end

  def install

    make :install, 'DESTDIR' => destdir
  end
end
