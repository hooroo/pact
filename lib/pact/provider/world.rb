module Pact

  def self.world
    @world ||= Pact::Provider::World.new
  end

  # internal api, for testing only
  def self.clear_world
    @world = nil
  end

  module Provider
    class World

      def initialize
      end

      def provider_states
        @provider_states_proxy ||= Pact::Provider::State::ProviderStateProxy.new
      end

    end
  end
end