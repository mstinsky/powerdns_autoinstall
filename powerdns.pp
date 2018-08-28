class { 'powerdns':
  db_password      => 'changeme_pdns_db_password',
  db_root_password => 'changeme_pdns_db_root_password',
  version          => '4.1',
}
powerdns::config { 'authoritative-local-address':
  type    => 'authoritative',
  setting => 'local-address',
  value   => "${::ipaddress}, 127.0.0.1",
}
powerdns::config { 'api':
  ensure  => present,
  setting => 'api',
  value   => 'yes',
  type    => 'authoritative',
}
powerdns::config { 'api-key':
  ensure  => present,
  setting => 'api-key',
  value   => 'changeme_api_key',
  type    => 'authoritative',
}
