require 'spec_helper'
describe 'stackdriver' do
  context 'with default values for all parameters' do
    it { should compile.with_all_deps }
    it { should contain_class('stackdriver') }

    it { is_expected.to have_resource_count(6) }
    it { is_expected.to have_class_count(1) }

    it do
      should contain_yumrepo('stackdriver').with({
        :ensure   => 'present',
        :descr    => 'Stackdriver Agent Repository',
        :baseurl  => 'http://repo.stackdriver.com/repo/el6/$basearch/',
        :enabled  => true,
        :gpgcheck => true,
        :gpgkey   => 'https://app.stackdriver.com/RPM-GPG-KEY-stackdriver',
        :before   => [
          'Package[stackdriver-agent]',
          'Package[stackdriver-extractor]',
        ],
      })
    end

    it do
      should contain_package('stackdriver-agent').with({
        :ensure => 'present',
      })
    end

    it do
      should contain_package('stackdriver-extractor').with({
        :ensure => 'present',
      })
    end

    sysconfig_content = <<-END.gsub(/^\s+\|/, '')
      |# This file is being maintained by Puppet.
      |# DO NOT EDIT
      |
      |# whether or not to autogenerate the stackdriver collectd config file
      |AUTOGENERATE_COLLECTD_CONFIG="yes"
      |
      |# url to a proxy for outbound https
      |PROXY_URL=""
      |
      |# your stackdriver api key
      |STACKDRIVER_API_KEY=""
      |
      |# the location of the java libraries, for the java plugin
      |# substitute the location where libjvm.so can be found
      |#JAVA_LIB_DIR="/usr/lib/jvm/jre-1.8.0-openjdk.x86_64/lib/amd64/server"
      |DETECT_GCM="yes"
    END

    it do
      should contain_file('/etc/sysconfig/stackdriver').with({
        :ensure  => 'file',
        :content => sysconfig_content,
        :owner   => 'root',
        :group   => 'root',
        :mode    => '0644',
        :require => 'Package[stackdriver-agent]',
        :notify  => 'Service[stackdriver-agent]',
      })
    end

    it do
      should contain_service('stackdriver-agent').with({
        :ensure  => 'running',
        :enable  => true,
        :require => 'Package[stackdriver-agent]',
      })
    end

    it do
      should contain_service('stackdriver-extractor').with({
        :ensure  => 'stopped',
        :enable  => false,
        :require => 'Package[stackdriver-extractor]',
      })
    end
  end

  describe 'with parameter manage_repo' do
    [true,'true',false,'false'].each do |value|
      context "set to #{value} (as #{value.class})" do
        let(:params) { { :manage_repo => value } }

        if value.to_s == 'true'
          it { should contain_yumrepo('stackdriver') }
        else
          it { should_not contain_yumrepo('stackdriver') }
        end
      end
    end
  end

  describe 'with parameter baseurl' do
    context 'set to a valid URL' do
      let(:params) { { :baseurl => 'http://yum/el6/x86_64/' } }

      it do
        should contain_yumrepo('stackdriver').with({
          :baseurl  => 'http://yum/el6/x86_64/',
        })
      end
    end
  end

  describe 'variable type and content validations' do
    #let(:facts) { [mandatory_facts, { :osfamily => 'RedHat', }].reduce(:merge) }

    validations = {
      'bool stringified' => {
        :name    => %w(manage_repo),
        :valid   => [true, false, 'true', 'false'],
        :invalid => ['string', %w(array), { 'ha' => 'sh' }, 3, 2.42, nil],
        :message => '(is not a boolean|Unknown type of boolean given)',
      },
      # /!\ Downgrade for Puppet 3.x: remove fixnum and float from invalid list
      'url_string' => {
        :name    => %w(baseurl gpgkey),
        :valid   => ['http://string'],
        :invalid => [%w(array), { 'ha' => 'sh' }, true, false,],
        :message => 'is not a string',
      },
    }

    validations.sort.each do |type, var|
      var[:name].each do |var_name|
        var[:params] = {} if var[:params].nil?
        var[:valid].each do |valid|
          context "when #{var_name} (#{type}) is set to valid #{valid} (as #{valid.class})" do
            let(:params) { [var[:params], { :"#{var_name}" => valid, }].reduce(:merge) }
            it { should compile }
          end
        end

        var[:invalid].each do |invalid|
          context "when #{var_name} (#{type}) is set to invalid #{invalid} (as #{invalid.class})" do
            let(:params) { [var[:params], { :"#{var_name}" => invalid, }].reduce(:merge) }
            it 'should fail' do
              expect { should contain_class(subject) }.to raise_error(Puppet::Error, /#{var[:message]}/)
            end
          end
        end
      end # var[:name].each
    end # validations.sort.each
  end # describe 'variable type and content validations'
end
