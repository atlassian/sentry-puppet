require 'spec_helper'

describe 'sentry' do 
    context 'supported operating systems' do
        on_supported_os.each do |os, facts|
            context "on #{os}" do
                let(:facts) do
                    facts
                end
                
                context "sentry class without any parameters" do
                    it { is_expected.to compile.with_all_deps }
                    it { is_expected.to contain_file('/etc/puppetlabs/puppet/sentry.yaml').with({'ensure' => 'file'},'owner' => 'root', 'group' => 'root', 'mode' => '0644',})}
