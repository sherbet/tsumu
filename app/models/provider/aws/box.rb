module Provider
  module Aws
    class Box

      def initialize( record, provider )
        @record = record
        @provider = provider
      end

      def get
        @provider.servers.get(@record.name)
        rescue
        nil
      end

      def exists?
        !get.nil?
      end

      def destroy
        get.destroy
      end

      def run_up
        unless exists?
          server = @provider.servers.new({
            flavor_id: @record.application.safe_flavor,
            image_id: @record.application.safe_image_id,
            vpc_id: @record.eco_system.vpc,
            subnet_id: @record.eco_system.subnet.box_id,
            # groups: @groups,
            key_name: @record.application.eco_system.key_pairs.first.name,
            tags: { group: @record.application.name, eco_system: @record.eco_system_name  }
            })
          server.save
          server.wait_for { sleep(1); ready? }
          server
        end
      end

      def bootstrap
        system "knife bootstrap #{get.public_ip_address} -x ubuntu -i keys/#{@record.application.eco_system.key_pairs.first.name}.pem -r 'role[#{@record.application.name}]' --secret-file .chef/encrypted_data_bag_secret --sudo -E #{@record.application.eco_system.name}"
      end


    end
  end
end
