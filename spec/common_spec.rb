require 'spec_helper'

describe 'storm-cluster::common' do
  cached(:chef_run) { ChefSpec::ServerRunner.converge(described_recipe) }

  it 'Includes the java recipe' do
    expect(chef_run).to include_recipe('java')
  end

  it 'adds the storm group to the system' do
    expect(chef_run).to create_group('storm')
  end

  it 'adds the storm user to run the storm application as' do
    expect(chef_run).to create_user('storm').with(
      comment: 'For storm services',
      group:     'storm',
      home:    '/home/storm',
      shell:   '/bin/bash'
   )
  end

  it 'creates the directory /usr/share/storm' do
    expect(chef_run).to create_directory('/usr/share/storm').with(
      owner: 'root',
      group: 'root',
      mode:  '0644'
    )
  end

  it 'creates the file "/tmp/apache-storm-0.9.3.tar.gz"' do
    expect(chef_run).to create_cookbook_file(
      '/tmp/apache-storm-0.9.3.tar.gz').with(
      source: 'apache-storm-0.9.3.tar.gz'
    )
  end

  it 'runs the install script' do
    expect(chef_run).to run_script('install_storm').with(
      interpreter: 'bash',
      user:        'root'
    )
  end

  it 'adds the tempalted file /usr/share/storm/apache-storm-0.9.3/conf/storm.yaml' do
    expect(chef_run).to create_template(
      '/usr/share/storm/0.9.3/conf/storm.yaml').with(
        source: 'storm.yaml.erb',
        mode:   '0440',
        owner:  'root',
        group:  'root'
    )
  end

  it 'renders the template storm.yaml tempalte with contents from ./spec/rendered_templates/storm.yaml' do
    storm_yaml = File.read('./spec/rendered_templates/storm.yaml')
    expect(chef_run).to render_file('/usr/share/storm/0.9.3/conf/storm.yaml').with_content(storm_yaml)
  end
end
