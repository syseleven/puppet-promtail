require 'spec_helper'

describe 'promtail::install' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      context 'with valid params' do
        let(:facts) { os_facts }
        let(:pre_condition) do
          "class { 'promtail':
            password_file_path    => '/etc/promtail/.gc_pw',
            password_file_content => Sensitive('myPassword'),
            server_config_hash    => {
              'server' => {
                'http_listen_port' => 9274,
                'grpc_listen_port' => 0,
              },
            },
            clients_config_hash => {
              'clients' => [{
                'url'        => 'https://logs-us-west1.grafana.net/api/prom/push',
                'basic_auth' => {
                  'username' => '1234',
                  'password_file' => '/etc/promtail/.gc_pw',
                },
              }],
            },
            positions_config_hash => {
              'positions' => {
                'filename' => '/tmp/positions.yaml',
              },
            },
            scrape_configs_hash => {
              'scrape_configs' => [{
                'job_name'       => 'system_secure',
                'entry_parser'   => 'raw',
                'static_configs' => [{
                  'targets' => [ 'localhost' ],
                  'labels'  => {
                    'job'      => 'var_log_secure',
                    'host'     => $facts['networking']['fqdn'],
                    '__path__' => '/var/log/messages',
                  },
                }],
              }],
            },
          }"
        end

        it { is_expected.to compile }
        it { is_expected.to contain_file('/usr/local/bin/promtail').with_ensure('link') }
        it { is_expected.to contain_file('/usr/local/promtail_data').with_ensure('directory') }
      end
    end
  end
end
