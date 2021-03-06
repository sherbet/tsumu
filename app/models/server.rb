class Server
  include Mongoid::Document

  field :name, type: String
  field :ip, type: String
  field :private_ip_address, type: String
  field :dns, type: String
  field :groups_name, type: Array
  field :role, type: String

  belongs_to :application, inverse_of: :servers

  before_destroy :destroy_box

  rails_admin do

    list do
      field :eco_system_name
      field :application
      field :state
      field :ip
      field :private_ip_address
      field :groups_name
    end

    show do
      field :eco_system_name
      field :application
      field :name
      field :ip
      field :private_ip_address
      field :dns
      field :created_at
    end

    show do
    end

    edit do
      field :application
      field :groups_name
      field :role, :string
      field :ip
      field :private_ip_address
      # field :dns
      # field :created_at
    end

  end

  state_machine :state, :initial => :creating do

    event :build do
      transition :creating => :ran_up
    end

    event :bootstrap do
      transition :ran_up => :bootstraping
    end

    event :bootstrap_ended do
      transition :bootstraping => :bootstraped
    end

    event :verify do
      transition :bootstraped => :verified
    end

    before_transition :creating => :ran_up do |server, transition|
      server.build_box
    end

  end

  def bootstrap_job
    p "bootstraping server #{name}"
    box.bootstrap
    bootstrap_ended!
  end

  def provision!
    box.bootstrap
  end

  def provider
    eco_system.warehouse.compute
  end

  def bootstrap_role
    role.present? ? role : application.name
  end


  def update_after_run_up( server )
    update_attributes(  name: server.id,
                        ip: server.public_ip_address,
                        private_ip_address: server.private_ip_address,
                        dns: server.dns_name )
  end


  include ServerMethods

end
