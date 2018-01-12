# frozen_string_literal: true

require 'spec_helper'
require_relative '../factories/factories'

describe Automation::NodesController, type: :controller do
  routes { Automation::Engine.routes }

  default_params = {domain_id: AuthenticationStub.domain_id, project_id: AuthenticationStub.project_id}

  before(:all) do
    FriendlyIdEntry.find_or_create_entry('Domain',nil,default_params[:domain_id],'default')
    FriendlyIdEntry.find_or_create_entry('Project',default_params[:domain_id],default_params[:project_id],default_params[:project_id])
  end

  before :each do
    stub_authentication

    client = double('arc_client').as_null_object
    automation_service = double('automation_service').as_null_object
    automation_run_service = double('automation_run_service').as_null_object

    allow(UserProfile).to receive(:tou_accepted?).and_return(true)
    allow_any_instance_of(ServiceLayer::AutomationService).to receive(:client).and_return(client)
    allow_any_instance_of(ServiceLayer::AutomationService).to receive(:automation_service).and_return(automation_service)
    allow_any_instance_of(ServiceLayer::AutomationService).to receive(:automation_run_service).and_return(automation_run_service)
  end

  describe "GET 'index'" do

    before :each do
      # mock the nodes with jobs
      @nodes = ::Automation::FakeFactory.new.nodes
      @nodes[:jobs] = {}
      @nodes[:addresses] = {}
      indexServiceNode = double('index_service_node', list_nodes_with_jobs: @nodes)
      allow(IndexNodesService).to receive(:new).and_return(indexServiceNode)
    end

    it "returns http success" do
      get :index, params: default_params
      expect(response).to be_success
      expect(response).to render_template(:index)
    end

    it "should assign variables" do
      get :index, params: default_params
      expect(@nodes[:elements]).to eq(assigns(:nodes))
      expect(@nodes[:jobs]).to include(assigns(:jobs))
    end

  end

  describe "GET 'show'" do

    it "returns http success" do
      get :show, params: default_params.merge({id: "node_id"})
      expect(response).to be_success
      expect(response).to render_template(:show)
    end

    it "should assign variables" do
      node = ::Automation::FakeFactory.new.node
      allow_any_instance_of(ServiceLayer::AutomationService).to receive(:node).and_return(node)

      get :show, params: default_params.merge({id: "node_id"})
      expect(node).to eq(assigns(:node))
      expect(assigns(:node_form)).to be_truthy
      expect(assigns(:node_form_read)).to be_truthy
      expect(assigns(:facts)).to be_truthy
      expect(assigns(:jobs)).to be_truthy
    end

  end

  describe "GET 'install'" do
    before :each do
      allow_any_instance_of(ServiceLayer::ComputeService).to receive(:servers).and_raise("boom")
    end

    it "returns http success" do
      get :install, params: default_params
      expect(response).to be_success
      expect(response).to render_template(:install)
    end

    it "should assign variables" do
      get :install, params: default_params
      expect(assigns(:compute_instances)).to be_truthy
    end


    it "should rescue on error" do
      get :install, params: default_params
      expect(assigns(:compute_instances)).to be_empty
      expect(assigns(:errors)).to be_truthy
    end

  end

  describe "GET xhr 'show_instructions'" do

    it "returns http success" do
      get :show_instructions, params: default_params.merge({id: "instance_id", type: "external"}), xhr: true
      expect(response).to be_success
      expect(response).to render_template(:show_instructions)
    end

  end

  describe "GET xhr 'update'" do

    it "returns http success" do
      put :update, params: default_params.merge({id: "node_id"}), xhr: true
      expect(response).to be_success
      expect(response).to render_template(:update)
    end

    it "renders the page correcty when an exception happens" do
      allow_any_instance_of(Automation::Forms::NodeTags).to receive(:update).and_raise("boom update")
      put :update, params: default_params.merge({id: "node_id"}), xhr: true
      expect(assigns(:node)).to be_truthy
      expect(assigns(:node_form_read)).to be_truthy
      expect(assigns(:node_form)).to be_truthy
      # expect(assigns(:errors)).to be_truthy
    end

  end

  describe "GET xhr run_automation" do

    it "returns http success" do
      get :run_automation, params: default_params.merge({id: "node_id", }), xhr: true
      expect(response).to be_success
      expect(response).to render_template(:run_automation)
    end

  end

  describe "DELETE destroy" do

    it "returns http success" do
      expect(delete :destroy, params: default_params.merge({id: "node_id"})).to redirect_to(nodes_path(default_params))
    end

  end

end
