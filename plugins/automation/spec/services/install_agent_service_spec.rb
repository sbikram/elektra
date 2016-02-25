require 'spec_helper'

RSpec.describe InstallAgentService do

  describe 'process_request' do

    before(:each) do
      @instance_id = 'some_nice_instance_id'
      @os = 'linux'
      @url = 'some_nice_url'
      @script = 'some cool script'
      @automation_service = double('automation_service')
      @active_project = double('active_project', id: 'miau', domain_id: 'bup')
      @service = InstallAgentService.new()
    end

    it 'should raise an exception if instance_id is empty or nil' do
      # empty
      expect { @service.process_request('', '', nil, nil, '', '') }.to raise_error(InstallAgentParamError, 'Instance id empty')
      # blank
      expect { @service.process_request(nil, '', nil, nil, '', '') }.to raise_error(InstallAgentParamError, 'Instance id empty')
    end

    it 'should raise an exception if instance not found' do
      Object.const_set 'NotFound', Class.new(StandardError)
      compute_service = double('compute_service')
      allow(compute_service).to receive(:find_server){ raise Core::ServiceLayer::Errors::ApiError.new(NotFound.new('test')) }
      expect { @service.process_request(@instance_id, '', compute_service, nil, '', '') }.to raise_error(InstallAgentParamError, "Instance with id #{@instance_id} not found")
    end

    it "should raise an error if agent already exists on the instance" do
      instance = double('instance', id: @instance_id, image: double('image', name: 'cuak_cuak'))
      compute_service = double('compute_service', find_server: instance)
      allow(@automation_service).to receive(:agent){ true }

      expect { @service.process_request(@instance_id, '', compute_service, @automation_service, '', '') }.to raise_error(InstallAgentAlreadyExists, "Agent already exists on instance id #{instance.id} (#{instance.image.name})")
    end

    it "should raise an exception if instance_os and image metadata os_family are empty or nil" do
      instance = double('instance', id: @instance_id, image: double('image', name: 'cuak_cuak', metadata: {}))
      compute_service = double('compute_service', find_server: instance)
      allow(@automation_service).to receive(:agent){ raise ::RestClient::ResourceNotFound.new() }

      expect { @service.process_request(@instance_id, '', compute_service, @automation_service, '', '') }.to raise_error(InstallAgentInstanceOSNotFound, "Instance OS empty or not known")
      expect { @service.process_request(@instance_id, nil, compute_service, @automation_service, '', '') }.to raise_error(InstallAgentInstanceOSNotFound, "Instance OS empty or not known")
    end

    it "should get the image metadata os_family when input param instance_os is empty or nil" do
      instance = double('instance', id: @instance_id, image: double('image', name: 'cuak_cuak', metadata: {'os_family'=> @os}), addresses: {}, metadata: double('metadata', dns_name: ''))
      compute_service = double('compute_service', find_server: instance)
      allow(@automation_service).to receive(:agent){ raise ::RestClient::ResourceNotFound.new() }
      allow(RestClient::Request).to receive(:new).and_return( double('response', execute: {url: @url}.to_json) )
      allow(@service).to receive(:create_script).with(@url,@os).and_return( @script )

      expect( @service.process_request(@instance_id, '', compute_service, @automation_service, @active_project, '') ).to match( {log_info: '', instance: instance, script: @script} )
    end

    it "should return the right log info" do
      instance = double('instance', id: @instance_id, image: double('image', name: 'cuak_cuak', metadata: {'os_family'=> @os}), addresses: {'first_ip' => [{'addr' => 'this_is_the_ip'}]}, metadata: double('metadata', dns_name: 'mo_hash'))
      compute_service = double('compute_service', find_server: instance)
      allow(@automation_service).to receive(:agent){ raise ::RestClient::ResourceNotFound.new() }
      allow(RestClient::Request).to receive(:new).and_return(double('response', execute: {url: @url}.to_json))
      allow(@service).to receive(:create_script).with(@url, @os).and_return( @script )

      expect( @service.process_request(@instance_id, '', compute_service, @automation_service, @active_project, '') ).to match( {log_info: 'this_is_the_ip / mo_hash', instance: instance, script: @script} )
    end

  end

end