class sentry (

  $user  = $::sentry::params::user,
  $group = $::sentry::params::group,

) inherits ::sentry::params { 

 class { '::sentry::config': } ->
 Class['::sentry']

}
