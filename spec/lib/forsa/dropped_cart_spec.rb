require 'rails_helper'
require 'forsa/dropped_cart'

RSpec.describe Forsa::DroppedCart do
  describe '#subscribe_dropped_applications' do
    subject(:dropped_cart) { Forsa::DroppedCart.new(logger) }

    let(:logger)      { spy('Logger') }

    let(:fake_gibbon) { spy('Gibbon::Request') }
    before do
      allow_any_instance_of(DroppedCartMailingListSubscriber).to receive(:mail_chimp).and_return(fake_gibbon)
    end

    context 'there is one application over 24h old from created_at' do
      include ActiveSupport::Testing::TimeHelpers

      let!(:abandoned_application) { create :membership_application, :abandoned }

      before do
        create :membership_application, :step_about_you
        create :membership_application, :step_declaration, created_at: 25.hours.ago

        dropped_cart.subscribe_dropped_applications
      end

      it 'subscribes to the DROPPED_CART list and does not do so again' do
        aggregate_failures do
          expect(fake_gibbon).to have_received(:lists).with(ENV['MAILCHIMP_DROPPED_CART_LIST_ID']).once

          dropped_cart.subscribe_dropped_applications # now ignores things it has sent

          expect(fake_gibbon).to have_received(:lists).with(ENV['MAILCHIMP_DROPPED_CART_LIST_ID']).once
        end
      end

      it 'records dropped_cart_processed_at' do
        expect(abandoned_application.reload.dropped_cart_processed_at).to be_an(ActiveSupport::TimeWithZone)
      end
    end

    context 'there are two applications over 24h old from created_at' \
            'with the same email and one of them is complete' do
      include ActiveSupport::Testing::TimeHelpers

      let!(:dropped_application) do
        create :membership_application, :step_about_you, email: 'dupe@example.com', created_at: 25.hours.ago
      end

      before do
        create :membership_application, :step_declaration, email: 'dupe@example.com', created_at: 24.hours.ago

        dropped_cart.subscribe_dropped_applications
      end

      it 'does not subscribe people who have already completed' do
        expect(fake_gibbon).not_to have_received(:lists)
      end

      it 'records dropped_cart_processed_at' do
        expect(dropped_application.reload.dropped_cart_processed_at).to be_an(ActiveSupport::TimeWithZone)
      end
    end

    context 'there are no applications over 24h old from created_at' do
      before do
        create :membership_application, :step_about_you
        dropped_cart.subscribe_dropped_applications
      end

      it 'does not subscribe anybody to anything' do
        expect(fake_gibbon).not_to have_received(:lists)
      end
    end

    context 'there are bad email addresses that would 400' do
      let!(:bad_email) { create :membership_application, :abandoned, :bad_email }

      before do
        allow(fake_gibbon).to receive(:lists).and_raise(Gibbon::MailChimpError, 'the server responded with status 400')

        dropped_cart.subscribe_dropped_applications
      end

      it 'logs the error and will not attempt to send again' do
        expect(logger).to have_received(:error).with(an_instance_of(Gibbon::MailChimpError))
        expect(bad_email.reload.dropped_cart_processed_at).not_to be_nil
      end
    end
  end
end
