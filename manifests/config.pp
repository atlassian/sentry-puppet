 class sentry::config {

   file{ '/etc/puppetlabs/puppet/sentry.yaml':
     ensure  => file,
     mode    => '0644',
     owner   => $::sentry::user,
     group   => $::sentry::group,
     content => template('sentry/sentry.yaml.erb')
   }
}
