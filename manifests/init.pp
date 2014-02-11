# == Class: cows
#
# A class to obtain the packages required to deploy COWS
# core, client and server and then install them.
#
# TODO: Only works on CentOS, needs more work for Ubuntu!
#
# == Dependencies
#
# stankevich/python >=1.6.2
#
# === Authors
#
# Mike Wilson - mw@ceh.ac.uk
#

class cows ()
  {
    class { 'python':
      pip         => true,
      dev         => true,
      virtualenv  => true,
    }
  
    class { 'imaging':}

    # Make sure Python is install before running any packages
    # that require the pip provider!
    Class['python'] -> Package<| provider == 'pip' |>    

    # Download servers
    $servers        = {
      'ndg'         => 'http://ndg.nerc.ac.uk/dist/',
      'badc'        => 'http://cows.badc.rl.ac.uk/dist/',
      'cairo'       => 'http://www.cairographics.org/releases/'
    }
    # Python package version pins
    $versions       = {
      'matplotlib'  => '1.1.0',
      'pylons'      => '1.0',
      'geoplot'     => '0.4.3',
      'numpy'       => '1.8.0',
      'cdat_lite'   => '6.0rc2',
      'basemap'     => '1.0.7',
      'mock'        => '1.0.1',
      'shapely'     => '1.3.0',
      'genshi'      => '0.7',
      'owslib'      => '0.8.3',
      'libxml2dom'  => '0.5',
      'pycairo'     => '1.8.8',
      'image_utils' => '1.0',
      'csml'        => '2.7.21',
      'cows'        => '1.6.1',
      'cowsserver'  => '1.6.1',
      'cowsclient'  => '1.7.0',
    }

    # Install required system packages
    package {'netcdf':         ensure => installed,}
    package {'netcdf-devel':   ensure => installed,}
    package {'cairo':          ensure => installed,}
    package {'cairo-devel':    ensure => installed,}
    package {'geos':           ensure => installed,}
    package {'geos-devel':     ensure => installed,}
    package {'libxml2-python': ensure => installed,}
    package {'libpng-devel':   ensure => installed,}

    # Pip installed packages
    package { 
      'numpy':
        ensure   => $versions['numpy'],
        provider => 'pip';
      'matplotlib':
        ensure    => $versions['matplotlib'],
        provider  => 'pip',
        require   => Package['numpy'];
      'cdat_lite':
        ensure   => $versions['cdat_lite'],
        provider => 'pip',
        require  => Package['netcdf', 'netcdf-devel', 'numpy'];
      'basemap':
        ensure    => $versions['basemap'],
        provider  => 'pip',
        require   => Package['geos', 'geos-devel', 'numpy'];
      'pylons':
        ensure    => $versions['pylons'],
        provider  => 'pip';
      'mock':
        ensure    => $versions['mock'],
        provider  => 'pip';
      'shapely':
        ensure    => $versions['shapely'],
        provider  => 'pip';
      'genshi':
        ensure    => $versions['genshi'],
        provider  => 'pip';
      'owslib':
        ensure    => $versions['owslib'],
        provider  => 'pip';
      'libxml2dom':
        ensure    => $versions['libxml2dom'],
        provider  => 'pip';
      'pycairo':
        ensure    => installed,
        provider  => 'pip',
        require   => Package['cairo', 'cairo-devel'],
        source    => "${servers['cairo']}pycairo-${versions['pycairo']}.tar.gz";
      'geoplot':
        ensure    => installed,
        provider  => 'pip',
        require   => Package['numpy', 'matplotlib'],
        source    => "${servers['badc']}geoplot-${versions['geoplot']}.tar.gz";
      'image_utils':
        ensure    => installed,
        provider  => 'pip',
        source    => "${servers['badc']}image_utils-${versions['image_utils']}.tar.gz";
      'csml':
        ensure    => installed,
        provider  => 'pip',
        require   => Package['numpy', 'cdat_lite'],
        source    => "${servers['ndg']}csml-${versions['csml']}.tar.gz";
      'cows':
        ensure    => installed,
        provider  => 'pip',
        require   => Package['genshi', 'numpy', 'cdat_lite',
                      'csml', 'pycairo', 'shapely', 
                      'Pillow', 'matplotlib', 'basemap',
                      'mock', 'owslib', 'geoplot',
                      'image_utils', 'pylons'],
        source    => "${servers['badc']}cows-${versions['cows']}.tar.gz";
      'cowsserver':
        ensure    => installed,
        provider  => 'pip',
        require   => Package['cows'],
        source    => "${servers['badc']}cowsserver-${versions['cowsserver']}.tar.gz";
    }

    # Easy_install'ed packages
    exec { "easy_install ${servers['ndg']}cowsclient-${versions['cowsclient']}-py2.6.egg":
      path    => 'usr/local/bin:/usr/bin:/bin',
      unless  => "python -c 'import cowsclient'",
      require => Package['cows'],
    }
}
