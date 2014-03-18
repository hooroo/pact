require 'spec_helper'

module Pact::Provider


  describe TestMethods do

    include TestMethods

    PROVIDER_STATE_MESSAGES = []

    before do
      PROVIDER_STATE_MESSAGES.clear
      Pact.clear_world

      Pact.base_provider_state do
        set_up do
          PROVIDER_STATE_MESSAGES << :global_base_set_up
        end

        tear_down do
          PROVIDER_STATE_MESSAGES << :global_base_tear_down
        end
      end

      Pact.provider_states_for "a consumer with provider states" do
        base_provider_state do
          set_up do
            PROVIDER_STATE_MESSAGES << :consumer_base_set_up
          end

          tear_down do
            PROVIDER_STATE_MESSAGES << :consumer_base_tear_down
          end
        end

        provider_state "a custom state" do
          set_up do
            PROVIDER_STATE_MESSAGES << :custom_consumer_state_set_up
          end

          tear_down do
            PROVIDER_STATE_MESSAGES << :custom_consumer_state_tear_down
          end
        end

      end
    end

    describe "set_up_provider_state" do

      subject { set_up_provider_state "a custom state", "a consumer with provider states" }

      it "sets up the global base state" do
        subject
        expect(PROVIDER_STATE_MESSAGES[0]).to eq :global_base_set_up
      end

      it "sets up the consumer base state" do
        subject
        expect(PROVIDER_STATE_MESSAGES[1]).to eq :consumer_base_set_up
      end

      it "sets up the consumer custom state" do
        subject
        expect(PROVIDER_STATE_MESSAGES[2]).to eq :custom_consumer_state_set_up
      end
    end

    describe "tear_down_provider_state" do

      subject { tear_down_provider_state "a custom state", "a consumer with provider states" }

      it "tears down the consumer custom state" do
        subject
        expect(PROVIDER_STATE_MESSAGES[0]).to eq :custom_consumer_state_tear_down
      end

      it "tears down the consumer base state" do
        subject
        expect(PROVIDER_STATE_MESSAGES[1]).to eq :consumer_base_tear_down
      end

      it "tears down the global base state" do
        subject
        expect(PROVIDER_STATE_MESSAGES[2]).to eq :global_base_tear_down
      end
    end

  end

end