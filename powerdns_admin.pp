class  { 'powerdns_admin':
  backend_install => false,
  db_password     => 'changeme_pdns_admin_db_password',
  pdns_api_key    => 'changeme_api_key',
  signup_enable   => true
}

class { 'nginx':
  confd_purge  => true,
  server_purge => true,
}

nginx::resource::server { 'poweradmin':
  ensure               => present,
  server_name          => ['changeme_domain_name'],
  use_default_location => false,
  index_files          => [ 'index.html', 'index.htm', 'index.php'],
  proxy_set_header     => ['Host $host', 'X-Real-IP $remote_addr', 'X-Forwarded-For $proxy_add_x_forwarded_for'],
  client_max_body_size => '10m',
  ssl                  => true,
  listen_port          => 80,
}

nginx::resource::location { 'poweradmin_root':
  ensure                => present,
  server                => 'poweradmin',
  location              => '/',
  proxy                 => 'http://unix:/opt/web/powerdns-admin/powerdns-admin.sock',
  proxy_read_timeout    => '120',
  proxy_connect_timeout => '120',
  proxy_redirect        => 'off',
}

nginx::resource::location { 'poweradmin_static':
  ensure   => present,
  server   => 'poweradmin',
  location => '~ ^/static/',
  www_root => '/opt/web/powerdns-admin/app',
}
