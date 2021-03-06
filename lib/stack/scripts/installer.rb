module Stack
  module Scripts
    class Installer

      def initialize( stack )
        @stack = stack
        @computer = Stack::Brain::Computer.new
        @command_factory = Stack::Brain::Command

        preload

      end

      def preload
        commands = []

        commands << @command_factory.create("Creating key pair") do
          @stack.key_pair.create unless @stack.key_pair.exists?
        end

        commands << @command_factory.create("Creating Group #{@stack.group.name}") do
          @stack.group.create unless @stack.group.exists?
        end

        commands << @command_factory.create("Creating Group #{@stack.db_group.name}") do
          @stack.db_group.create unless @stack.db_group.exists?
        end

        commands << @command_factory.create("Creating Group #{@stack.cache_group.name}") do
          @stack.cache_group.create unless @stack.cache_group.exists?
        end

        @computer.register commands

        commands = []
        commands << @command_factory.create("Creating Database #{@stack.database.name}") do
          unless @stack.database.exists?
            @stack.database.create
          end
        end
        commands << @command_factory.create("Creating Cache #{@stack.cache.name}") do
          unless @stack.cache.exists?
            @stack.cache.create
          end
        end
        @computer.register commands

        commands = []

        @stack.applications.each do |application|
          application.build.commands.each{ |command| @computer.register command }
        end

      end

      def run
        @computer.execute
        p @computer.result
      end

    end
  end
end
