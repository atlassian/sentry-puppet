require 'hiera_puppet'
require 'puppet'

begin
    require 'rubygems'
rescue LoadError => e
    Puppet.err "You need `rubygems` to send reports to Sentry"
end

begin
    require 'raven'
rescue LoadError => e
    Puppet.err "You need the `sentry-raven` gem installed on the puppetmaster to send reports to Sentry"
end

Puppet::Reports.register_report(:sentry) do
    desc = 'Puppet reporter designed to send failed runs to a sentry server'

    # Process an event
    def process
        # We only care if the run failed
        if self.status != 'failed'
            return
        end

        config = HieraPuppet.lookup('sentry', {}, self, nil, :priority)

        # Check the config contains what we need
        if not config['dsn']
            raise(Puppet::ParseError, "Sentry did not contain a dsn")
        end

        if self.respond_to?(:host)
            @host = self.host
        end

        if self.respond_to?(:kind)
            @kind = self.kind
        end

        if self.respond_to?(:puppet_version)
            @puppet_version = self.puppet_version
        end

        if self.respond_to?(:configuration_version)
            @configuration_version = self.configuration_version
        end

        if self.respond_to?(:transaction_uuid)
            @transaction_uuid = self.transaction_uuid
        end

        if self.respond_to?(:status)
            @status = self.status
        end

        if self.respond_to?(:environment)
            @environment = self.environment
        end

        # Configure raven
        Raven.configure do |c|
            c.dsn = config['dsn']
            c.encoding = 'gzip'
            c.timeout = 5
        end

        tags = {
            'status'      => @status,
            'environment' => @environment,
            'version'     => @puppet_version,
            'kind'        => @kind,
            'configuration_version' => @configuration_version,
            'transaction_uuid' => @transaction_uuid,
        }

        self.resource_statuses.each do |_, status|
            status.events.each do |event|
                if event.status != "failure"
                    return
                end

                Raven.captureMessage(event.message, {
                  :culprit => status.resource,
                  :server_name => @host,
                  :tags => tags.merge({
                    'resource' => status.title,
                    'resource_type' => status.resource_type,
                  }),
                  :extra => {
                    'name'   => event.name,
                    'property'   => event.property,
                    'previous_value' => event.previous_value,
                    'desired_value' => event.desired_value,
                    'historical_value' => event.historical_value,
                    'line'   => status.line,
                    'file'   => status.file,
                  },
                })
            end
        end
    end
end
