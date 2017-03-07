class sentry (

  $user  = $::sentry::params::user,
  $group = $::sentry::params::group,
  $dsn   = $::sentry::params::dsn,

) inherits ::sentry::params { 

 class { '::sentry::config': } ->
 Class['::sentry']

}
