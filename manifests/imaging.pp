# == Class: cows::imaging
#
# A class to obtain the packages required to install Python
# imaging library, Pillow and install it.
#
# === Authors
#
# Mike Wilson - mw@ceh.ac.uk
#

class cows::imaging (
  $version  = '1.7.8'
) {
    # Pillow dependencies based on info supplied by
    #  http://pillow.readthedocs.org/en/latest/installation.html#linux-installation
    case $::osfamily {
      'RedHat' : {
        $pillow = [
          'libtiff-devel', 
          'libjpeg-turbo-devel', 
          'libzip-devel', 
          'freetype-devel', 
          'lcms2-devel', 
          'tcl-devel', 
          'tk-devel'
        ]
      }

      'Debian' : {
        $pillow = [
          'libtiff4-dev',
          'libjpeg8-dev',
          'zlib1g-dev',
          'libfreetype6-dev',
          'liblcms2-dev',
          'libwebp-dev',
          'tcl8.5-dev',
          'tk8.5-dev',
        ]
      }
    }

    package { $pillow:
      ensure  => installed,
    }

    package {'Pillow':
      ensure    => $version,
      provider  => 'pip',
      require   => Package[$pillow],
    }

    Class['::python'] -> Class['cows::imaging']

}