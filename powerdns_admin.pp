class  { 'powerdns_admin':
  backend_install => false,
  db_password     => 'changeme_pdns_admin_db_password',
  pdns_api_key    => 'changeme_api_key',
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
  listen_port          => 443,
  ssl_cert             => '/etc/nginx/certs/cert.pem',
  ssl_key              => '/etc/nginx/certs/key.pem',
  ssl_ciphers          => 'EECDH+AESGCM:EDH+AESGCM:EECDH:EDH:!MD5:!RC4:!LOW:!MEDIUM:!CAMELLIA:!ECDSA:!DES:!DSS:!3DES:!NULL',
  ssl_protocols        => 'TLSv1.1 TLSv1.2',
}

nginx::resource::server { 'poweradmin_ssl_redirect':
  ensure              => present,
  server_name         => ['changeme_domain_name'],
  listen_port         => 80,
  location_cfg_append => {
    rewrite             => "^ https://changeme_domain_name\$request_uri? permanent",
  },
}

nginx::resource::location { 'poweradmin_root':
  ensure                => present,
  ssl                   => true,
  ssl_only              => true,
  server                => 'poweradmin',
  location              => '/',
  proxy                 => 'http://unix:/opt/web/powerdns-admin/powerdns-admin.sock',
  proxy_read_timeout    => '120',
  proxy_connect_timeout => '120',
  proxy_redirect        => 'off',
}

nginx::resource::location { 'poweradmin_static':
  ensure   => present,
  ssl      => true,
  ssl_only => true,
  server   => 'poweradmin',
  location => '~ ^/static/',
  www_root => '/opt/web/powerdns-admin/app',
}
